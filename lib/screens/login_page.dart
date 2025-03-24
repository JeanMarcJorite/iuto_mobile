import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Se connecter'),
          onPressed: () {
            Provider.of<AuthProvider>(context, listen: false).login();
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}