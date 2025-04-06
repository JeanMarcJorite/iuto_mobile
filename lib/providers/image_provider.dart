import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iuto_mobile/services/storage_services.dart';

class ImagesProvider extends ChangeNotifier {
  final StorageServices _storageServices = StorageServices();
  final ImagePicker _picker = ImagePicker();

  final List<File> _localImages = [];
  List<File> get localImages => _localImages;

  List<String> _imageUrls = [];
  List<String> get imageUrls => _imageUrls;

  bool _isLoading = false;
  bool get isLoading => _isLoading; 


  Future<void> fetchImagesByRestaurantId(String restaurantId) async {
    _isLoading = true;
    try {
      final imageUrls = await _storageServices.getImagesByRestoId(restaurantId);
      _imageUrls = imageUrls;
    } catch (e) {
      print('Erreur lors de la récupération des images : $e');
      _imageUrls = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchImagesByUserId(String restaurantId, String userId) async {
    _isLoading = true;

    try {
      final imageUrls = await _storageServices.getImagesRestoByUserId(
        'restaurants_photos/$restaurantId',
        userId,
      );
      _imageUrls = imageUrls;
    } catch (e) {
      print('Erreur lors de la récupération des images : $e');
      _imageUrls = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addImage(ImageSource source) async {
    try {
      final XFile? pickedImage = await _picker.pickImage(source: source);
      if (pickedImage != null) {
        _localImages.add(File(pickedImage.path));
        notifyListeners();
      }
    } catch (e) {
      print('Erreur lors de la sélection de l\'image : $e');
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < _localImages.length) {
      _localImages.removeAt(index);
      notifyListeners();
    }
  }

  Future<void> uploadImages(String restaurantId, String userId) async {
    for (int i = 0; i < _localImages.length; i++) {
      final image = _localImages[i];
      try {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final path = 'restaurants_photos/$restaurantId/$userId/$fileName';

        await _storageServices.uploadFile(path, image);
      } catch (e) {
        print('Erreur lors du téléchargement de l\'image : $e');
      }
    }

    _localImages.clear();
    notifyListeners();
  }

  void clearLocalImages() {
    _localImages.clear();
    notifyListeners();
  }
}

