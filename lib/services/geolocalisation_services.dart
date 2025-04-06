import 'package:geolocator/geolocator.dart';

class GeolocalisationServices {
  late LocationSettings locationSettings;

  GeolocalisationServices() {
    locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );
  }

  Future<Position?> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        locationSettings: locationSettings,
      );
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  Future<double?> distanceBetween(double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) async {
    try {
      return await Geolocator.distanceBetween(
          startLatitude, startLongitude, endLatitude, endLongitude);
    } catch (e) {
      print('Error calculating distance: $e');
      return null;
    }
  }

  Stream<Position> getRealTimeLocation() {
    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }
}
