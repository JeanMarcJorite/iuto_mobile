import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iuto_mobile/db/iutoDB.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:iuto_mobile/providers/user_provider.dart';

class AuthGates extends StatelessWidget {
  const AuthGates({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Chargement des données en cours...'),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Une erreur est survenue : ${snapshot.error}'),
            );
          } else if (snapshot.hasData && snapshot.data!.session != null) {
            Future.microtask(() async {
              final userProvider =
                  Provider.of<UserProvider>(context, listen: false);
              await userProvider.fetchUser();

              context.go("/home");
            });
          } else {
            Future.microtask(() => context.go('/login'));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
