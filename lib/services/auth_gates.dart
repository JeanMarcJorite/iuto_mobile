import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:iuto_mobile/providers/user_provider.dart';

class AuthGates extends StatefulWidget {
  const AuthGates({super.key});

  @override
  State<AuthGates> createState() => _AuthGatesState();
}

class _AuthGatesState extends State<AuthGates> {
  bool _initialized = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        await Provider.of<UserProvider>(context, listen: false).fetchUser();
        if (mounted) {
          Future.microtask(() => context.go('/home'));
        }
      } else {
        if (mounted) {
          Future.microtask(() => context.go('/login'));
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() => _initialized = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorScreen(snapshot.error.toString());
          }

          if (!_initialized) {
            return _buildLoadingScreen();
          }

          if (_hasError) {
            return _buildErrorScreen(_errorMessage ?? 'Erreur inconnue');
          }

          final session = snapshot.data?.session;
          
          if (session != null) {
            _handleAuthenticatedUser(context);
            return _buildLoadingScreen(message: 'Connexion réussie...');
          } else {
            Future.microtask(() => context.go('/login'));
            return _buildLoadingScreen(message: 'Redirection...');
          }
        },
      ),
    );
  }

  Future<void> _handleAuthenticatedUser(BuildContext context) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.fetchUser();
      if (mounted) {
        Future.microtask(() => context.go('/home'));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement: ${e.toString()}')),
        );
        Future.microtask(() => context.go('/login'));
      }
    }
  }

  Widget _buildLoadingScreen({String message = 'Chargement...'}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }

  Widget _buildErrorScreen(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 50),
          const SizedBox(height: 16),
          const Text('Erreur de connexion', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text(error, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _initializeApp(),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}