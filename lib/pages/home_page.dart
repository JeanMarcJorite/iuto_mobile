import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iuto_mobile/providers/restaurant_provider.dart';
import 'package:iuto_mobile/widgets/restaurant_card.dart';

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
    });
  }

  @override
  Widget build(BuildContext context) {
    final restaurantProvider = Provider.of<RestaurantProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('IUTables’O'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bienvenue sur la page d\'accueil',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Bienvenue sur notre plateforme de comparateur de restaurants en ligne. Vous pouvez comparer les restaurants de la région Orléanaise.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              const Text(
                'Les meilleurs restaurants',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              restaurantProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : restaurantProvider.restaurants.isEmpty
                      ? const Text('Aucun restaurant trouvé avec plus d\'une étoile.')
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: restaurantProvider.restaurants.length,
                          itemBuilder: (context, index) {
                            final restaurant = restaurantProvider.restaurants[index];
                            if (restaurant.stars != null && restaurant.stars! > 1) {
                              return RestaurantCard(restaurant: restaurant);
                            }
                            return const SizedBox.shrink();
                          },
                        ),
            ],
          ),
        ),
      ),
    );
  }
}