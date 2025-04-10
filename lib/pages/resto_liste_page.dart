import 'package:flutter/material.dart';
import 'package:iuto_mobile/db/models/restaurant.dart';
import 'package:iuto_mobile/widgets/restaurant_card.dart';

class RestaurantListPage extends StatelessWidget {
  final String title;
  final List<Restaurant> restaurants;

  const RestaurantListPage({
    super.key,
    required this.title,
    required this.restaurants,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: restaurants.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: RestaurantCard(restaurant: restaurants[index]),
          );
        },
      ),
    );
  }
}
