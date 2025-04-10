import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:iuto_mobile/providers/user_provider.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return FutureBuilder(
      future: userProvider.fetchUserByEmail(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Erreur : ${snapshot.error}')),
          );
        }

        final user = userProvider.user;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profil'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  context.push('/settings');
                },
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/selection');
        },
        child: const Icon(Icons.navigate_next),
      ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nom : ${user['nom']} ${user['prenom']}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Email : ${user['email']}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                
                
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    context.push('/user/comments');
                  },
                  icon: const Icon(Icons.comment),
                  label: const Text('Voir tous les commentaires'),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    context.push('/user/photos');
                  },
                  icon: const Icon(Icons.photo),
                  label: const Text('Voir toutes les photos'),
                ),
              ],

            ),
          ),
        );
      },
    );
  }
}