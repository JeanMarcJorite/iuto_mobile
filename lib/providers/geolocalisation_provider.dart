import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iuto_mobile/services/geolocalisation_services.dart';

class GeolocalisationProvider with ChangeNotifier {
  final GeolocalisationServices _geoService = GeolocalisationServices();
  Position? _currentPosition;
  bool _isLoading = false;
  StreamSubscription<Position>? _positionStreamSubscription;

  final StreamController<Position> _positionStreamController =
      StreamController<Position>.broadcast();

  Stream<Position> get positionStream => _positionStreamController.stream;

  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;

  Future<void> loadCurrentPosition() async {
    _isLoading = true;
    notifyListeners();

    try {
      final position = await _geoService.getCurrentLocation();
      if (position != null) {
        _currentPosition = position;
        _positionStreamController.add(position);
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération de la position : $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void startRealTimeLocation() {
    if (_positionStreamSubscription != null) {
      debugPrint('Service de localisation déjà actif.');
      return;
    }

    debugPrint('Démarrage du service de localisation...');
    _positionStreamSubscription =
        _geoService.getRealTimeLocation().listen((Position position) {
      _currentPosition = position;
      _positionStreamController.add(position);
      notifyListeners();
    });
  }

  void stopRealTimeLocation() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  Future<double?> calculerDistance(double latitude, double longitude) async {
    if (_currentPosition == null) {
      return null;
    }

    final distance = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      latitude,
      longitude,
    );

    return distance;
  }
}
