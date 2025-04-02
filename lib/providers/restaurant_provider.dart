import 'package:flutter/material.dart';
import 'package:iuto_mobile/db/data/Restaurants/restaurant.dart';
import 'package:iuto_mobile/db/supabase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RestaurantProvider with ChangeNotifier {
  List<Restaurant> _restaurants = [];
  List<Restaurant> _filteredRestaurants = [];
  Restaurant? _selectedRestaurant;
  List<String> _restoLike = [];
  Map<String, dynamic> _activeFilters = {};
  bool _isLoading = false;
  String? _error;

  List<Restaurant> get restaurants =>
      _filteredRestaurants.isNotEmpty ? _filteredRestaurants : _restaurants;
  List<String> get likedRestaurant => _restoLike;
  Restaurant? get selectedRestaurant => _selectedRestaurant;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadRestaurants() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await SupabaseService.selectRestaurants();
      _restaurants = data;
      _filteredRestaurants = data;
      await _loadLikedRestaurants();
      debugPrint("Restaurants chargés : ${_restaurants.length}");
    } catch (e) {
      _error = "Erreur lors de la récupération des restaurants : $e";
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadRestaurantById(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final restaurant = await SupabaseService.selectRestaurantById(id);
      _selectedRestaurant = restaurant;
      debugPrint("Restaurant chargé : ${restaurant.nom}");
      debugPrint("Restaurant chargéID : ${restaurant.id}");
    } catch (e) {
      _error = "Erreur lors de la récupération du restaurant : $e";
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilters(Map<String, dynamic> filters) {
    _activeFilters = filters;
    filterRestaurants(
      searchQuery: filters['searchQuery'],
      vegetarian: filters['isVegetarian'],
      vegan: filters['isVegan'],
      internetAccess: filters['internetAccess'],
      wheelchair: filters['wheelchair'],
      delivery: filters['delivery'],
      takeaway: filters['takeaway'],
      driveThrough: filters['driveThrough'],
      smoking: filters['smoking'],
    );
  }

  void clearFilters() {
    debugPrint("clearFilters appelé");
    _activeFilters = {};
    _filteredRestaurants = _restaurants;
    notifyListeners();
  }

  Map<String, dynamic> getActiveFilters() {
    return _activeFilters;
  }

  void filterRestaurants({
    String? searchQuery,
    bool? vegetarian,
    bool? vegan,
    bool? internetAccess,
    bool? wheelchair,
    bool? delivery,
    bool? takeaway,
    bool? driveThrough,
    bool? smoking,
  }) {
    _filteredRestaurants = _restaurants.where((restaurant) {
      final matchesSearchQuery = searchQuery == null ||
          searchQuery.isEmpty ||
          restaurant.nom.toLowerCase().contains(searchQuery.toLowerCase());

      final matchesVegetarian =
          vegetarian == null || restaurant.vegetarian == vegetarian;
      final matchesVegan = vegan == null || restaurant.vegan == vegan;
      final matchesInternetAccess =
          internetAccess == null || restaurant.internetAccess == internetAccess;
      final matchesWheelchair =
          wheelchair == null || restaurant.wheelchair == wheelchair;
      final matchesDelivery =
          delivery == null || restaurant.delivery == delivery;
      final matchesTakeaway =
          takeaway == null || restaurant.takeaway == takeaway;
      final matchesDriveThrough =
          driveThrough == null || restaurant.driveThrough == driveThrough;
      final matchesSmoking = smoking == null || restaurant.smoking == smoking;

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

    debugPrint("Restaurants filtrés : ${_filteredRestaurants.length}");
    notifyListeners();
  }

  Future<void> _loadLikedRestaurants() async {
    final prefs = await SharedPreferences.getInstance();
    _restoLike = prefs.getStringList('restoLike') ?? [];
    notifyListeners();
  }

  Future<void> likeRestaurant(int restaurantId) async {
    final prefs = await SharedPreferences.getInstance();
    if (!_restoLike.contains(restaurantId.toString())) {
      _restoLike.add(restaurantId.toString());
      await prefs.setStringList('restoLike', _restoLike);
      notifyListeners();
    }
  }

  Future<void> unlikeRestaurant(int restaurantId) async {
    final prefs = await SharedPreferences.getInstance();
    _restoLike.remove(restaurantId.toString());
    await prefs.setStringList('restoLike', _restoLike);
    notifyListeners();
  }

  Future<bool> isRestaurantLiked(int restaurantId) async {
    return _restoLike.contains(restaurantId.toString());
  }
}
