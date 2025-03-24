import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/footer.dart';

class HomePage extends StatelessWidget {
  final List<Map<String, String>> bestRestaurants = [
    {'nom': 'Le Bistrot Français', 'adresse': '12 Rue des Orléanais'},
    {'nom': 'La Table Royale', 'adresse': '24 Avenue des Ducs'},
    {'nom': 'Chez Marcel', 'adresse': '5 Place du Marché'},
  ];

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IUTables’O'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restaurant),
            onPressed: () => Navigator.pushNamed(context, '/restos'),
          ),
          Consumer<AuthProvider>(
            builder: (context, auth, child) => auth.isLoggedIn
                ? IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      auth.logout();
                      Navigator.pushReplacementNamed(context, '/');
                    },
                  )
                : IconButton(
                    icon: const Icon(Icons.login),
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bienvenue sur la page d\'accueil',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Comparez les restaurants de la région Orléanaise',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Les Meilleurs restaurants',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 3 / 2,
                    ),
                    itemCount: bestRestaurants.length,
                    itemBuilder: (context, index) {
                      final restaurant = bestRestaurants[index];
                      return Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                restaurant['nom']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Adresse: ${restaurant['adresse']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
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
            const Footer(),
          ],
        ),
      ),
    );
  }
}