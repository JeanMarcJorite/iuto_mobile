import 'package:flutter/material.dart';
import 'package:iuto_mobile/providers/restaurant_provider.dart';
import 'package:provider/provider.dart';
import 'db/supabase_service.dart';
import 'providers/auth_provider.dart';
import 'pages/home_page.dart';
import 'pages/restaurants_page.dart';
import 'pages/sign_up_page.dart';
import 'pages/login_page.dart';
import 'pages/map_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RestaurantProvider()),
      ],
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
        '/restos': (context) => const RestaurantsPage(),
        '/login': (context) =>  LoginPage(onTap: () {  },),
        '/register': (context) =>  SignUpPage(onTap: () {  },),
        '/register': (context) => SignUpPage(onTap: () {}),
        '/map': (context) => const MapPage(),
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

