import 'package:flutter/material.dart';
import 'package:iuto_mobile/db/auth_services.dart';
import 'package:go_router/go_router.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  void _logout(BuildContext context) async {
    final authService = AuthServices();
    try {
      await authService.logOut();
      context.go('/login'); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la déconnexion : ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _logout(context);
          },
          child: const Text('Logout'),
        ),
      ),
    );
  }
}