import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:iuto_mobile/db/data/Restaurants/restaurant.dart';
import 'package:iuto_mobile/providers/favoris_provider.dart';
import 'package:iuto_mobile/widgets/filters_widgets.dart';
import 'package:provider/provider.dart';
import 'package:iuto_mobile/providers/restaurant_provider.dart';
import 'package:iuto_mobile/providers/geolocalisation_provider.dart';
import 'package:iuto_mobile/widgets/restaurant_card.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with AutomaticKeepAliveClientMixin {
  StreamSubscription<Position>? _positionSubscription;
  final TextEditingController _searchController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await Provider.of<RestaurantProvider>(context, listen: false)
        .loadRestaurants();
    _setupLocationUpdates();
  }

  void _setupLocationUpdates() {
    final geoProvider =
        Provider.of<GeolocalisationProvider>(context, listen: false);
    final restaurantProvider =
        Provider.of<RestaurantProvider>(context, listen: false);

    geoProvider.loadCurrentPosition().then((_) {
      if (mounted) {
        _updateRestaurantDistances(geoProvider, restaurantProvider);
      }
    });

    _positionSubscription = geoProvider.positionStream.listen((_) {
      if (mounted) {
        _updateRestaurantDistances(geoProvider, restaurantProvider);
      }
    });
  }

  Future<void> _updateRestaurantDistances(
    GeolocalisationProvider geoProvider,
    RestaurantProvider restaurantProvider,
  ) async {
    if (!mounted) return;

    bool hasChanges = false;
    final List<Restaurant> updatedRestaurants = [];

    for (var restaurant in restaurantProvider.restaurants) {
      final newDistance = await geoProvider.calculerDistance(
        restaurant.latitude,
        restaurant.longitude,
      );

      final distanceKm = newDistance != null ? newDistance / 1000 : null;

      if (restaurant.distance != distanceKm) {
        updatedRestaurants.add(restaurant.copyWith(distance: distanceKm));
        hasChanges = true;
      } else {
        updatedRestaurants.add(restaurant);
      }
    }

    if (hasChanges && mounted) {
      restaurantProvider.updateRestaurants(updatedRestaurants);
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('IUTables\'O'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => FiltersWidget(
                  onApplyFilters: (filters) {
                    Provider.of<RestaurantProvider>(context, listen: false)
                        .setFilters(filters);
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: _buildBodyContent(),
    );
  }

  Widget _buildBodyContent() {
    return Consumer2<RestaurantProvider, GeolocalisationProvider>(
      builder: (context, restaurantProvider, geoProvider, _) {
        if (restaurantProvider.isLoading || geoProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (restaurantProvider.restaurants.isEmpty) {
          return const Center(child: Text('Aucun restaurant disponible.'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              const SizedBox(height: 32),
              _buildTopRatedRestaurants(restaurantProvider),
              const SizedBox(height: 32),
              _buildNearestRestaurants(restaurantProvider),
              const SizedBox(height: 32),
              _buildPluslikeRestaurant(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeSection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bienvenue sur la page d\'accueil',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'Bienvenue sur notre plateforme de comparateur de restaurants en ligne. '
          'Vous pouvez comparer les restaurants de la région Orléanaise.',
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher un restaurant...',
          suffixIcon: IconButton(
            onPressed: () {
              if (_searchController.text.isEmpty) return;

              debugPrint("Recherche: ${_searchController.text}");
              context.push("/recherche?search=${_searchController.text}");
            },
            icon: const Icon(Icons.search),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));
  }

  Widget _buildTopRatedRestaurants(RestaurantProvider provider) {
    final topRestaurants = provider.restaurants
        .where((r) => r.stars != null && r.stars! > 1)
        .toList();

    if (topRestaurants.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Les restaurants étoilés',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 340,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: topRestaurants.length,
            itemBuilder: (context, index) {
              return SizedBox(
                width: 300,
                child: RestaurantCard(
                  restaurant: topRestaurants[index],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNearestRestaurants(RestaurantProvider provider) {
    final plusProcheResto = [...provider.restaurants];
    plusProcheResto.sort((a, b) {
      if (a.distance == null) return 1;
      if (b.distance == null) return -1;
      return a.distance!.compareTo(b.distance!);
    });
    final dixMeilleursRestaurants = plusProcheResto.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Les restaurants les plus proches',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: dixMeilleursRestaurants.length,
          itemBuilder: (context, index) {
            return RestaurantCard(
              restaurant: plusProcheResto[index],
            );
          },
        ),
      ],
    );
  }

  Widget _buildPluslikeRestaurant() {
    return Consumer2<RestaurantProvider, FavorisProvider>(
      builder: (context, restaurantProvider, favorisProvider, _) {
        final restaurantLikesCount = <int, int>{};

        for (final favori in favorisProvider.allFavoris) {
          restaurantLikesCount.update(
            favori.idRestaurant,
            (value) => value + 1,
            ifAbsent: () => 1,
          );
        }

        final restaurantsWithLikes =
            restaurantProvider.restaurants.map((resto) {
          return {
            'restaurant': resto,
            'likes': restaurantLikesCount[resto.id] ?? 0,
          };
        }).toList();

        restaurantsWithLikes.sort((a, b) => b['likes']?.compareTo(a['likes']));

        final topLikedRestaurants = restaurantsWithLikes.take(5).toList();

        if (topLikedRestaurants.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Les plus populaires',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 340,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: topLikedRestaurants.length,
                itemBuilder: (context, index) {
                  final item = topLikedRestaurants[index];
                  return SizedBox(
                    width: 300,
                    child: Column(
                      children: [
                        Expanded(
                          child: RestaurantCard(
                            restaurant: item['restaurant'] as Restaurant,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

extension on Object? {
  compareTo(Object? a) {
    if (this == null) return 1;
    if (a == null) return -1;
    if (this is num && a is num) {
      return (this as num).compareTo(a);
    }
    return 0;
  }
}
