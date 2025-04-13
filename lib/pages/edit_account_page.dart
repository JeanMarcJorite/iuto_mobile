import 'package:flutter/material.dart';
import 'package:iuto_mobile/db/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditAccountPage extends StatefulWidget {
  const EditAccountPage({super.key});

  @override
  State<EditAccountPage> createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _currentPassword = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Utilisateur non connecté.')),
        );
        return;
      }

      final userData = await SupabaseService.selectUserById(userId);
      if (userData.isNotEmpty) {
        setState(() {
          _usernameController.text = userData['pseudo'] ?? '';
          _emailController.text = userData['email'] ?? '';
        });
      } else {
        debugPrint('Aucune donnée utilisateur trouvée pour ID : $userId');
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des données utilisateur : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de chargement des données : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _newPasswordController,
                decoration: const InputDecoration(labelText: 'New Password'),
                obscureText: true,
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _confirmNewPasswordController,
                decoration: const InputDecoration(labelText: 'Confirm New Password'),
                obscureText: true,
                validator: (value) {
                  if (value != null && value.isNotEmpty && value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        if (_formKey.currentState?.validate() ?? false) {
                          _showPasswordDialog(context);
                        }
                      },
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPasswordDialog(BuildContext context) {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Changes'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please enter your current password to confirm changes.'),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _currentPassword = passwordController.text.trim();
              debugPrint('Mot de passe saisi dans le dialogue : $_currentPassword');
              Navigator.of(context).pop();
              _confirmChanges();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmChanges() async {
    setState(() => _isLoading = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw 'Utilisateur non connecté.';
      }

      // Vérifier le mot de passe actuel
      final userData = await SupabaseService.selectUserById(userId);
      if (userData.isEmpty) {
        throw 'Utilisateur non trouvé dans la base de données.';
      }

      debugPrint('Email utilisé pour la vérification : ${_emailController.text}');
      debugPrint('Mot de passe saisi : $_currentPassword');
      debugPrint('Mot de passe haché dans la base : ${userData['mdp']}');

      // Vérifier avec BCrypt
      final isPasswordValid = SupabaseService.verifyPassword(
        _currentPassword,
        userData['mdp'],
      );

      debugPrint('Mot de passe valide ? : $isPasswordValid');

      if (!isPasswordValid) {
        // Tester avec Supabase Auth comme secours
        final authResponse = await Supabase.instance.client.auth.signInWithPassword(
          email: userData['email'],
          password: _currentPassword,
        );
        if (authResponse.user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Incorrect password. Please try again.')),
          );
          return;
        }
      }

      // Sauvegarder les modifications
      await _saveChanges(userId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Changes saved successfully!')),
      );
    } catch (e) {
      debugPrint('Erreur lors de la confirmation des changements : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

Future<void> _saveChanges(String userId) async {
  try {
    // Préparer les mises à jour
    final updates = {
      'pseudo': _usernameController.text.trim(),
      'email': _emailController.text.trim(),
      if (_newPasswordController.text.isNotEmpty)
        'mdp': SupabaseService.hashPassword(_newPasswordController.text),
    };

    debugPrint('Préparation des données utilisateur : $updates');

    // Mettre à jour Supabase Auth en premier
    final currentEmail = Supabase.instance.client.auth.currentUser?.email ?? '';
    if (_emailController.text.trim() != currentEmail) {
      debugPrint('Mise à jour de l\'email dans auth.users : ${_emailController.text.trim()}');
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(email: _emailController.text.trim()),
      );
    }

    if (_newPasswordController.text.isNotEmpty) {
      debugPrint('Mise à jour du mot de passe dans auth.users');
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: _newPasswordController.text),
      );
    }

    // Ensuite, mettre à jour UTILISATEURS
    debugPrint('Mise à jour des données utilisateur dans UTILISATEURS : $updates');
    await SupabaseService.supabase
        .from('UTILISATEURS')
        .update(updates)
        .eq('id', userId);

    debugPrint('Informations utilisateur mises à jour avec succès.');
  } catch (e) {
    debugPrint('Échec de la mise à jour des informations utilisateur : $e');
    rethrow;
  }
}
}