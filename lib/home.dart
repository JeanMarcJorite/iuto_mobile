import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Mock class pour la gestion de l'état de session
class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  
  bool get isLoggedIn => _isLoggedIn;
  
  void login() {
    _isLoggedIn = true;
    notifyListeners();
  }
  
  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }
}

class HomePage extends StatelessWidget {
  final List<Map<String, String>> bestRestaurants = [
    {'nom': 'Restaurant 1', 'adresse': 'Adresse 1'},
    {'nom': 'Restaurant 2', 'adresse': 'Adresse 2'},
    // Ajouter d'autres restaurants...
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IUTables’O'),
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () => Navigator.pushNamed(context, '/home'),
          ),
          IconButton(
            icon: Icon(Icons.restaurant),
            onPressed: () => Navigator.pushNamed(context, '/restos'),
          ),
          Consumer<AuthProvider>(
            builder: (context, auth, child) => auth.isLoggedIn
                ? IconButton(
                    icon: Icon(Icons.logout),
                    onPressed: () {
                      auth.logout();
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                  )
                : IconButton(
                    icon: Icon(Icons.login),
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bienvenue sur la page d\'accueil',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Bienvenue sur notre plateforme de comparateur de Restaurant en ligne vous pouvez comparer les restaurant de la région Orléanaises',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Les Meilleurs restaurants',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 3/2,
                    ),
                    itemCount: bestRestaurants.length,
                    itemBuilder: (context, index) {
                      final restaurant = bestRestaurants[index];
                      return Card(
                        elevation: 4,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                restaurant['nom']!,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Adresse: ${restaurant['adresse']}',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Footer(), // Widget personnalisé pour le footer
          ],
        ),
      ),
    );
  }
}

class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.grey[200],
      child: Center(
        child: Text(
          '© 2023 IUTables’O - Tous droits réservés'),
      ),
    );
  }
}