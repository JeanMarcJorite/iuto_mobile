import 'dart:io';

import 'package:flutter/services.dart';
import 'package:iuto_mobile/db/supabase_service.dart';

class StorageServices {
  final supabaseServiceStorage = SupabaseService.supabase;

  Future<void> uploadFile(String path, File file) async {
    try {
      await supabaseServiceStorage.storage.from("images").upload(path, file);
    } catch (e) {
      print('Failed to upload image: $e');
    }
  }

  Future<Uint8List> getImageData(String path) async {
    try {
      return await supabaseServiceStorage.storage.from("images").download(path);
    } catch (e) {
      print('Failed to get image data: $e');
      rethrow;
    }
  }

  Future<List<String>> getImagesByRestoId(String restaurantId) async {
    try {
      final response = await supabaseServiceStorage.storage.from("images").list(
            path: 'restaurants_photos/$restaurantId',
          );

      if (response.isEmpty) {
        print(
            'Aucun fichier ou sous-dossier trouvé pour le restaurant : $restaurantId');
        return [];
      }

      List<String> allFileUrls = [];

      for (final item in List.from(response)) {
        final userFiles =
            await supabaseServiceStorage.storage.from("images").list(
                  path: 'restaurants_photos/$restaurantId/${item.name}',
                );

        final fileUrls = userFiles.map((file) {
          return supabaseServiceStorage.storage.from("images").getPublicUrl(
              'restaurants_photos/$restaurantId/${item.name}/${file.name}');
        }).toList();

        allFileUrls.addAll(fileUrls);
      }

      return allFileUrls;
    } catch (e) {
      print('Failed to list all files: $e');
      return [];
    }
  }

  Future<List<String>> getImagesRestoByUserId(
      String path, String userId) async {
    try {
      final response = await supabaseServiceStorage.storage
          .from("images")
          .list(path: '$path/$userId');

      final List<String> urlFichiers = response.map((file) {
        return supabaseServiceStorage.storage
            .from("images")
            .getPublicUrl('$path/$userId/${file.name}');
      }).toList();

      return urlFichiers;
    } catch (e) {
      print('Failed to list files: $e');
      return [];
    }
  }
}
