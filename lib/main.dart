import 'package:flutter/material.dart';
import 'package:iuto_mobile/db/iutoDB.dart';
import 'package:iuto_mobile/db/supabase_service.dart';
import 'package:iuto_mobile/pages/account_comment_resto_page.dart';
import 'package:iuto_mobile/pages/account_photo_resto_page.dart';
import 'package:iuto_mobile/pages/add_avis_page.dart';
import 'package:iuto_mobile/pages/advanced_settings.dart';
import 'package:iuto_mobile/pages/avis_detail_page.dart';
import 'package:iuto_mobile/pages/cuisine_selection_page.dart';
import 'package:iuto_mobile/pages/edit_account_page.dart';
import 'package:iuto_mobile/pages/main_page.dart';
import 'package:iuto_mobile/pages/recherche_page.dart';
import 'package:iuto_mobile/pages/restaurant_photo_page.dart';
import 'package:iuto_mobile/pages/restaurants_details.dart';
import 'package:iuto_mobile/pages/resto_liste_page.dart';
import 'package:iuto_mobile/pages/settings_page.dart';
import 'package:iuto_mobile/pages/map_page.dart';
import 'package:iuto_mobile/providers/critique_provider.dart';
import 'package:iuto_mobile/providers/favoris_provider.dart';
import 'package:iuto_mobile/providers/geolocalisation_provider.dart';
import 'package:iuto_mobile/providers/image_provider.dart';
import 'package:iuto_mobile/providers/user_provider.dart';
import 'package:iuto_mobile/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:iuto_mobile/providers/restaurant_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:iuto_mobile/pages/login_page.dart';
import 'package:iuto_mobile/pages/sign_up_page.dart';
import 'package:iuto_mobile/services/auth_gates.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    debugPrint('Initialisation de Supabase...');
    await SupabaseService.init();
    debugPrint('Supabase initialisé avec succès.');

    debugPrint('Initialisation de la base de données locale...');
    final IutoDB db = IutoDB();
    debugPrint('Base de données locale initialisée avec succès.');

    debugPrint('Initialisation de la notification...');
    NotificationService().initNotification();
    debugPrint('Service de notification initialisé avec succès.');

    debugPrint('Lancement de l\'application...');
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => RestaurantProvider()),
          ChangeNotifierProvider(create: (_) => CritiqueProvider()),
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (_) => FavorisProvider()),
          ChangeNotifierProvider(create: (_) => ImagesProvider()),
          ChangeNotifierProvider(create: (_) => GeolocalisationProvider()),
          ChangeNotifierProvider(create: (_) => db),
        ],
        child: const MyApp(),
      ),
    );
    debugPrint('Application lancée avec succès.');
  } catch (e, stackTrace) {
    debugPrint('Erreur lors de l\'initialisation : $e');
    debugPrint('Stack trace : $stackTrace');
  }
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
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
        ),
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
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
      builder: (context, state) {
        return MainPage();
      }),
  GoRoute(
    path: '/selection',
    builder: (context, state) {
      return const CuisineSelectionPage();
    },
  ),
  GoRoute(
      path: "/recherche",
      builder: (context, state) =>
          RecherchePage(search: state.uri.queryParameters['search'] ?? '')),
  GoRoute(
    path: '/login',
    builder: (context, state) => LoginPage(onTap: () => context.go('/signup')),
  ),
  GoRoute(
    path: '/signup',
    builder: (context, state) => SignUpPage(onTap: () => context.go('/login')),
  ),
  GoRoute(
    path: '/map',
    builder: (context, state) => const MapPage(),
  ),
  GoRoute(
      path: '/details/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final previousPage =
            state.extra != null && state.extra is Map<String, String>
                ? (state.extra as Map<String, String>)['previousPage']
                : null;
        return RestaurantDetailsPage(
          key: ValueKey('details-${DateTime.now().millisecondsSinceEpoch}'),
          restaurantId: int.parse(id),
          previousPage: previousPage,
        );
      },
      routes: [
        GoRoute(
          path: 'photo',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return RestaurantPhotoPage(
              restaurantId: int.parse(id),
            );
          },
        ),
        GoRoute(
            path: 'avis',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return AllReviewsPage(restaurantId: int.parse(id));
            }),
        GoRoute(
            path: 'avis/add/:critiqueId',
            builder: (context, state) {
              final restaurantId = int.parse(state.pathParameters['id']!);
              final critiqueId = state.pathParameters['critiqueId']!;
              return AddAvisPage(
                  restaurantId: restaurantId, idCritique: critiqueId);
            }),
      ]),
  GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
      routes: [
        GoRoute(
          path: 'profile/edit',
          builder: (context, state) => const EditAccountPage(),
        ),
        GoRoute(
          path: 'profile/advanced',
          builder: (context, state) => const AdvancedSettingsPage(),
        )
      ]),
  GoRoute(
    path: '/user/photosResto',
    builder: (context, state) {
      return const AccountPhotoRestoPage();
    },
  ),
  GoRoute(
    path: '/user/comments',
    builder: (context, state) {
      return const AccountCommentRestoPage();
    },
  ),
  GoRoute(
    path: '/restaurant-list',
    builder: (context, state) {
      final args = state.extra as Map<String, dynamic>;
      return RestaurantListPage(
        title: args['title'],
        restaurants: args['restaurants'],
      );
    },
  ),
]);
