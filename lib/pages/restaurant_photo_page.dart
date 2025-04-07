import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iuto_mobile/providers/image_provider.dart';
import 'package:iuto_mobile/providers/user_provider.dart';
import 'package:provider/provider.dart';

class RestaurantPhotoPage extends StatefulWidget {
  final int restaurantId;
  const RestaurantPhotoPage({super.key, required this.restaurantId});

  @override
  State<RestaurantPhotoPage> createState() => _RestaurantPhotoPageState();
}

class _RestaurantPhotoPageState extends State<RestaurantPhotoPage> {
  void _showSnackBar(String message, {Color backgroundColor = Colors.green}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(milliseconds: 600),
      ),
    );
  }

  Future<void> _optionImage(ImageSource source) async {
    final imagesProvider = Provider.of<ImagesProvider>(context, listen: false);
    try {
      await imagesProvider.addImage(source);
      if (imagesProvider.localImages.isEmpty) {
        _showSnackBar('Aucune image sélectionnée!',
            backgroundColor: Colors.red);
        return;
      }

      _showSnackBar('Image ajoutée avec succès!');
    } catch (e) {
      _showSnackBar('Erreur lors de l\'ajout de l\'image : $e',
          backgroundColor: Colors.red);
    }
  }

  Future<void> _uploadImages(String userId) async {
    final imagesProvider = Provider.of<ImagesProvider>(context, listen: false);

    if (imagesProvider.localImages.isEmpty) {
      _showSnackBar('Ajouter une photo avant de télécharger!',
          backgroundColor: Colors.orange[400]!);
      return;
    }

    try {
      await imagesProvider.uploadImages(
        widget.restaurantId.toString(),
        userId,
      );
      _showSnackBar('Toutes les photos ont été téléchargées avec succès!');
      context.pop();
    } catch (e) {
      _showSnackBar('Erreur lors du téléchargement des images : $e',
          backgroundColor: Colors.red);
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Prendre une photo'),
            onTap: () {
              context.pop();
              _optionImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choisir depuis la galerie'),
            onTap: () {
              context.pop();
              _optionImage(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid() {
    final imagesProvider = Provider.of<ImagesProvider>(context);

    if (imagesProvider.localImages.isEmpty) {
      return const Center(child: Text('Aucune photo disponible.'));
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      itemCount: imagesProvider.localImages.length,
      itemBuilder: (context, index) {
        final image = imagesProvider.localImages[index];
        return GestureDetector(
          onTap: () => _showFullImage(image),
          onLongPress: () => _showEditOptions(index),
          child: Image.file(
            image,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }

  void _showFullImage(File image) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.file(image),
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

  void _showEditOptions(int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Modifier la photo'),
            onTap: () {
              context.pop();
              _editPhoto(index);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Supprimer la photo'),
            onTap: () {
              context.pop();
              _deletePhoto(index);
            },
          ),
        ],
      ),
    );
  }

  void _deletePhoto(int index) {
    final imagesProvider = Provider.of<ImagesProvider>(context, listen: false);
    imagesProvider.removeImage(index);
    _showSnackBar('Photo supprimée avec succès!');
  }

  void _editPhoto(int index) async {
    final imagesProvider = Provider.of<ImagesProvider>(context, listen: false);
    if (imagesProvider.localImages.isNotEmpty) {
      imagesProvider.updateImage(index, ImageSource.gallery);
      _showSnackBar('Photo modifiée avec succès!',
          backgroundColor: Colors.green[400]!);
    } else {
      _showSnackBar('Aucune photo sélectionnée.',
          backgroundColor: Colors.orange);
    }
  }

  void _showConfirmDeleteAllDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: const Text(
              'Êtes-vous sûr de vouloir supprimer toutes les photos locales ?'),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                context.pop();
                _deleteAllPhotos();
              },
              child: const Text(
                'Supprimer',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteAllPhotos() {
    final imagesProvider = Provider.of<ImagesProvider>(context, listen: false);
    imagesProvider.clearLocalImages();
    _showSnackBar('Toutes les photos ont été supprimées avec succès!');
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<UserProvider>(context, listen: false).user["id"];
    final imagesProvider = Provider.of<ImagesProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photos du restaurant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () {
              if (imagesProvider.localImages.isNotEmpty) {
                _showConfirmDeleteAllDialog();
              } else {
                _showSnackBar('Aucune photo à supprimer!',
                    backgroundColor: Colors.orange);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildImageGrid()),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: _showPhotoOptions,
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Ajouter une photo'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: () async {
                await _uploadImages(userId);
              },
              icon: const Icon(Icons.upload_file),
              label: const Text('Télécharger les photos'),
            ),
          ),
        ],
      ),
    );
  }
}
