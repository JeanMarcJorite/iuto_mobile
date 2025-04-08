import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:iuto_mobile/db/models/restaurant.dart';
import 'package:iuto_mobile/db/iutoDB.dart';
import 'package:iuto_mobile/db/supabase_service.dart';
import 'package:iuto_mobile/providers/favoris_provider.dart';
import 'package:iuto_mobile/widgets/index.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:iuto_mobile/providers/restaurant_provider.dart';
import 'package:iuto_mobile/providers/geolocalisation_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  StreamSubscription<Position>? _positionSubscription;
  final TextEditingController _searchController = TextEditingController();
  LatLng? _currentPosition;
  bool _isLoadingLocation = true;
  bool _locationEnabled = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await Provider.of<RestaurantProvider>(context, listen: false)
        .loadRestaurants();
    await _loadRestaurantsByPreferences();
    _checkLocationSettings();

    _setupLocationUpdates();
  }

  Future<void> _checkLocationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _locationEnabled = prefs.getBool('localisation') ?? true;
    });

    if (_locationEnabled) {
      await _getCurrentLocation();
    } else {
      setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final geoProvider =
          Provider.of<GeolocalisationProvider>(context, listen: false);
      await geoProvider.loadCurrentPosition();

      if (geoProvider.currentPosition != null && mounted) {
        setState(() {
          _currentPosition = LatLng(
            geoProvider.currentPosition!.latitude,
            geoProvider.currentPosition!.longitude,
          );
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
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

  Future<void> _loadRestaurantsByPreferences() async {
    final db = Provider.of<IutoDB>(context, listen: false);
    final restaurantProvider =
        Provider.of<RestaurantProvider>(context, listen: false);

    try {
      final user = SupabaseService.supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non connecté.');
      }

      final preferences = await db.getPreferences(user.id);
      final preferredCuisineIds = preferences.map((p) => p.idCuisine).toList();

      await restaurantProvider
          .loadRestaurantsByPreferences(preferredCuisineIds);
    } catch (e) {
      debugPrint(
          'Erreur lors du chargement des restaurants par préférences : $e');
    }
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

  Widget _buildRestaurantsByPreferences(RestaurantProvider provider) {
    final preferredRestaurants = provider.restaurantsPreferences;

    if (preferredRestaurants.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Restaurants selon vos préférences',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: preferredRestaurants.length,
          itemBuilder: (context, index) {
            return RestaurantCard(
              restaurant: preferredRestaurants[index],
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IUTables\'O'),
        centerTitle: true,
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
                  initialFilters:
                      Provider.of<RestaurantProvider>(context, listen: false)
                          .activeFilters,
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

        bool hasActiveFilters = restaurantProvider.activeFilters.entries
            .where((entry) => entry.key != 'searchQuery')
            .any((entry) => entry.value == true);

        if (hasActiveFilters && restaurantProvider.restaurants.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.no_meals, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Aucun restaurant ne correspond à ces filtres',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => restaurantProvider.clearFilters(),
                  child: const Text('Réinitialiser les filtres'),
                ),
              ],
            ),
          );
        }

        if (restaurantProvider.allRestaurants.isEmpty) {
          return const Center(child: Text('Aucun restaurant disponible.'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              const SizedBox(height: 32),
              _buildRestaurantsByPreferences(restaurantProvider),
              const SizedBox(height: 32),
              _buildRestaurantsEtoile(restaurantProvider),
              const SizedBox(height: 32),
              if (_locationEnabled && _currentPosition != null)
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

  Widget _buildRestaurantsEtoile(RestaurantProvider provider) {
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
    final dixPlusProcheRestaurants = plusProcheResto.take(10).toList();

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
          itemCount: dixPlusProcheRestaurants.length,
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
