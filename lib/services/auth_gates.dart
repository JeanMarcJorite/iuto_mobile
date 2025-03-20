import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iuto_mobile/db/auth_services.dart';
import 'package:iuto_mobile/db/data/Users/src/models/user_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGates extends StatelessWidget {
  const AuthGates({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<MyUser?>(
      stream: AuthServices().user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasData && snapshot.data != MyUser.empty) {
          Future.microtask(() => context.go('/home'));
        } else {
          Future.microtask(() => context.go('/login'));
        }
        return const SizedBox.shrink(); 
      },
    ));
  }
}
