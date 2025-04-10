import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iuto_mobile/db/models/restaurant.dart';
import 'package:iuto_mobile/widgets/like_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final bool showDistance;
  final VoidCallback? onTap;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    this.showDistance = true,
    this.onTap,
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
        onTap: onTap ?? () => context.push("/details/${restaurant.id}"),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: 0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildImageSection(),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderRow(),
                      _buildAttributesRow(),
                      _buildOpeningHoursRow(),
                      if (showDistance) _buildDistanceInfoFuture(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: CachedNetworkImage(
          imageUrl: restaurant.photo ?? '',
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildPlaceholder(),
          errorWidget: (context, url, error) => _buildErrorWidget(),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorWidget() {
    return Image.asset(
      'assets/images/lounge.jpg',
      
      fit: BoxFit.cover,
    );
  }


  Widget _buildHeaderRow() {
    return Row(
      children: [
        Expanded(child: _buildRestaurantName()),
        const SizedBox(width: 8),
        LikeWidget(restaurantId: restaurant.id),
      ],
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

  Widget _buildAttributesRow() {
    final attributes = <Widget>[];

    if (restaurant.stars != null) {
      attributes.add(
        _buildRatingChip(restaurant.stars!),
      );
    }

    if (restaurant.internetAccess) {
      attributes.add(
        _buildAttributeIcon(Icons.wifi, 'Wi-Fi disponible'),
      );
    }

    if (restaurant.wheelchair) {
      attributes.add(
        _buildAttributeIcon(Icons.accessible, 'Accessible PMR'),
      );
    }

    if (restaurant.vegetarian || restaurant.vegan) {
      attributes.add(
        _buildAttributeIcon(
          restaurant.vegan ? Icons.eco : Icons.restaurant,
          restaurant.vegan ? 'Vegan' : 'Végétarien',
        ),
      );
    }

    if (restaurant.delivery) {
      attributes.add(
        _buildAttributeIcon(Icons.delivery_dining, 'Livraison'),
      );
    }

    if (restaurant.takeaway) {
      attributes.add(
        _buildAttributeIcon(Icons.takeout_dining, 'À emporter'),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: attributes,
    );
  }

  Widget _buildRatingChip(double rating) {
    return Chip(
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
      backgroundColor: Colors.amber.withOpacity(0.2),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 16, color: Colors.amber),
          const SizedBox(width: 4),
          Text(
            '${rating.toStringAsFixed(1)}',
            style: const TextStyle(color: Colors.amber),
          ),
        ],
      ),
    );
  }

  Widget _buildAttributeIcon(IconData icon, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Icon(
        icon,
        size: 18,
        color: Colors.blue.shade700,
      ),
    );
  }

  Widget _buildOpeningHoursRow() {
    return Row(
      children: [
        const Icon(Icons.schedule, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          restaurant.openingHours?.isNotEmpty == true
              ? restaurant.openingHours!
              : 'Horaires non disponibles',
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildDistanceInfoFuture() {
    return FutureBuilder<Widget>(
      future: _buildDistanceInfo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return snapshot.data!;
        }
        return const SizedBox.shrink();
      },
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
            '${restaurant.distance!.toStringAsFixed(1)} km',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
