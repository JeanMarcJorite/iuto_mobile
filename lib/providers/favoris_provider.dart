import 'package:flutter/material.dart';
import 'package:iuto_mobile/db/data/Favoris/favoris.dart';
import 'package:iuto_mobile/db/supabase_service.dart';

class FavorisProvider extends ChangeNotifier {
  List<Favoris> _favoris = [];
  List<Favoris> _allFavoris = [];
  bool _isLoading = false;

  List<Favoris> get favoris => _favoris;
  List<Favoris> get allFavoris => _allFavoris;
  bool get isLoading => _isLoading;

  Future<void> loadAllFavoris() async {
    _isLoading = true;

    try {
      _allFavoris = await SupabaseService.selectFavoris();
    } catch (e) {
      debugPrint('Erreur lors du chargement de tous les favoris : $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  int getTotalFavorisCount(int restaurantId) {
    return _allFavoris
        .where((favori) => favori.idRestaurant == restaurantId)
        .length;
  }

  Future<void> loadFavorisbyUser(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _favoris = await SupabaseService.selectFavorisByUserId(userId);
    } catch (e) {
      debugPrint('Erreur lors du chargement des favoris : $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addFavoris(Favoris favori) async {
    try {
      await SupabaseService.insertFavoris(favori.toMap());
      _favoris.add(favori);
      _allFavoris.add(favori);
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors de l\'ajout d\'un favori : $e');
    }
    
  }

  Future<void> removeFavoris(int favoriId) async {
    try {
      await SupabaseService.deleteFavoris(favoriId);
      _favoris.removeWhere((favori) => favori.id == favoriId);
      _allFavoris.removeWhere((favori) => favori.id == favoriId);
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors de la suppression d\'un favori : $e');
    }
  }

  bool isFavorited(int restaurantId) {
    return _favoris.any((favori) => favori.idRestaurant == restaurantId);
  }

  Future<int> getLastFavorisId() async {
    try {
      return SupabaseService.getLastFavorisId().then((value) {
        return value;
      });
    } catch (e) {
      throw Exception(
          'Erreur lors de la récupération du dernier ID de favoris : $e');
    }
  }
}
