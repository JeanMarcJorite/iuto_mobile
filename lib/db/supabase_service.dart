import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://ibepjgntihedhmtwslxg.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImliZXBqZ250aWhlZGhtdHdzbHhnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzczOTE4OTksImV4cCI6MjA1Mjk2Nzg5OX0.EsAGivjEfopNH7sKLnykD8rJ-DlAcfSL4IlILMoo7zI',
    );
  }

  static Future<List<Map<String, dynamic>>> fetchRestaurants() async {
    try {
      final response = await client.from('Restaurants').select('*');
      print('Données brutes de Supabase (fetchRestaurants) : $response');
      return (response as List<dynamic>).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Erreur dans fetchRestaurants : $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> fetchRestaurantById(int id) async {
    final response =
        await client.from('Restaurants').select('*').eq('id', id).single();
    return response;
  }
}
