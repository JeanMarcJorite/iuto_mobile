import 'package:flutter/material.dart';
import 'package:iuto_mobile/pages/home_page.dart';
import 'package:iuto_mobile/pages/favoris_page.dart';
import 'package:iuto_mobile/pages/account_page.dart';
import 'package:iuto_mobile/pages/restaurants_page.dart';
import 'package:iuto_mobile/pages/map_page.dart';
import 'package:iuto_mobile/providers/favoris_provider.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const MyHomePage(),
    const RestaurantsPage(),
    const MapPage(),
    const FavorisPage(),
    const AccountPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    final favorisProvider =
        Provider.of<FavorisProvider>(context, listen: false);

    favorisProvider.loadAllFavoris();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Restaurants',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Carte',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoris',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Compte',
          ),
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}
