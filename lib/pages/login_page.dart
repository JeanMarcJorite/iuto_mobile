import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iuto_mobile/components/my_button.dart';
import 'package:iuto_mobile/components/my_textfield.dart';
import 'package:iuto_mobile/services/auth_services.dart';
import 'package:iuto_mobile/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final void Function()? onTap;

  LoginPage({super.key, required this.onTap});

  void login(BuildContext context) async {
    final authServices = AuthServices();

    if (_emailController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Erreur"),
          content: const Text("Veuillez entrer votre email."),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }
    if (_passwordController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Erreur"),
          content: const Text("Veuillez entrer votre mot de passe."),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    try {
      await authServices.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool notificationsEnabled =
          prefs.getBool('notifications_enabled') ?? false;

      if (notificationsEnabled) {
        NotificationService().initNotification();
        NotificationService().showNotification(
          title: "Bienvenue ${_emailController.text} !",
          body: "Vous êtes connecté avec succès.",
        );
      }

      Future.microtask(() => context.go('/home'));
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Erreur"),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Stack(
        children: [
          Positioned(
            top: 10,
            left: 230,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.blue.shade300,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 270,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.blue.shade300,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Connexion",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Connectez-vous à votre compte",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 30),
                  MyTextField(
                    hintText: "Email",
                    icon: const Icon(Icons.mail_outline),
                    controller: _emailController,
                    obscureText: false,
                  ),
                  const SizedBox(height: 15),
                  MyTextField(
                    hintText: "Mot de passe",
                    icon: const Icon(Icons.lock_outline),
                    controller: _passwordController,
                    obscureText: true,
                    showIconObscure: true,
                  ),
                  const SizedBox(height: 15),
                  MyButton(
                    text: "Se connecter",
                    onPressed: () {
                      login(context);
                    },
                    elevation: 5.0,
                    fontSize: 15,
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Vous n'avez pas de compte ?"),
                      GestureDetector(
                        onTap: onTap,
                        child: Text(
                          "Créer un compte",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade400,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      )),
    );
  }
}
