import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iuto_mobile/components/my_button.dart';
import 'package:iuto_mobile/components/my_textfield.dart';
import 'package:iuto_mobile/db/data/Users/src/models/user_repo.dart';
import 'package:iuto_mobile/db/supabase.dart';
import 'package:iuto_mobile/services/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _pseudoController = TextEditingController();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();

  final void Function()? onTap;

  SignUpPage({super.key, required this.onTap});

  void register(BuildContext context) async {
    if (_passwordController.text.trim() ==
        _confirmPasswordController.text.trim()) {
      try {
        final supabeService = SupabaseService();
        MyUser myUser = MyUser.empty;
    
        myUser.email = _emailController.text.trim();
        myUser.mdp = _passwordController.text.trim();
        myUser.pseudo = _pseudoController.text.trim();
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


        final myuserEntity = myUser.toEntity();


        final rep = await supabeService.insertUser(myuserEntity);

         SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', rep["id"]);
          await prefs.setBool('isLoggedIn', true);

          Provider.of<UserProvider>(context, listen: false).user = rep;
          context.go('/home');
      } catch (e) {
        showDialog(
            context: context,
            builder: ((context) => AlertDialog(
                  title: Text(e.toString()),
                )));
      }
    } else {
      showDialog(
          context: context,
          builder: ((context) => const AlertDialog(
                title: Text("Erreur"),
                content: Text("Les mots de passe ne correspondent pas"),
              )));
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
                    "Créez un compte",
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
                      const Text("Déjà un compte ? "),
                      InkWell(
                        onTap: onTap,
                        child: Text(
                          "Se connecter",
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
