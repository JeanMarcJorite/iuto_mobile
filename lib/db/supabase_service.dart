import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'package:iuto_mobile/db/data/Critiques/critique.dart';
import 'package:iuto_mobile/db/data/Favoris/favoris.dart';
import 'package:iuto_mobile/db/data/Restaurants/restaurant.dart';
import 'package:iuto_mobile/db/data/Users/src/entities/entities.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final supabase = Supabase.instance.client;

  static Future<void> init() async {
    await Supabase.initialize(
      url: 'https://ibepjgntihedhmtwslxg.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImliZXBqZ250aWhlZGhtdHdzbHhnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzczOTE4OTksImV4cCI6MjA1Mjk2Nzg5OX0.EsAGivjEfopNH7sKLnykD8rJ-DlAcfSL4IlILMoo7zI',
    );
  }

  Future<Map<String, dynamic>> insertUser(MyUserEntity user) async {
    try {
      user.mdp = hashPassword(user.mdp);

      final userDocument = user.toDocument();

      final response = await supabase
          .from('UTILISATEURS')
          .insert(userDocument)
          .select()
          .single();

      return response;
    } catch (e) {
      print('Erreur lors de l\'insertion de l\'utilisateur : $e');
      throw Exception('Failed to insert user: $e');
    }
  }

  static Future<Map<String, dynamic>> signIn(
      String email, String password) async {
    try {
      final response = await supabase
          .from('UTILISATEURS')
          .select('id, pseudo, email, nom, prenom, mdp, idRole, date_creation')
          .eq('email', email)
          .maybeSingle();

      if (response == null) {
        print("Aucun utilisateur trouvé avec cet email.");
        return {'success': false, 'user': null};
      }

      final hashedPassword = response['mdp'];
      if (_verifyPassword(password, hashedPassword)) {
        print("Connexion réussie pour l'utilisateur : ${response['pseudo']}");
        return {'success': true, 'user': response};
      } else {
        print("Mot de passe incorrect.");
        return {'success': false, 'user': null};
      }
    } catch (error) {
      print("Erreur lors de la connexion : $error");
      return {'success': false, 'error': error.toString()};
    }
  }

  static bool _verifyPassword(String password, String hashedPassword) {
    return BCrypt.checkpw(password, hashedPassword);
  }

  static String hashPassword(String password) {
    return BCrypt.hashpw(password, BCrypt.gensalt());
  }

  static Future<Map<String, dynamic>> selectUserById(String id) async {
    final response = await supabase
        .from('UTILISATEURS')
        .select()
        .eq('id', id)
        .then((value) => value[0]);
    return response;
  }

  static Future<List<Restaurant>> selectRestaurants() async {
    final response = await supabase.from('Restaurants').select();

    List<Restaurant> restaurants = [];
    for (var restaurant in response) {
      restaurants.add(Restaurant.fromMap(restaurant));
    }
    return restaurants;
  }

  static Future<Restaurant> selectRestaurantById(int id) async {
    final response =
        await supabase.from('Restaurants').select().eq('id', id).single();
    return Restaurant.fromMap(response);
  }

  static Future<List<String>> getAllTables() async {
    try {
      final response = await supabase.rpc('get_all_tables');

      if (response is List) {
        return response.map((table) => table['tablename'] as String).toList();
      } else {
        throw Exception('Erreur lors de la récupération des tables.');
      }
    } catch (e) {
      debugPrint('Erreur : $e');
      throw Exception('Impossible de récupérer les tables : $e');
    }
  }

  static Future<List<Critique>> selectCritiquesByRestaurantId(
      int restaurantId) async {
    try {
      final response =
          await supabase.from('Critiquer').select().eq('idR', restaurantId);

      debugPrint('Réponse brute de Supabase : $response');

      final critiques =
          response.map((critique) => Critique.fromMap(critique)).toList();
      debugPrint('Critiques converties : $critiques');
      return critiques;
    } catch (e) {
      debugPrint('Erreur lors de la récupération des critiques : $e');
      return [];
    }
  }

  static Future<void> insertCritique(Map<String, dynamic> critique) async {
    await supabase.from('Critiquer').insert(critique);
  }

  static Future<void> deleteCritique(int id) async {
    await supabase.from('Critiquer').delete().eq('id', id);
  }

  static Future<void> updateCritique(Map<String, dynamic> critique) async {
    await supabase.from('Critiquer').update(critique).eq('id', critique['id']);
  }

  static Future<List<Favoris>> selectFavoris() async {
    try {
      final response = await supabase.from('favoris').select();

      debugPrint('Réponse brute de Supabase : $response');

      final favoris =
          response.map((favori) => Favoris.fromMap(favori)).toList();
      debugPrint('Favoris convertis : $favoris');
      return favoris;
    } catch (e) {
      debugPrint('Erreur lors de la récupération des favoris : $e');
      return [];
    }
  }

  static Future<List<Favoris>> selectFavorisByUserId(String userId) async {
    try {
      final response =
          await supabase.from('favoris').select().eq('id_utilisateur', userId);

      debugPrint('Réponse brute de Supabase : $response');

      final favoris =
          response.map((favori) => Favoris.fromMap(favori)).toList();
      debugPrint('Favoris convertis : $favoris');
      return favoris;
    } catch (e) {
      debugPrint('Erreur lors de la récupération des favoris : $e');
      return [];
    }
  }

  static Future<void> insertFavoris(Map<String, dynamic> favoris) async {
    await supabase.from('favoris').insert(favoris);
  }

  static Future<void> deleteFavoris(int id) async {
    await supabase.from('favoris').delete().eq('id', id);
  }

  static Future<int> getLastFavorisId() async {
    try {
      final response = await supabase
          .from('favoris')
          .select('id')
          .order('id', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) {
        // Aucun favori trouvé, retourner 0
        return 0;
      }

      return response['id'] as int;
    } catch (e) {
      debugPrint(
          'Erreur lors de la récupération du dernier ID de favoris : $e');
      return 0; // Retourne 0 en cas d'erreur
    }
  }
}
