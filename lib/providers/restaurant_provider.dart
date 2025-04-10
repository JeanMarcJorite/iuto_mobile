import 'package:flutter/material.dart';
import 'package:iuto_mobile/db/models/restaurant.dart';
import 'package:iuto_mobile/db/supabase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RestaurantProvider with ChangeNotifier {
  List<Restaurant> _allRestaurants = [];
  List<Restaurant> _filteredRestaurants = [];
  List<Restaurant> _restaurantsPreferences = [];
  Restaurant? _selectedRestaurant;
  List<String> _restoLike = [];
  Map<String, dynamic> _activeFilters = {};
  bool _isLoading = false;
  String? _error;

  List<Restaurant> get restaurants =>
      _filteredRestaurants.isNotEmpty ? _filteredRestaurants : _allRestaurants;

  List<Restaurant> get allRestaurants => _allRestaurants;

  List<Restaurant> get restaurantsPreferences => _restaurantsPreferences;

  List<String> get likedRestaurant => _restoLike;
  Restaurant? get selectedRestaurant => _selectedRestaurant;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Map<String, dynamic> get activeFilters => Map.from(_activeFilters);

  bool get hasActiveFilters => _activeFilters.entries
      .where((entry) => entry.key != 'searchQuery')
      .any((entry) => entry.value == true) || 
      (_activeFilters['searchQuery'] != null && _activeFilters['searchQuery'].toString().isNotEmpty);
  
  bool get hasNoResults => hasActiveFilters && _filteredRestaurants.isEmpty;

  Future<void> loadRestaurants() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await SupabaseService.selectRestaurants();
      _allRestaurants = data;
      _filteredRestaurants = [];
      _activeFilters = {};
    } catch (e) {
      _error = 'Erreur lors de la récupération des restaurants : $e';
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
    } catch (e) {
      _error = "Erreur lors de la récupération du restaurant : $e";
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadRestaurantsByPreferences(List<int> preferredCuisineIds) async {
    _isLoading = true;

    try {
      final proposes = await SupabaseService.selectProposeByCuisineIds(preferredCuisineIds);

      final restaurantIds = proposes.map((propose) => propose.idRestaurant).toSet();

      _restaurantsPreferences = _allRestaurants
          .where((restaurant) => restaurantIds.contains(restaurant.id))
          .toList();

      debugPrint(
          "${_restaurantsPreferences.length} restaurants trouvés selon les préférences.");
    } catch (e) {
      _error = 'Erreur lors de la récupération des restaurants par préférences : $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilters(Map<String, dynamic> filters) {
    bool hasChanged = false;
    filters.forEach((key, value) {
      if (_activeFilters[key] != value) {
        hasChanged = true;
      }
    });

    if (hasChanged) {
      _activeFilters = Map.from(filters);
      _applyFilters();
    }
  }

  void clearFilters() {
    debugPrint("Suppression des filtres");
    _activeFilters = {}; 
    _filteredRestaurants = []; 
    notifyListeners();
  }

  void _applyFilters() {
    bool hasActiveFiltersLocal = _activeFilters.entries
        .where((entry) => entry.key != 'searchQuery')
        .any((entry) => entry.value == true);

    if (!hasActiveFiltersLocal &&
        (_activeFilters['searchQuery'] == null ||
            _activeFilters['searchQuery'].isEmpty)) {
      _filteredRestaurants = []; 
      debugPrint("Aucun filtre actif, affichage de tous les restaurants");
      notifyListeners();
      return;
    }

    debugPrint("Application des filtres: $_activeFilters");
    _filteredRestaurants = _allRestaurants.where((restaurant) {
      if (_activeFilters['searchQuery'] != null &&
          _activeFilters['searchQuery'].isNotEmpty) {
        if (!restaurant.nom
            .toLowerCase()
            .contains(_activeFilters['searchQuery'].toLowerCase())) {
          return false;
        }
      }

      if (_activeFilters['isVegetarian'] == true && !restaurant.vegetarian) {
        return false;
      }
      if (_activeFilters['isVegan'] == true && !restaurant.vegan) {
        return false;
      }
      if (_activeFilters['internetAccess'] == true &&
          !restaurant.internetAccess) {
        return false;
      }
      if (_activeFilters['wheelchair'] == true && !restaurant.wheelchair) {
        return false;
      }
      if (_activeFilters['delivery'] == true && !restaurant.delivery) {
        return false;
      }
      if (_activeFilters['takeaway'] == true && !restaurant.takeaway) {
        return false;
      }
      if (_activeFilters['driveThrough'] == true && !restaurant.driveThrough) {
        return false;
      }
      if (_activeFilters['smoking'] == true && !restaurant.smoking) {
        return false;
      }

      return true;
    }).toList();

    debugPrint(
        "${_filteredRestaurants.length} restaurants après filtrage sur ${_allRestaurants.length} restaurants total");
    
    if (_filteredRestaurants.isEmpty) {
      debugPrint("ATTENTION: Aucun restaurant ne correspond aux filtres actifs!");
    }
    
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

  void updateRestaurants(List<Restaurant> updatedRestaurants) {
    _allRestaurants = updatedRestaurants;
    _applyFilters();
    notifyListeners();
  }

  void updateRestaurant(Restaurant restaurant) {
    final index = _allRestaurants.indexWhere((r) => r.id == restaurant.id);
    if (index != -1) {
      _allRestaurants[index] = restaurant;
      _applyFilters();
      notifyListeners();
    }
  }
}