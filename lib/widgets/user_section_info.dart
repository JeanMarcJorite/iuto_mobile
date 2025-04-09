import 'package:flutter/material.dart';
import 'package:iuto_mobile/providers/critique_provider.dart';
import 'package:provider/provider.dart';
import 'package:iuto_mobile/providers/favoris_provider.dart';
import 'package:iuto_mobile/providers/image_provider.dart';
import 'stat_section.dart';

class UserInfoSection extends StatelessWidget {
  final Map<String, dynamic> user;

  const UserInfoSection({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imagesProvider = Provider.of<ImagesProvider>(context);
    final favorisProvider = Provider.of<FavorisProvider>(context);
    final critiqueProvider = Provider.of<CritiqueProvider>(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            StatSection(
              icon: Icons.favorite_outline,
              value: favorisProvider.favoris.length.toString(),
              label: 'Favoris',
            ),
            StatSection(
              icon: Icons.photo_library_outlined,
              value: imagesProvider.userImages.length.toString(),
              label: 'Photos',
            ),
            StatSection(
              icon: Icons.comment_outlined,
              value: critiqueProvider.critiques.length.toString(),
              label: 'Commentaires',
            ),
          ],
        ),
      ),
    );
  }
}
