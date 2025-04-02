import 'package:flutter/material.dart';
import '../db/data/Users/src/models/restaurant.dart';
import '../db/supabase_service.dart';

class RestaurantProvider with ChangeNotifier {
  List<Restaurant> _restaurants = [];
  List<Restaurant> _filteredRestaurants = [];
  bool _isLoading = false;
  String? _error;

  List<Restaurant> get restaurants => _filteredRestaurants;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadRestaurants() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await SupabaseService.fetchRestaurants();
      print('Données récupérées de Supabase : $data'); // Ajoute ce log
      _restaurants = data.map((json) => Restaurant.fromMap(json)).toList();
      _filteredRestaurants = _restaurants;
      _error = null;
    } catch (e) {
      _error = 'Failed to load restaurants: ${e.toString()}';
      print('Erreur lors du chargement : $_error'); // Ajoute ce log
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterRestaurants({
    String? searchQuery,
    String? cuisineType,
    String? restaurantType,
    bool? internetAccess,
    bool? wheelchair,
    bool? vegetarian,
    bool? vegan,
    bool? delivery,
    bool? takeaway,
    bool? driveThrough,
    bool? smoking,
  }) {
    _filteredRestaurants = _restaurants.where((restaurant) {
      bool matches = true;

      if (searchQuery != null && searchQuery.isNotEmpty) {
        matches = matches &&
            (restaurant.nom.toLowerCase().contains(searchQuery.toLowerCase()) ||
                restaurant.adresse
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()));
      }

      // Ajoutez les autres filtres ici...

      return matches;
    }).toList();

    notifyListeners();
  }
}
