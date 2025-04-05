import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iuto_mobile/providers/user_provider.dart';
import 'package:iuto_mobile/services/storage_services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class RestaurantPhotoPage extends StatefulWidget {
  final int restaurantId;
  const RestaurantPhotoPage({super.key, required this.restaurantId});

  @override
  State<RestaurantPhotoPage> createState() => _RestaurantPhotoPageState();
}

class _RestaurantPhotoPageState extends State<RestaurantPhotoPage> {
  final List<File> _photos = [];
  final ImagePicker _picker = ImagePicker();
  final StorageServices _storageServices = StorageServices();

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
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _photos.add(File(image.path));
      });
    }
  }

  Future<void> _uploadImages(String userId) async {
    if (_photos.isEmpty) {
      _showSnackBar('Ajouter une photo avant de télécharger!',
          backgroundColor: Colors.orange[400]!);
      return;
    }

    final List<File> photosAUpload = List.from(_photos);

    for (int i = 0; i < photosAUpload.length; i++) {
      final photo = photosAUpload[i];
      try {
        final nomFichier = Uuid().v4();
        final chemin =
            'restaurants_photos/${widget.restaurantId}/$userId/$nomFichier';

        await _storageServices.uploadFile(chemin, photo).then(
          (value) async {
            setState(() {
              _photos.remove(photo);
            });
            await Future.delayed(Duration(milliseconds: 100));
          },
        );
      } catch (e) {
        _showSnackBar('Échec du téléchargement de l\'image : $e',
            backgroundColor: Colors.red);
      }
    }

    _showSnackBar('Toutes les photos ont été téléchargées avec succès!');
    context.pop();
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text('Prendre une photo'),
            onTap: () {
              context.pop();
              _optionImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: Icon(Icons.photo_library),
            title: Text('Choisir depuis la galerie'),
            onTap: () {
              context.pop();
              _optionImage(ImageSource.gallery);
            },
          ),
        ],
      ),
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
                child: Text('Fermer'),
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
            leading: Icon(Icons.edit),
            title: Text('Modifier la photo'),
            onTap: () {
              context.pop();
              _editPhoto(index);
            },
          ),
          ListTile(
            leading: Icon(Icons.delete),
            title: Text('Supprimer la photo'),
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
    setState(() {
      _photos.removeAt(index);
    });
  }

  void _editPhoto(int index) async {
    final XFile? newImage =
        await _picker.pickImage(source: ImageSource.gallery);
    if (newImage != null) {
      setState(() {
        _photos[index] = File(newImage.path);
      });
      _showSnackBar('Photo modifiée avec succès!',
          backgroundColor: Colors.green[400]!);
    } else {
      _showSnackBar('Aucune photo sélectionnée.',
          backgroundColor: Colors.orange);
    }
  }

  Widget _buildImageGrid() {
    if (_photos.isEmpty) {
      return Center(child: Text('Aucune photo disponible.'));
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      itemCount: _photos.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _showFullImage(_photos[index]),
          onLongPress: () => _showEditOptions(index),
          child: Image.file(
            _photos[index],
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<UserProvider>(context, listen: false).user["id"];
    return Scaffold(
      appBar: AppBar(
        title: Text('Photos du restaurant'),
      ),
      body: Column(
        children: [
          Expanded(child: _buildImageGrid()),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: _showPhotoOptions,
              icon: Icon(Icons.add_a_photo),
              label: Text('Ajouter une photo'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: () async {
                await _uploadImages(userId);
              },
              icon: Icon(Icons.upload_file),
              label: Text('Télécharger les photos'),
            ),
          ),
        ],
      ),
    );
  }
}
