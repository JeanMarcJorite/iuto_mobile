import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iuto_mobile/providers/favoris_provider.dart';
import 'package:iuto_mobile/providers/image_provider.dart';
import 'package:iuto_mobile/providers/restaurant_provider.dart';
import 'package:iuto_mobile/providers/critique_provider.dart';
import 'package:iuto_mobile/widgets/like_widget.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class RestaurantDetailsPage extends StatefulWidget {
  final int restaurantId;
  final String? previousPage;

  const RestaurantDetailsPage({
    super.key,
    required this.restaurantId,
    this.previousPage,
  });

  @override
  State<RestaurantDetailsPage> createState() => _RestaurantDetailsPageState();
}

class _RestaurantDetailsPageState extends State<RestaurantDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchRestaurantCritiques();
      _fetchRestaurantImages();
      _fetchRestaurantDetails();
    });
  }

  /// Récupère les détails d'un restaurant spécifique
  Future<void> _fetchRestaurantDetails() async {
    final restaurantProvider =
        Provider.of<RestaurantProvider>(context, listen: false);
    await restaurantProvider.loadRestaurantById(widget.restaurantId);
  }

  /// Récupère les critiques pour un restaurant spécifique
  Future<void> _fetchRestaurantCritiques() async {
    final critiqueProvider =
        Provider.of<CritiqueProvider>(context, listen: false);
    await critiqueProvider.loadCritiquesByRestaurantId(widget.restaurantId);
  }

  /// Récupère les images pour un restaurant spécifique
  Future<void> _fetchRestaurantImages() async {
    try {
      final imagesProvider =
          Provider.of<ImagesProvider>(context, listen: false);
      await imagesProvider
          .fetchImagesByRestaurantId(widget.restaurantId.toString());
    } catch (e) {
      print('Erreur lors de la récupération des images : $e');
    }
  }

  void _showFullImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.7,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Colors.grey,
                    );
                  },
                ),
              ),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Fermer'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final restaurantProvider = Provider.of<RestaurantProvider>(context);
    final critiqueProvider = Provider.of<CritiqueProvider>(context);
    final imagesProvider = Provider.of<ImagesProvider>(context);

    final favorisProvider = Provider.of<FavorisProvider>(context);
    final totalFavoris = favorisProvider.allFavoris
        .where((favori) => favori.idRestaurant == widget.restaurantId)
        .length;

    final restaurant = restaurantProvider.selectedRestaurant;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: restaurantProvider.isLoading ||
              critiqueProvider.isLoading ||
              imagesProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : restaurant == null
              ? const Center(
                  child: Text('Erreur lors du chargement du restaurant.'))
              : SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              height: 300,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: const AssetImage(
                                        'assets/images/restaurant_defaut_2.jpg')),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 58.0, left: 18),
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(80),
                                    ),
                                    child: IconButton(
                                      icon:
                                          const Icon(Icons.arrow_back_outlined),
                                      onPressed: () {
                                        if (widget.previousPage == 'map') {
                                          context.go('/home');
                                        } else {
                                          context.pop();
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 58.0, right: 18),
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(80),
                                    ),
                                    child: LikeWidget(
                                      restaurantId: restaurant.id,
                                      showCount: false,
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
                                "${critiqueProvider.noteMoyenne.toStringAsFixed(2)} / 5",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 20),
                              const Icon(Icons.comment, color: Colors.blue),
                              const SizedBox(width: 5),
                              Text(
                                "${critiqueProvider.critiques.length} avis",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 20),
                              const Icon(Icons.favorite_rounded,
                                  color: Colors.red),
                              const SizedBox(width: 5),
                              Text(
                                "$totalFavoris",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
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
                            context
                                .push("/details/${widget.restaurantId}/photo");
                          },
                          child: const Text('Ajouter une image'),
                        ),
                        const SizedBox(height: 20),
                        imagesProvider.imageUrls.isEmpty
                            ? const Center(
                                child: Text('Aucune image disponible.'),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SizedBox(
                                  height: 200, // Adjust height as needed
                                  child: GridView.builder(
                                    scrollDirection: Axis.horizontal,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 4.0,
                                      mainAxisSpacing: 4.0,
                                      childAspectRatio: 1,
                                    ),
                                    itemCount: imagesProvider.imageUrls.length,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          _showFullImage(
                                            imagesProvider.imageUrls[index],
                                          );
                                        },
                                        child: Image.network(
                                          imagesProvider.imageUrls[index],
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.broken_image,
                                              size: 50,
                                              color: Colors.grey,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
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
                                      style:
                                          const TextStyle(color: Colors.grey),
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
                ),
    );
  }
}
