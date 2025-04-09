import 'package:flutter/material.dart';
import 'package:iuto_mobile/services/auth_services.dart';
import 'package:provider/provider.dart';
import 'package:iuto_mobile/providers/favoris_provider.dart';
import 'package:iuto_mobile/db/models/favoris.dart';

class LikeWidget extends StatefulWidget {
  final int restaurantId;
  final bool showCount;

  const LikeWidget(
      {super.key, required this.restaurantId, this.showCount = true});

  @override
  State<LikeWidget> createState() => _LikeWidgetState();
}

class _LikeWidgetState extends State<LikeWidget> {
  final AuthServices _authServices = AuthServices();
  String? userId;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    final userStream = _authServices.user;
    final user = await userStream.first;

    if (mounted) {
      setState(() {
        userId = user?.id;
      });
    }

    if (userId != null) {
      final favorisProvider =
          Provider.of<FavorisProvider>(context, listen: false);
      await favorisProvider.loadFavorisbyUser(userId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavorisProvider>(
      builder: (context, favorisProvider, child) {
        final isLiked = favorisProvider.isFavorited(widget.restaurantId);
        final totalLikes =
            favorisProvider.getTotalFavorisCount(widget.restaurantId);

        return Row(
          children: [
            if (widget.showCount) ...[
              Text(
                '$totalLikes',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
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
                      (favori) => favori.idRestaurant == widget.restaurantId,
                    );
                    debugPrint('Favori à retirer : ${favoriToRemove.toMap()}');
                    await favorisProvider.removeFavoris(favoriToRemove.id!);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Retiré des favoris !'),
                        backgroundColor: Colors.redAccent,
                        duration: Duration(seconds: 1),
                      ),
                    );
                  } else {
                    final lastFavorisId =
                        await favorisProvider.getLastFavorisId();

                    final newFavori = Favoris(
                      id: lastFavorisId + 1,
                      idUtilisateur: userId!,
                      idRestaurant: widget.restaurantId,
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
  }

}
