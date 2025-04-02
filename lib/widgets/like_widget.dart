import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iuto_mobile/providers/restaurant_provider.dart';

class LikeWidget extends StatelessWidget {
  final int restaurantId;

  const LikeWidget({super.key, required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    final restaurantProvider = Provider.of<RestaurantProvider>(context);

    final isLiked =
        restaurantProvider.likedRestaurant.contains(restaurantId.toString());

    return IconButton(
      icon: Icon(
        isLiked ? Icons.favorite : Icons.favorite_border,
        color: isLiked ? Colors.red : Colors.grey,
      ),
      onPressed: () async {
        if (isLiked) {
          await restaurantProvider.unlikeRestaurant(restaurantId);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Retiré des favoris !'),
              backgroundColor: Colors.redAccent,
              duration: Duration(seconds: 1),
            ),
          );
        } else {
          await restaurantProvider.likeRestaurant(restaurantId);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ajouté aux favoris !'),
              backgroundColor: Colors.blueAccent,
              duration: Duration(seconds: 1),
            ),
          );
        }
      },
    );
  }
}
