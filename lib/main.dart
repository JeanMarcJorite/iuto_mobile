import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/auth_provider.dart';
import 'pages/home_page.dart';
import 'pages/restos_page.dart';
import 'pages/sign_up_page.dart';
import 'pages/login_page.dart';
import 'pages/restaurant_list_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'aws-0-eu-west-3.pooler.supabase.com',
    anonKey: 'ENZOAMINEROMAINJEAN-MARC',
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IUTables’O',
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/restos': (context) => const RestosPage(),
        '/login': (context) => LoginPage(onTap: () {}),
        '/register': (context) => SignUpPage(onTap: () {}),
        '/restaurant_list': (context) => RestaurantListPage(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}