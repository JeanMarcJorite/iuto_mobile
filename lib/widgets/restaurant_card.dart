import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iuto_mobile/db/data/Restaurants/restaurant.dart';
import 'package:iuto_mobile/widgets/like_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final bool showDistance;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    this.showDistance = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push("/details/${restaurant.id}"),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRestaurantImage(),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom et like
                  Row(
                    children: [
                      Expanded(child: _buildRestaurantName()),
                      const SizedBox(width: 8),
                      LikeWidget(restaurantId: restaurant.id),
                    ],
                  ),

                  const SizedBox(height: 8),

                  _buildRestaurantAttributs(),

                  if (showDistance)
                    FutureBuilder<Widget>(
                      future: _buildDistanceInfo(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData) {
                          return snapshot.data!;
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: AspectRatio(
        aspectRatio: 16 / 9,

        child: CachedNetworkImage(
          imageUrl: restaurant.photo!,

          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Image.asset(
            'assets/images/lounge.jpg',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildRestaurantName() {
    return Text(
      restaurant.nom,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildRestaurantAttributs() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        if (restaurant.stars != null)
          _buildAttributeChip(
            '${restaurant.stars!.toStringAsFixed(1)}/5',
            Icons.star,
            Colors.amber,
          ),
        if (restaurant.internetAccess)
          _buildAttributeIcon(Icons.wifi, 'Wi-Fi disponible'),
        if (restaurant.wheelchair)
          _buildAttributeIcon(Icons.accessible, 'Accessible PMR'),
        if (restaurant.vegetarian || restaurant.vegan)
          _buildAttributeIcon(
            restaurant.vegan ? Icons.eco : Icons.restaurant,
            restaurant.vegan ? 'Vegan' : 'Végétarien',
          ),
        if (restaurant.delivery)
          _buildAttributeIcon(Icons.delivery_dining, 'Livraison'),
        if (restaurant.takeaway)
          _buildAttributeIcon(Icons.takeout_dining, 'À emporter'),
      ],
    );
  }

  Widget _buildAttributeIcon(IconData icon, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Icon(icon, size: 18, color: Colors.blue.shade700),
    );
  }

  Widget _buildAttributeChip(String text, IconData icon, Color color) {
    return Chip(
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
      backgroundColor: color.withOpacity(0.2),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: color)),
        ],
      ),
    );
  }

  Future<Widget> _buildDistanceInfo() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('localisation') == false) {
      return const SizedBox.shrink();
    }
    if (restaurant.distance == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          const Icon(Icons.location_on, size: 16, color: Colors.grey),
          const SizedBox(width: 4),
          Text(
            restaurant.distance != null
                ? '${restaurant.distance!.toStringAsFixed(1)} km'
                : 'Distance non disponible',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
