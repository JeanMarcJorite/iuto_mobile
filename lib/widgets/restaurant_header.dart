import 'package:flutter/material.dart';
import 'package:iuto_mobile/db/models/restaurant.dart';

class RestaurantHeader extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantHeader({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                restaurant.nom,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (restaurant.stars != null) ...[
              const Icon(Icons.star, color: Colors.amber, size: 16),
              Text(
                restaurant.stars!.toStringAsFixed(1),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        _buildRestaurantIcons(restaurant),
        if (restaurant.distance != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${restaurant.distance!.toStringAsFixed(1)} km',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildRestaurantIcons(Restaurant restaurant) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: [
        if (restaurant.internetAccess)
          const Tooltip(
            message: 'Wi-Fi disponible',
            child: Icon(Icons.wifi, size: 16, color: Colors.blue),
          ),
        if (restaurant.wheelchair)
          const Tooltip(
            message: 'Accessible PMR',
            child: Icon(Icons.accessible, size: 16, color: Colors.green),
          ),
        if (restaurant.vegetarian)
          const Tooltip(
            message: 'Options végétariennes',
            child: Icon(Icons.eco, size: 16, color: Colors.lightGreen),
          ),
        if (restaurant.vegan)
          const Tooltip(
            message: 'Options véganes',
            child: Icon(Icons.clear, size: 16, color: Colors.green),
          ),
        if (restaurant.delivery)
          const Tooltip(
            message: 'Livraison disponible',
            child: Icon(Icons.delivery_dining, size: 16, color: Colors.red),
          ),
        if (restaurant.takeaway)
          const Tooltip(
            message: 'À emporter',
            child: Icon(Icons.takeout_dining, size: 16, color: Colors.orange),
          ),
        if (restaurant.smoking)
          const Tooltip(
            message: 'Espace fumeur',
            child: Icon(Icons.smoking_rooms, size: 16, color: Colors.grey),
          ),
      ],
    );
  }
}