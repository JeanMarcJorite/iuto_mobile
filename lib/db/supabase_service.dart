import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'package:iuto_mobile/db/data/Critiques/critique.dart';
import 'package:iuto_mobile/db/data/Favoris/favoris.dart';
import 'package:iuto_mobile/db/data/Propose/propose.dart';
import 'package:iuto_mobile/db/data/Restaurants/restaurant.dart';
import 'package:iuto_mobile/db/data/Type_cuisine/type_cuisine.dart';
import 'package:iuto_mobile/db/data/Users/src/entities/entities.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient supabase = Supabase.instance.client;

  static Future<void> init() async {
    await Supabase.initialize(
      url: 'https://ibepjgntihedhmtwslxg.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImliZXBqZ250aWhlZGhtdHdzbHhnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzczOTE4OTksImV4cCI6MjA1Mjk2Nzg5OX0.EsAGivjEfopNH7sKLnykD8rJ-DlAcfSL4IlILMoo7zI',
    );
  }

  Future<Map<String, dynamic>> insertUser(MyUserEntity user) async {
    try {
      // Hachez le mot de passe
      user.mdp = hashPassword(user.mdp);
      print('Mot de passe haché : ${user.mdp}');

      // Préparez les données pour l'insertion
      final userDocument = user.toDocument();
      print('Tentative d\'insertion de l\'utilisateur : $userDocument');
      if (await SupabaseService().userExists(user.email)) {
        throw Exception('Un utilisateur avec cet email existe déjà.');
      }
      // Insérez l'utilisateur dans la base de données
      final response = await supabase
          .from('UTILISATEURS')
          .insert(userDocument)
          .select()
          .single();

      print('Utilisateur inséré avec succès : $response');
      return response;
    } catch (e) {
      print('Erreur lors de l\'insertion de l\'utilisateur : $e');
      throw Exception('Failed to insert user: $e');
    }
  }

  Future<bool> userExists(String email) async {
    try {
      final response = await supabase
          .from('UTILISATEURS')
          .select('id')
          .eq('email', email)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print(
          'Erreur lors de la vérification de l\'existence de l\'utilisateur : $e');
      return false;
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
      print("Mot de passe haché récupéré : $hashedPassword");
      print("Mot de passe fourni : $password");
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
    try {
      final response = await supabase
          .from('UTILISATEURS')
          .select()
          .eq('id', id)
          .maybeSingle(); // Utilisez maybeSingle pour éviter les erreurs si aucun résultat n'est trouvé

      if (response == null) {
        throw Exception('Aucun utilisateur trouvé avec cet ID.');
      }

      return response;
    } catch (e) {
      debugPrint('Erreur lors de la récupération de l\'utilisateur : $e');
      return {}; // Retournez une map vide en cas d'erreur
    }
  }

  static Future<List<Restaurant>> selectRestaurants() async {
    final response = await supabase.from('Restaurants').select();

    if (response.isEmpty) {
      throw Exception('Aucune donnée trouvée pour les restaurants.');
    }

    return (response as List<dynamic>)
        .map((restaurant) =>
            Restaurant.fromMap(restaurant as Map<String, dynamic>))
        .toList();
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

      final critiques =
          response.map((critique) => Critique.fromMap(critique)).toList();
      return critiques;
    } catch (e) {
      debugPrint('Erreur lors de la récupération des critiques : $e');
      return [];
    }
  }

  static Future<List<Critique>> selectCritiquesByUserId(String userId) async {
    try {
      final response =
          await supabase.from('Critiquer').select().eq('idU', userId);

      final critiques =
          response.map((critique) => Critique.fromMap(critique)).toList();
      return critiques;
    } catch (e) {
      debugPrint('Erreur lors de la récupération des critiques : $e');
      return [];
    }
  }

  static Future<void> insertCritique(Map<String, dynamic> critique) async {
    await supabase.from('Critiquer').insert(critique);
  }

  static Future<void> deleteCritique(String critiqueId) async {
    debugPrint('Suppression de la critique avec l\'ID : $critiqueId');

    await supabase.from('Critiquer').delete().eq('id', critiqueId);
  }

  static Future<void> updateCritique(Map<String, dynamic> critique) async {
    await supabase.from('Critiquer').update(critique).eq('id', critique['id']);
  }

  static Future<List<Favoris>> selectFavoris() async {
    try {
      final response = await supabase.from('favoris').select();

      final favoris =
          response.map((favori) => Favoris.fromMap(favori)).toList();
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

      final favoris =
          response.map((favori) => Favoris.fromMap(favori)).toList();
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
        return 0;
      }

      return response['id'] as int;
    } catch (e) {
      debugPrint(
          'Erreur lors de la récupération du dernier ID de favoris : $e');
      return 0;
    }
  }

  static Future<List<Propose>> selectProposeByCuisineIds(
      List<int> idCuisines) async {
    try {
      final List<Propose> proposes = [];

      for (int idCuisine in idCuisines) {
        final response =
            await supabase.from('Propose').select().eq('idCuisine', idCuisine);

        if (response.isNotEmpty) {
          proposes.addAll(
              response.map((propose) => Propose.fromMap(propose)).toList());
        }
      }

      if (proposes.isEmpty) {
        throw Exception('Aucune donnée trouvée pour les propositions.');
      }

      return proposes;
    } catch (e) {
      debugPrint('Erreur lors de la récupération des propositions : $e');
      return [];
    }
  }

  static Future<List<TypeCuisine>> selectTypeCuisine() async {
    try {
      final response = await supabase.from('Type_Cuisine').select();

      final typeCuisines = response
          .map((typeCuisine) => TypeCuisine.fromMap(typeCuisine))
          .toList();

      debugPrint('Types de cuisine récupérés : $typeCuisines');
      if (typeCuisines.isEmpty) {
        throw Exception('Aucun type de cuisine trouvé.');
      }
      return typeCuisines;
    } catch (e) {
      debugPrint('Erreur lors de la récupération des types de cuisine : $e');
      return [];
    }
  }
}
