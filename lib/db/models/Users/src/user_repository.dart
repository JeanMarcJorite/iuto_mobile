

import 'package:iuto_mobile/db/models/Users/src/models/user_repo.dart';

abstract class UserRepository {
  Stream<MyUser?> get user;

  Future<MyUser> signUp(MyUser myUser, String password);

  Future<void> setUserData(MyUser myUser);

  Future<void> signIn(String email, String password);

  Future<void> logOut();
}
