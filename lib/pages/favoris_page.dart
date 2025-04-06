import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iuto_mobile/providers/favoris_provider.dart';
import 'package:iuto_mobile/providers/restaurant_provider.dart';
import 'package:iuto_mobile/widgets/restaurant_card.dart';

class FavorisPage extends StatefulWidget {
  const FavorisPage({Key? key}) : super(key: key);

  @override
  State<FavorisPage> createState() => _FavorisPageState();
}

class _FavorisPageState extends State<FavorisPage> {
  @override
  Widget build(BuildContext context) {
    final favorisProvider = Provider.of<FavorisProvider>(context);
    final restaurantProvider = Provider.of<RestaurantProvider>(context);

    final likedRestaurants =
        restaurantProvider.allRestaurants.where((restaurant) {
      return favorisProvider.favoris
          .any((favori) => favori.idRestaurant == restaurant.id);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoris'),
      ),
      body: likedRestaurants.isEmpty
          ? const Center(
              child: Text(
                'Vous n\'avez pas encore de favoris.',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: likedRestaurants.length,
              itemBuilder: (context, index) {
                final restaurant = likedRestaurants[index];
                return RestaurantCard(
                  restaurant: restaurant,
                );
              },
            ),
    );
  }
}
