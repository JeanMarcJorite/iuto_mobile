import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iuto_mobile/providers/image_provider.dart';
import 'package:iuto_mobile/providers/restaurant_provider.dart';
import 'package:iuto_mobile/providers/user_provider.dart';
import 'package:iuto_mobile/widgets/index.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:iuto_mobile/providers/image_provider.dart';
import 'package:iuto_mobile/providers/restaurant_provider.dart';
import 'package:iuto_mobile/providers/user_provider.dart';
import 'package:iuto_mobile/widgets/index.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:iuto_mobile/providers/image_provider.dart';

class AccountPhotoRestoPage extends StatefulWidget {
  const AccountPhotoRestoPage({super.key});

  @override
  State<AccountPhotoRestoPage> createState() => _AccountPhotoRestoPageState();
}

class _AccountPhotoRestoPageState extends State<AccountPhotoRestoPage> {
  Future<void> _editImage(BuildContext context, String imageUrl) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité à venir')),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String imageUrl) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Confirmer la suppression'),
            content:
                const Text('Êtes-vous sûr de vouloir supprimer cette image ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Supprimer',
                    style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        });
    if (confirmed == true && mounted) {
      try {
        final imagesProvider =
            Provider.of<ImagesProvider>(context, listen: false);
        await imagesProvider.deleteImage(imageUrl);

        if (mounted) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Image supprimée avec succès')),
          );
        }
      } catch (e) {
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Erreur: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes photos de restaurant'),
        centerTitle: true,
      ),
      body: Consumer<ImagesProvider>(
        builder: (context, imagesProvider, child) {
          if (imagesProvider.userImages.isEmpty) {
            return const Center(child: Text('Aucune image trouvée.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: imagesProvider.userImages.length,
            itemBuilder: (context, index) {
              final imageUrl = imagesProvider.userImages[index];
              return GestureDetector(
                onTap: () => _showFullScreenImage(context, imageUrl),
                onLongPress: () => _showImageOptions(context, imageUrl),
                child: Image.network(imageUrl, fit: BoxFit.cover),
              );
            },
          );
        },
      ),
    );
  }

  void _showImageOptions(BuildContext context, String imageUrl) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Modifier'),
            onTap: () {
              Navigator.pop(context);
              _editImage(context, imageUrl);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Supprimer', style: TextStyle(color: Colors.red)),
            onTap: () {
              context.pop();
              _confirmDelete(context, imageUrl);
            },
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImagePage(imageUrl: imageUrl),
      ),
    );
  }
}
