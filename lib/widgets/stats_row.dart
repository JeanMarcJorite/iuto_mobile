import 'package:flutter/material.dart';

class StatsRow extends StatelessWidget {
  final double averageRating;
  final int reviewsCount;
  final int favoritesCount;

  const StatsRow({
    super.key,
    required this.averageRating,
    required this.reviewsCount,
    required this.favoritesCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            Icons.star,
            Colors.orange,
            "${averageRating.toStringAsFixed(1)}/5",
          ),
          _buildStatItem(
            Icons.comment,
            Colors.blue,
            "$reviewsCount avis",
          ),
          _buildStatItem(
            Icons.favorite,
            Colors.red,
            "$favoritesCount",
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, Color color, String text) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}