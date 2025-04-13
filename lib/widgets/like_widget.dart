import 'package:flutter/material.dart';
import 'package:iuto_mobile/services/auth_services.dart';
import 'package:provider/provider.dart';
import 'package:iuto_mobile/providers/favoris_provider.dart';
import 'package:iuto_mobile/db/models/favoris.dart';
import 'package:iuto_mobile/db/models/Users/src/models/user_repo.dart';

class LikeWidget extends StatelessWidget {
  final int restaurantId;
  final bool showCount;

  const LikeWidget({
    super.key,
    required this.restaurantId,
    this.showCount = true,
  });

  @override
  Widget build(BuildContext context) {
    final authServices = AuthServices();

    return StreamBuilder<MyUser?>(
      stream: authServices.user,
      builder: (context, snapshot) {
        // Cas 1 : En attente de connexion au stream
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Cas 2 : Erreur dans le stream
        if (snapshot.hasError) {
          debugPrint('Erreur dans le stream : ${snapshot.error}');
          return Row(
            children: [
              if (showCount) ...[
                const Text(
                  '0',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
              IconButton(
                icon: const Icon(Icons.favorite_border, color: Colors.grey),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Erreur lors de la récupération de l\'utilisateur.'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          );
        }

        // Récupérer l'utilisateur et son ID
        final user = snapshot.data;
        final userId = user?.id;
        debugPrint('ID de l\'utilisateur : $userId');

        // Cas 3 : Aucun utilisateur connecté
        if (userId == null) {
          return Row(
            children: [
              if (showCount) ...[
                const Text(
                  '0',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
              IconButton(
                icon: const Icon(Icons.favorite_border, color: Colors.grey),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Veuillez vous connecter pour ajouter un favori.'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          );
        }

        // Cas 4 : Utilisateur connecté, charger les favoris
        return Consumer<FavorisProvider>(
          builder: (context, favorisProvider, child) {
            // Charger les favoris si ce n'est pas déjà fait
            favorisProvider.loadFavorisbyUser(userId);

            final isLiked = favorisProvider.isFavorited(restaurantId);
            final totalLikes = favorisProvider.getTotalFavorisCount(restaurantId);

            return Row(
              children: [
                if (showCount) ...[
                  Text(
                    '$totalLikes',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.grey,
                  ),
                  onPressed: () async {
                    try {
                      if (isLiked) {
                        final favoriToRemove = favorisProvider.favoris.firstWhere(
                          (favori) => favori.idRestaurant == restaurantId,
                        );
                        await favorisProvider.removeFavoris(favoriToRemove.id!);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Retiré des favoris !'),
                            backgroundColor: Colors.redAccent,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      } else {
                        final lastFavorisId = await favorisProvider.getLastFavorisId() ?? 0;
                        final newFavori = Favoris(
                          id: lastFavorisId + 1,
                          idUtilisateur: userId,
                          idRestaurant: restaurantId,
                          dateAjout: DateTime.now(),
                        );
                        await favorisProvider.addFavoris(newFavori);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Ajouté aux favoris !'),
                            backgroundColor: Colors.blueAccent,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                    } catch (e) {
                      debugPrint('Erreur lors de la gestion des favoris : $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Une erreur est survenue.'),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 1),
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}