import 'package:iuto_mobile/db/data/Users/src/entities/entities.dart';
import 'package:iuto_mobile/db/data/Users/src/models/user_repo.dart';
import 'package:iuto_mobile/db/data/Users/src/user_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthServices implements UserRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  final userCollection = Supabase.instance.client.from('UTILISATEURS');

  @override
  Stream<MyUser?> get user {
    return _supabase.auth.onAuthStateChange.asyncExpand((authState) async* {
      final session = authState.session;
      if (session == null) {
        yield MyUser.empty;
      } else {
        final userId = session.user.id;
        final response =
            await userCollection.select().eq('id', userId).single();
        if (response.isNotEmpty) {
          yield MyUser.fromEntity(MyUserEntity.fromDocument(response));
        } else {
          yield MyUser.empty;
        }
      }
    });
  }

  @override
  Future<void> logOut() async {
    await _supabase.auth.signOut();
  }

  @override
  Future<void> setUserData(MyUser myUser) async {
    try {
      await userCollection
          .upsert(myUser.toEntity().toDocument())
          .eq('id', myUser.id);
    } catch (e) {
      throw Exception('Failed to set user data: ${e.toString()}');
    }
  }

  @override
  Future<AuthResponse> signIn(String email, String password) async {
    try {
      return await _supabase.auth
          .signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      throw Exception('Failed to sign in: ${e.message}');
    }
  }

  @override
  Future<MyUser> signUp(MyUser myUser, String password) async {
    try {
      final response =
          await _supabase.auth.signUp(email: myUser.email, password: password);
      if (response.user == null) {
        throw Exception('Failed to sign up: User is null');
      }
      myUser.id = response.user!.id;

      await setUserData(myUser);
      return myUser;
    } on AuthException catch (e) {
      throw Exception('Failed to sign up: ${e.message}');
    } catch (e) {
      throw Exception('Failed to sign up: ${e.toString()}');
    }
  }
}
