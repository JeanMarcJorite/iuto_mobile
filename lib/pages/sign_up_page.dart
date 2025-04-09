import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iuto_mobile/components/my_button.dart';
import 'package:iuto_mobile/components/my_textfield.dart';
import 'package:iuto_mobile/services/auth_services.dart';
import 'package:iuto_mobile/db/models/Users/src/models/user_repo.dart';
import 'package:iuto_mobile/db/supabase_service.dart';
import 'package:iuto_mobile/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpPage extends StatefulWidget {
  final void Function()? onTap;

  const SignUpPage({super.key, required this.onTap});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _pseudoController = TextEditingController();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();

  bool _isLoading = false;

  Future<void> _register(BuildContext context) async {
    setState(() => _isLoading = true);

    try {
      if (_emailController.text.trim().isEmpty) {
        throw 'L\'email est requis';
      }
      if (_passwordController.text.trim().isEmpty) {
        throw 'Le mot de passe est requis';
      }
      if (_passwordController.text.trim() !=
          _confirmPasswordController.text.trim()) {
        throw 'Les mots de passe ne correspondent pas';
      }
      if (_pseudoController.text.trim().isEmpty) {
        throw 'Le pseudo est requis';
      }
      if (_nomController.text.trim().isEmpty) {
        throw 'Le nom est requis';
      }
      if (_prenomController.text.trim().isEmpty) {
        throw 'Le prénom est requis';
      }

      final authResponse = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (authResponse.user == null) {
        throw 'Erreur lors de la création du compte';
      }

      final myUser = MyUser(
        id: authResponse.user!.id,
        pseudo: _pseudoController.text.trim(),
        email: _emailController.text.trim(),
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        mdp: _passwordController.text.trim(),
        idRole: 2,
        date_creation: DateTime.now(),
      );

      await SupabaseService().insertUser(myUser.toEntity());

      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool notificationsEnabled =
          prefs.getBool('notifications_enabled') ?? false;

      if (notificationsEnabled) {
        NotificationService().showNotification(
          title: "Bienvenue",
          body: "Votre compte a été créé avec succès.",
        );
        NotificationService().showNotification(
          title: "Attention",
          body: "Vérifiez votre email pour confirmer votre compte.",
        );
      }

      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Créer un compte",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    MyTextField(
                      hintText: "Email",
                      icon: const Icon(Icons.mail_outline),
                      controller: _emailController,
                      obscureText: false,
                      keyboardType: TextInputType.emailAddress,
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
                    MyTextField(
                      hintText: "Confirmer le mot de passe",
                      icon: const Icon(Icons.lock_outline),
                      controller: _confirmPasswordController,
                      obscureText: true,
                      showIconObscure: true,
                    ),
                    const SizedBox(height: 15),
                    MyTextField(
                      hintText: "Pseudo",
                      icon: const Icon(Icons.person_outline),
                      controller: _pseudoController,
                      obscureText: false,
                    ),
                    const SizedBox(height: 15),
                    MyTextField(
                      hintText: "Nom",
                      icon: const Icon(Icons.person_outline),
                      controller: _nomController,
                      obscureText: false,
                    ),
                    const SizedBox(height: 15),
                    MyTextField(
                      hintText: "Prénom",
                      icon: const Icon(Icons.person_outline),
                      controller: _prenomController,
                      obscureText: false,
                    ),
                    const SizedBox(height: 15),
                    MyButton(
                      text: "Créer un compte",
                      onPressed: _isLoading ? null : () => _register(context),
                      elevation: 5.0,
                      fontSize: 15,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Vous avez déjà un compte ?"),
                        InkWell(
                          onTap: widget.onTap,
                          child: Text(
                            "Se connecter",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
