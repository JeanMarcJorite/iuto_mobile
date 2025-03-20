import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iuto_mobile/components/my_button.dart';
import 'package:iuto_mobile/components/my_textfield.dart';
import 'package:iuto_mobile/db/supabase.dart';
import 'package:iuto_mobile/services/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final void Function()? onTap;

  LoginPage({super.key, required this.onTap});

  void login(BuildContext context) async {
  try {
    final result = await SupabaseService.signIn(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (result['success']) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', result['user']['id']); 
      await prefs.setBool('isLoggedIn', true);

      Provider.of<UserProvider>(context, listen: false).user = result['user'];

      context.go('/home');
    } else {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text("Erreur"),
          content: Text("Email ou mot de passe incorrect."),
        ),
      );
    }
  } catch (e) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Erreur"),
        content: Text(e.toString()),
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
                    "Veuillez vous connecter pour continuer",
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
                    text: "Connexion",
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
                      const Text("Nouvelle Utilisateur ? "),
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