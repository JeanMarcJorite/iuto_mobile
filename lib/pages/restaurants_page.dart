import 'package:flutter/material.dart';
import 'package:iuto_mobile/db/data/Restaurants/restaurant.dart';
import 'package:provider/provider.dart';
import 'package:iuto_mobile/providers/restaurant_provider.dart';
import 'package:iuto_mobile/widgets/restaurant_card.dart';
import '../widgets/filters_widgets.dart';

class RestaurantsPage extends StatefulWidget {
  const RestaurantsPage({super.key});

  @override
  State<RestaurantsPage> createState() => _RestaurantsPageState();
}

class _RestaurantsPageState extends State<RestaurantsPage> {
  final TextEditingController _searchController = TextEditingController();

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
        title: const Text('Rechercher un restaurant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => FiltersWidget(
                  onApplyFilters: (filters) {
                    restaurantProvider.setFilters(filters);
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: restaurantProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : restaurantProvider.restaurants.isEmpty
              ? const Center(child: Text('Aucun restaurant trouvé.'))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Rechercher un restaurant...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: (value) {
                          restaurantProvider.filterRestaurants(
                              searchQuery: value);
                        },
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: restaurantProvider.restaurants.length,
                        itemBuilder: (context, index) {
                          final restaurant =
                              restaurantProvider.restaurants[index];
                          return RestaurantCard(restaurant: restaurant);
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}