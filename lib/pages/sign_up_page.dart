import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iuto_mobile/components/my_button.dart';
import 'package:iuto_mobile/components/my_textfield.dart';
import 'package:iuto_mobile/db/auth_services.dart';
import 'package:iuto_mobile/db/data/Users/src/models/user_repo.dart';
import 'package:iuto_mobile/db/supabase_service.dart';


class SignUpPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _pseudoController = TextEditingController();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();



  final void Function()? onTap;

  SignUpPage({super.key, required this.onTap});

  void register(BuildContext context) async {
  final authService = AuthServices();
  final supabaseService = SupabaseService();

  if (_passwordController.text.trim() == _confirmPasswordController.text.trim()) {
    try {
      MyUser myUser = MyUser.empty;
      myUser.email = _emailController.text.trim();
      myUser.pseudo = _pseudoController.text.trim();
      myUser.mdp = _passwordController.text.trim();
      myUser.nom = _nomController.text.trim();
      myUser.prenom = _prenomController.text.trim();

      if (myUser.email == '') {
      showSnackBar(context, 'L\'email est requis');
      return;
    }
    if (myUser.mdp == '') {
      showSnackBar(context, 'Le mot de passe est requis');
      return;
    }
    if (myUser.pseudo == '') {
      showSnackBar(context, 'Le pseudo est requis');
      return;
    }
    if (myUser.nom == '') {
      showSnackBar(context, 'Le nom est requis');
      return;
    }
    if (myUser.prenom == '') {
      showSnackBar(context, 'Le prénom est requis');
      return;
    }

      // Vérifiez si l'utilisateur existe déjà
      if (await supabaseService.userExists(myUser.email)) {
        showSnackBar(context, 'Un utilisateur avec cet email existe déjà');
        return;
      }

      await supabaseService.insertUser(myUser.toEntity());

      await authService.signUp(myUser, _passwordController.text.trim());



      // Affichage du succès
      showDialog(
        context: context,
        builder: ((context) => AlertDialog(
              title: const Text("Succès"),
              content: const Text("Compte créé avec succès. Veuillez vérifier votre email."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.go('/login');
                  },
                  child: const Text("OK"),
                )
              ],
            )),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: ((context) => AlertDialog(
              title: const Text("Erreur"),
              content: Text("Une erreur s'est produite : ${e.toString()}"),
            )),
      );
    }
  } else {
    showDialog(
      context: context,
      builder: ((context) => const AlertDialog(
            title: Text("Les mots de passe ne correspondent pas"),
          )),
    );
  }
}

  void showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
                    "Create Account",
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
                  ),
                  const SizedBox(height: 15),
                  MyTextField(
                    hintText: "Password",
                    icon: const Icon(Icons.lock_outline),
                    controller: _passwordController,
                    obscureText: true,
                    showIconObscure: true,
                  ),
                  const SizedBox(height: 15),
                  MyTextField(
                    hintText: "Confirm Password",
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
                    text: "Sign up",
                    onPressed: () {
                      register(context);
                    },
                    elevation: 5.0,
                    fontSize: 15,
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already Have an Account ? "),
                      InkWell(
                        onTap: onTap,
                        child: Text(
                          "Log in",
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
