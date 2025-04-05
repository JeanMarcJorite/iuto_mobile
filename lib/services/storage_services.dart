import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iuto_mobile/db/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageServices {
  final supabaseServiceStorage = SupabaseService.supabase;

  Future<void> uploadFile(String path, File file) async {
    try {
      await supabaseServiceStorage.storage.from("images").upload(path, file);
    } catch (e) {
      print('Failed to upload image: $e');
    }
  }

  // Future<Uint8List?> getFile(String path) async {
  //   try {
  //     final imageRef = ref.child(path);
  //     return await imageRef.getData();
  //   } catch (e) {
  //     throw Exception('Failed to get image: $e');
  //   }
  // }
}

// class ImageServices {
//   final StorageServices storageServices = StorageServices();
//   final User? user = FirebaseAuth.instance.currentUser;

//   Future<Uint8List?> getProfileImage() async {
//     if (user == null) return null;

//     final uid = user?.uid;
//     final imageBytes = await storageServices.getFile('profile_images/$uid.jpg');
//     return imageBytes;
//   }

//   Future<Uint8List?> getRecipeImage(String recipeId) async {
//     if (user == null) return null;
//     final uid = user?.uid;

//     try {
//       final imageBytes = await storageServices
//           .getFile('recipe_images/$uid/$recipeId/$recipeId.jpg');
//       return imageBytes;
//     } catch (e) {
//       print('Failed to get recipe image: $e');
//       return null;
//     }
//   }

//   Future<Uint8List?> getIngredientImage(String recipeId, String key) async {
//     if (user == null) return null;
//     final uid = user?.uid;

//     try {
//       final imageBytes = await storageServices.getFile(
//           'recipe_images/$uid/$recipeId/ingredients/${key}_$recipeId.jpg');
//       return imageBytes;
//     } catch (e) {
//       print('Failed to get ingredient image: $e');
//       return null;
//     }
//   }

//   Future<void> deleteIngredientImage(String recipeId, String key) async {
//     if (user == null) return;
//     final uid = user?.uid;

//     await storageServices.ref
//         .child('recipe_images/$uid/$recipeId/ingredients/${key}_$recipeId.jpg')
//         .delete();
//   }

//   Future<void> deleteRecipe(String recipeId) async {
//     if (user == null) return;
//     final uid = user?.uid;

//     await storageServices.ref.child('recipe_images/$uid/$recipeId/').delete();
//   }
// }
