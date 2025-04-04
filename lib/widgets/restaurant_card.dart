import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iuto_mobile/db/data/Restaurants/restaurant.dart';
import 'package:iuto_mobile/widgets/like_widget.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final double? width;
  final double? height;
  final Future<void> Function(int restaurantId)? fetchRestaurantDetailsAndCritiques;

  const RestaurantCard({
    super.key, 
    required this.restaurant, 
    this.width, 
    this.height,
    this.fetchRestaurantDetailsAndCritiques,
  });

  @override
  Widget build(BuildContext context) {
    // Prépare l'image à afficher ou une image par défaut
    Widget leadingImage = restaurant.photo != null && restaurant.photo!.isNotEmpty
        ? ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              restaurant.photo!,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey[300],
                  child: const Icon(Icons.restaurant, size: 40, color: Colors.grey),
                );
              },
            ),
          )
        : Container(
            width: 70,
            height: 70,
            color: Colors.grey[300],
            child: const Icon(Icons.restaurant, size: 40, color: Colors.grey),
          );

    return SizedBox(
      width: width,
      height: height,
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () async {
            // Appeler la fonction de chargement si elle est fournie
            if (fetchRestaurantDetailsAndCritiques != null) {
              await fetchRestaurantDetailsAndCritiques!(restaurant.id);
            }
            // Ensuite naviguer vers la page détaillée
            if (context.mounted) {
              context.push("/details/${restaurant.id}");
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Information principale avec image et texte
              ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: leadingImage,
                title: Text(
                  restaurant.nom,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    if (restaurant.telephone != null)
                      Text(
                        restaurant.telephone!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber[700]),
                        const SizedBox(width: 2),
                        Text(
                          restaurant.telephone?.toString() ?? "N/A",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.comment, size: 16, color: Colors.blue[400]),
                        const SizedBox(width: 2),
                        Text(
                          "${restaurant.telephone ?? 0} avis",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Actions en bas de la carte
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    // Badges à gauche
                    Wrap(
                      spacing: 6,
                      children: _buildFeatureBadges(context),
                    ),
                    
                    // Like button à droite
                    LikeWidget(restaurantId: restaurant.id),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Génère les badges de caractéristiques du restaurant
  List<Widget> _buildFeatureBadges(BuildContext context) {
    final List<Widget> badges = [];
    
    if (restaurant.vegetarian == true) {
      badges.add(_buildBadge('Végé', Colors.green[100]!, Icons.eco_outlined));
    }
    
    if (restaurant.delivery == true) {
      badges.add(_buildBadge('Livraison', Colors.blue[100]!, Icons.delivery_dining));
    }

    if (restaurant.wheelchair == true) {
      badges.add(_buildBadge('Accès PMR', Colors.orange[100]!, Icons.accessible));
    }
    if (restaurant.internetAccess == true) {
      badges.add(_buildBadge('Wi-Fi', Colors.purple[100]!, Icons.wifi));
    }
    if (restaurant.smoking == true) {
      badges.add(_buildBadge('Fumeur', Colors.red[100]!, Icons.smoking_rooms));
    }
    if (restaurant.takeaway == true) {
      badges.add(_buildBadge('À emporter', Colors.yellow[100]!, Icons.takeout_dining));
    }
    if (restaurant.driveThrough == true) {
      badges.add(_buildBadge('Drive', Colors.teal[100]!, Icons.drive_eta));
    }
    
    // Limite le nombre de badges à afficher
    return badges.take(5).toList();
  }
  
  Widget _buildBadge(String text, Color color, IconData iconData) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 14, color: Colors.grey[800]),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
