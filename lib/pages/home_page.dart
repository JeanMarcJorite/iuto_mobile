import 'package:flutter/material.dart';
import 'package:iuto_mobile/providers/favoris_provider.dart';
import 'package:iuto_mobile/widgets/restaurant_card.dart';
import 'package:provider/provider.dart';
import 'package:iuto_mobile/providers/restaurant_provider.dart';

//Description : Affiche une liste de restaurants recommandés en fonction des préférences de l'utilisateur.
//Afficher les restaurants correspondant aux types de cuisine préférés.
//Mettre en avant les restaurants les mieux notés ou les plus proches.
//Inclure une section "Tendances" ou "Nouveaux restaurants".

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RestaurantProvider>(context, listen: false).loadRestaurants();
      Provider.of<FavorisProvider>(context, listen: false).loadAllFavoris();
    });
  }

  @override
  Widget build(BuildContext context) {
    final restaurantProvider = Provider.of<RestaurantProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurants'),
      ),
      body: restaurantProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : restaurantProvider.error != null
              ? Center(child: Text('Erreur : ${restaurantProvider.error}'))
              : restaurantProvider.restaurants.isEmpty
                  ? const Center(child: Text('Aucun restaurant trouvé.'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: restaurantProvider.restaurants.length,
                      itemBuilder: (context, index) {
                        final restaurant =
                            restaurantProvider.restaurants[index];
                        return RestaurantCard(restaurant: restaurant);
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          restaurantProvider.loadRestaurants();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Restaurants rechargés')),
          );
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
