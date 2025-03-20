import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iuto_mobile/pages/login_page.dart';
import 'package:iuto_mobile/pages/home_page.dart';
import 'package:iuto_mobile/pages/sign_up_page.dart';
import 'package:iuto_mobile/services/auth_gates.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final supabase = await Supabase.initialize(
    url: 'https://ibepjgntihedhmtwslxg.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImliZXBqZ250aWhlZGhtdHdzbHhnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzczOTE4OTksImV4cCI6MjA1Mjk2Nzg5OX0.EsAGivjEfopNH7sKLnykD8rJ-DlAcfSL4IlILMoo7zI',
  );

  if (supabase != null) {
    print('Connected to Supabase');
  } else {
    print('Failed to connect to Supabase');
  }

  runApp(MyApp());
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
