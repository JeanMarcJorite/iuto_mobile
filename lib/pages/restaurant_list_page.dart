import 'package:flutter/material.dart';
import '../db/restaurant_service.dart';
import '../db/restaurant_model.dart';

class RestaurantListPage extends StatelessWidget {
  final RestaurantService _service = RestaurantService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurants'),
      ),
      body: FutureBuilder<List<Restaurant>>(
        future: _service.fetchRestaurants(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun restaurant trouvé.'));
          }

          final restaurants = snapshot.data!;
          return ListView.builder(
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              final restaurant = restaurants[index];
              return ListTile(
                leading: restaurant.imageUrl.isNotEmpty
                    ? Image.network(restaurant.imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                    : const Icon(Icons.restaurant),
                title: Text(restaurant.name),
                subtitle: Text(restaurant.description),
              );
            },
          );
        },
      ),
    );
  }
}