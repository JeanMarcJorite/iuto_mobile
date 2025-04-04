import 'package:flutter/material.dart';
import 'package:iuto_mobile/db/data/Restaurants/restaurant.dart';
import 'package:provider/provider.dart';
import 'package:iuto_mobile/providers/restaurant_provider.dart';
import 'package:iuto_mobile/widgets/restaurant_card.dart';
import 'package:iuto_mobile/providers/critique_provider.dart';
import '../widgets/filters_widgets.dart';
import 'dart:async';

class RestaurantsPage extends StatefulWidget {
  const RestaurantsPage({super.key});

  @override
  State<RestaurantsPage> createState() => _RestaurantsPageState();
}

class _RestaurantsPageState extends State<RestaurantsPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  Map<String, dynamic> _activeFilters = {};
  List<Restaurant> _localRestaurants = [];
  List<Restaurant> _filteredRestaurants = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final restaurantProvider =
          Provider.of<RestaurantProvider>(context, listen: false);

      setState(() {
        _localRestaurants = restaurantProvider.restaurants;
        _filteredRestaurants = _localRestaurants;
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters(Map<String, dynamic> filters) {
    setState(() {
      _activeFilters = filters;
      _filterRestaurants();
    });
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _filterRestaurants();
      });
    });
  }

  void _filterRestaurants() {
    setState(() {
      _filteredRestaurants = _localRestaurants.where((restaurant) {
        final matchesSearchQuery = _searchController.text.isEmpty ||
            restaurant.nom
                .toLowerCase()
                .contains(_searchController.text.toLowerCase());

        final matchesVegetarian = _activeFilters['isVegetarian'] == null ||
            restaurant.vegetarian == _activeFilters['isVegetarian'];
        final matchesVegan = _activeFilters['isVegan'] == null ||
            restaurant.vegan == _activeFilters['isVegan'];
        final matchesInternetAccess =
            _activeFilters['internetAccess'] == null ||
                restaurant.internetAccess == _activeFilters['internetAccess'];
        final matchesWheelchair = _activeFilters['wheelchair'] == null ||
            restaurant.wheelchair == _activeFilters['wheelchair'];
        final matchesDelivery = _activeFilters['delivery'] == null ||
            restaurant.delivery == _activeFilters['delivery'];
        final matchesTakeaway = _activeFilters['takeaway'] == null ||
            restaurant.takeaway == _activeFilters['takeaway'];
        final matchesDriveThrough = _activeFilters['driveThrough'] == null ||
            restaurant.driveThrough == _activeFilters['driveThrough'];
        final matchesSmoking = _activeFilters['smoking'] == null ||
            restaurant.smoking == _activeFilters['smoking'];

        return matchesSearchQuery &&
            matchesVegetarian &&
            matchesVegan &&
            matchesInternetAccess &&
            matchesWheelchair &&
            matchesDelivery &&
            matchesTakeaway &&
            matchesDriveThrough &&
            matchesSmoking;
      }).toList();
    });
  }

  Future<void> _fetchRestaurantDetailsAndCritiques(int restaurantId) async {
    final restaurantProvider =
        Provider.of<RestaurantProvider>(context, listen: false);
    final critiqueProvider =
        Provider.of<CritiqueProvider>(context, listen: false);

    await restaurantProvider.loadRestaurantById(restaurantId);
    await critiqueProvider.loadCritiquesByRestaurantId(restaurantId);
  }

  @override
  Widget build(BuildContext context) {
    final restaurantProvider = Provider.of<RestaurantProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rechercher un restaurant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) {
                  return FractionallySizedBox(
                    heightFactor: 0.7,
                    child: FiltersWidget(
                      onApplyFilters: _applyFilters,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un restaurant...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: restaurantProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredRestaurants.isEmpty
                    ? const Center(child: Text('Aucun restaurant trouvé.'))
                    : ListView.builder(
                        itemCount: _filteredRestaurants.length,
                        itemBuilder: (context, index) {
                          final restaurant = _filteredRestaurants[index];
                          return RestaurantCard(
                            restaurant: restaurant,
                            width: double.infinity,
                            height: 150,
                            fetchRestaurantDetailsAndCritiques: _fetchRestaurantDetailsAndCritiques,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
