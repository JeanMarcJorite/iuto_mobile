import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:iuto_mobile/db/models/restaurant.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:iuto_mobile/providers/restaurant_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:iuto_mobile/providers/geolocalisation_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  LatLng? _currentPosition;
  bool _isLoadingLocation = true;
  bool _locationEnabled = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLocationSettings();
    });
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
        _mapController.move(_currentPosition!, 15);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final restaurantProvider = Provider.of<RestaurantProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carte des Restaurants'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(47.902964, 1.909251),
              initialZoom: 13.0,
              onTap: (_, __) => FocusManager.instance.primaryFocus?.unfocus(),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.iuto_mobile',
              ),
              if (_currentPosition != null && _locationEnabled)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentPosition!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              MarkerLayer(
                markers: restaurantProvider.restaurants.map((restaurant) {
                  return Marker(
                    point: LatLng(restaurant.latitude, restaurant.longitude),
                    width: 120,
                    height: 120,
                    child: GestureDetector(
                      onTap: () => _showRestaurantInfo(restaurant, context),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 4,
                                  color: Colors.black.withOpacity(0.2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.restaurant,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 2,
                                  color: Colors.black.withOpacity(0.1),
                                ),
                              ],
                            ),
                            child: Text(
                              restaurant.nom,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          if (restaurantProvider.isLoading || _isLoadingLocation)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
      floatingActionButton: _locationEnabled
          ? FloatingActionButton(
              onPressed: () => _mapController.move(
                _currentPosition ?? const LatLng(47.902964, 1.909251),
                15,
              ),
              child: const Icon(Icons.center_focus_strong),
            )
          : null,
    );
  }

  void _showRestaurantInfo(Restaurant restaurant, BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              restaurant.nom,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(restaurant.adresse),
            if (_locationEnabled && restaurant.distance != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '${restaurant.distance!.toStringAsFixed(1)} km',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.pop();
                  context.push(
                    '/details/${restaurant.id}',
                    extra: {'previousPage': 'map'},
                  );
                },
                child: const Text('Voir les détails'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
