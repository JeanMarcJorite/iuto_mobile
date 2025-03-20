import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iuto_mobile/db/supabase.dart';
import 'package:iuto_mobile/pages/login_page.dart';
import 'package:iuto_mobile/pages/home_page.dart';
import 'package:iuto_mobile/pages/sign_up_page.dart';
import 'package:iuto_mobile/services/auth_gates.dart';
import 'package:iuto_mobile/services/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseService.init();

  final userProvider = UserProvider();
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('userId');
  if (userId != null) {
    await userProvider.fetchUser(userId);
  }

  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => userProvider),
    ], child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _allRoutes,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          surface: Colors.grey.shade100,
          onSurface: Colors.black,
          primary: Colors.blue,
          onPrimary: Colors.white,
          secondary: const Color(0xFFD9D9D9),
        ),
      ),
    );
  }
}

final _allRoutes = GoRouter(routes: [
  GoRoute(
    path: '/',
    builder: (context, state) => const AuthGates(),
  ),
  GoRoute(
    path: '/home',
    builder: (context, state) => const MyHomePage(),
  ),
  GoRoute(
    path: '/login',
    builder: (context, state) => LoginPage(onTap: () => context.go('/signup')),
  ),
  GoRoute(
    path: '/signup',
    builder: (context, state) => SignUpPage(onTap: () => context.go('/login')),
  ),
]);
