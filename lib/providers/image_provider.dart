import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iuto_mobile/services/storage_services.dart';

class ImagesProvider extends ChangeNotifier {
  final StorageServices _storageServices = StorageServices();
  final ImagePicker _picker = ImagePicker();

  List<String> _restaurantImages = [];
  List<String> _userImages = [];
  List<File> _localImages = [];

  List<String> get restaurantImages => _restaurantImages;
  List<String> get userImages => _userImages;
  List<File> get localImages => _localImages;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchRestaurantImages(String restaurantId) async {
    if (restaurantId.isEmpty) {
      _restaurantImages = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    try {
      _restaurantImages =
          await _storageServices.getImagesByRestoId(restaurantId);
    } catch (e) {
      debugPrint('Error fetching restaurant images: $e');
      _restaurantImages = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUserImages(String userId) async {
    _isLoading = true;
    try {
      _userImages = await _storageServices.getAllUserImages(userId);
      debugPrint('Fetched ${_userImages.length} user images');
    } catch (e) {
      debugPrint('Error fetching user images: $e');
      _userImages = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearAllImages() {
    _restaurantImages = [];
    _userImages = [];
    notifyListeners();
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

  Future<void> addMultipleImages(ImageSource source) async {
    try {
      final List<XFile>? pickedImages = await _picker.pickMultiImage();
      if (pickedImages != null) {
        for (var image in pickedImages) {
          _localImages.add(File(image.path));
        }
        notifyListeners();
      }
    } catch (e) {
      print('Erreur lors de la sélection des images : $e');
    }
  }

  Future<void> updateImage(int index, ImageSource source) async {
    try {
      final XFile? pickedImage = await _picker.pickImage(source: source);
      if (pickedImage != null && index >= 0 && index < _localImages.length) {
        _localImages[index] = File(pickedImage.path);
        notifyListeners();
      }
    } catch (e) {
      print('Erreur lors de la mise à jour de l\'image : $e');
    }
  }

  void removeImageLocal(int index) {
    if (index >= 0 && index < _localImages.length) {
      _localImages.removeAt(index);
      notifyListeners();
    }
  }

  Future<void> deleteImage(String imageUrl) {
    return _storageServices.removeImage(imageUrl);
  }

  Future<void> deleteAllImages(String path) {
    return _storageServices.removeAllImages(path);
  }

  Future<void> uploadImage(String restaurantId, String userId) async {
    if (_localImages.isNotEmpty) {
      final image = _localImages.first;
      try {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final path = 'restaurants_photos/$restaurantId/$userId/$fileName';

        await _storageServices.uploadFile(path, image);
      } catch (e) {
        print('Erreur lors du téléchargement de l\'image : $e');
      }
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
