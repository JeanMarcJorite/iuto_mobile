import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';


//Prendre une photo avec l'appareil photo ou en sélectionner une depuis la galerie.
//Télécharger la photo sur Supabase.
//Afficher les photos existantes du restaurant.

class PhotoPage extends StatefulWidget {
  @override
  _PhotoPageState createState() => _PhotoPageState();
}

class _PhotoPageState extends State<PhotoPage> {
  final List<File> _photos = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _addPhotoFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _photos.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _addPhotoFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _photos.add(File(pickedFile.path));
      });
    }
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
              _addPhotoFromCamera();
            },
          ),
          ListTile(
            leading: Icon(Icons.photo_library),
            title: Text('Choisir depuis la galerie'),
            onTap: () {
               context.pop();
              _addPhotoFromGallery();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photos du restaurant'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _photos.isEmpty
                ? Center(child: Text('Aucune photo disponible.'))
                : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4.0,
                      mainAxisSpacing: 4.0,
                    ),
                    itemCount: _photos.length,
                    itemBuilder: (context, index) {
                      return Image.file(
                        _photos[index],
                        fit: BoxFit.cover,
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: _showPhotoOptions,
              icon: Icon(Icons.add_a_photo),
              label: Text('Ajouter une photo'),
            ),
          ),
        ],
      ),
    );
  }
}