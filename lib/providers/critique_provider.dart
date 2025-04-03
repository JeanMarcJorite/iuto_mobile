import 'package:flutter/material.dart';
import 'package:iuto_mobile/db/data/Critiques/critique.dart';
import 'package:iuto_mobile/db/supabase_service.dart';

class CritiqueProvider with ChangeNotifier {
  List<Critique> _critiques = [];
  bool _isLoading = false;
  String? _error;

  List<Critique> get critiques => _critiques;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCritiquesByRestaurantId(int restaurantId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _critiques =
          await SupabaseService.selectCritiquesByRestaurantId(restaurantId);
    } catch (e) {
      debugPrint('Erreur lors du chargement des critiques : $e');
      _critiques = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCritique(Critique critique) async {
    try {
      await SupabaseService.insertCritique(critique.toMap());
      _critiques.add(critique);
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de l\'ajout de la critique : $e';
      debugPrint(_error);
    }
  }

  void clearCritiques() {
    _critiques = [];
    _error = null;
    notifyListeners();
  }

  double get noteMoyenne {
    if (_critiques.isEmpty) {
      return 0.0;
    }
    double totalNote = _critiques.map((critique) => critique.note.toDouble()).reduce((a, b) => a + b);
    return totalNote / _critiques.length;
  }
}
