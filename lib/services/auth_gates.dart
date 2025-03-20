import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iuto_mobile/services/user_provider.dart';
import 'package:go_router/go_router.dart';

class AuthGates extends StatelessWidget {
  const AuthGates({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    if (userProvider.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/home');
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
    }

    return const SizedBox.shrink();
  }
}