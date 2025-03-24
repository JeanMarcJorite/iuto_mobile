import 'package:supabase_flutter/supabase_flutter.dart';
import 'restaurant_model.dart';

class RestaurantService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Restaurant>> fetchRestaurants() async {
    final response = await _client
        .from('restaurants')
        .select();

    if (response == null || response is! List) {
      throw Exception('Erreur lors de la récupération des restaurants.');
    }

    return response.map((json) => Restaurant.fromJson(json)).toList();
  }
}