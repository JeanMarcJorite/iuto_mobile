import 'package:bcrypt/bcrypt.dart';
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

  static Future<Map<String, dynamic>> signIn(String email, String password) async {
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
}
