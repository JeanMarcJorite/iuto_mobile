import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iuto_mobile/db/supabase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProvider with ChangeNotifier {
  Map<String, dynamic> _user = {};

  Map<String, dynamic> get user => _user;

  set user(Map<String, dynamic> newUser) {
    _user = newUser;
    notifyListeners();
  }

  bool get isLoggedIn => _user.isNotEmpty;

  Future<void> fetchUser() async {
  final session = Supabase.instance.client.auth.currentSession;
  if (session != null) {
    final userId = session.user.id;
    try {
      final fetchedUser = await SupabaseService.selectUserById(userId);
      if (fetchedUser.isNotEmpty) {
        _user = fetchedUser;
      } else {
        debugPrint('Aucun utilisateur trouvé pour l\'ID : $userId');
        _user = {}; 
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération des données utilisateur : $e');
      _user = {}; 
    }
    notifyListeners();
  }
}

  Future<void> logOut(BuildContext context) async {
    _user = {};
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    context.go('/login');
  }

  
}
