import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iuto_mobile/widgets/like_widget.dart';
import 'package:provider/provider.dart';
import 'package:iuto_mobile/providers/restaurant_provider.dart';
import 'package:iuto_mobile/providers/critique_provider.dart';
import 'package:uuid/uuid.dart';

class RestaurantDetailsPage extends StatefulWidget {
  final int restaurantId;

  const RestaurantDetailsPage({super.key, required this.restaurantId});

  @override
  State<RestaurantDetailsPage> createState() => _RestaurantDetailsPageState();
}

class _RestaurantDetailsPageState extends State<RestaurantDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchRestaurantDetailsAndCritiques();
    });
  }

  Future<void> _fetchRestaurantDetailsAndCritiques() async {
    final restaurantProvider =
        Provider.of<RestaurantProvider>(context, listen: false);
    final critiqueProvider =
        Provider.of<CritiqueProvider>(context, listen: false);

    await restaurantProvider.loadRestaurantById(widget.restaurantId);
    await critiqueProvider.loadCritiquesByRestaurantId(widget.restaurantId);
  }

  @override
  Widget build(BuildContext context) {
    final restaurantProvider = Provider.of<RestaurantProvider>(context);
    final critiqueProvider = Provider.of<CritiqueProvider>(context);

    final restaurant = restaurantProvider.selectedRestaurant;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: restaurantProvider.isLoading || critiqueProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : restaurant == null
              ? const Center(
                  child: Text('Erreur lors du chargement du restaurant.'))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: 300,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: restaurant.photo != null &&
                                        restaurant.photo!.isNotEmpty
                                    ? NetworkImage(restaurant.photo!)
                                    : const AssetImage(
                                            'assets/images/restaurant_defaut_2.jpg')
                                        as ImageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 58.0, left: 18),
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(80),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.arrow_back_outlined),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 58.0, right: 18),
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(80),
                                  ),
                                  child: LikeWidget(
                                    restaurantId: restaurant.id,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          restaurant.nom,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.star, color: Colors.orange),
                            const SizedBox(width: 5),
                            Text(
                              "${critiqueProvider.noteMoyenne} / 5",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 20),
                            const Icon(Icons.comment, color: Colors.blue),
                            const SizedBox(width: 5),
                            Text(
                              "${critiqueProvider.critiques.length} avis",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          final idCritique = const Uuid().v4();
                          context.push(
                              "/details/${widget.restaurantId}/avis/add/${idCritique}");
                        },
                        child: const Text('Ajouter un avis'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          final idCritique = const Uuid().v4();
                          context.push(
                              "/details/photo");
                        },
                        child: const Text('Ajouter une image'),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    "Avis des utilisateurs",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    context.push(
                                      "/details/${widget.restaurantId}/avis",
                                    );
                                  },
                                  child: Text(
                                    "Voir tous",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ...critiqueProvider.critiques.reversed
                                .take(2)
                                .map((critique) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: ListTile(
                                  leading: const Icon(Icons.person),
                                  title: Text(critique.commentaire),
                                  subtitle: Text(
                                    "Note : ${critique.note} / 5",
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
