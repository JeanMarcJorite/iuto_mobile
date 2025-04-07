import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iuto_mobile/providers/restaurant_provider.dart';

class FiltersWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onApplyFilters;
  final Map<String, dynamic> initialFilters;

  const FiltersWidget({
    super.key,
    required this.onApplyFilters,
    required this.initialFilters,
  });

  @override
  State<FiltersWidget> createState() => _FiltersWidgetState();
}

class _FiltersWidgetState extends State<FiltersWidget> {
  late Map<String, dynamic> _filters;

  @override
  void initState() {
    super.initState();
    _filters = Map.from(widget.initialFilters);
    
    // S'assurer que tous les filtres booléens existent
    _filters.putIfAbsent('internetAccess', () => false);
    _filters.putIfAbsent('wheelchair', () => false);
    _filters.putIfAbsent('isVegetarian', () => false);
    _filters.putIfAbsent('isVegan', () => false);
    _filters.putIfAbsent('delivery', () => false);
    _filters.putIfAbsent('takeaway', () => false);
    _filters.putIfAbsent('driveThrough', () => false);
    _filters.putIfAbsent('smoking', () => false);
    
    debugPrint("Filtres initiaux: $_filters");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Filtres',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Accès Internet'),
              value: _filters['internetAccess'] == true,
              onChanged: (value) => setState(() => _filters['internetAccess'] = value ?? false),
            ),
            CheckboxListTile(
              title: const Text('Accès fauteuil roulant'),
              value: _filters['wheelchair'] == true,
              onChanged: (value) => setState(() => _filters['wheelchair'] = value ?? false),
            ),
            CheckboxListTile(
              title: const Text('Végétarien'),
              value: _filters['isVegetarian'] == true,
              onChanged: (value) => setState(() => _filters['isVegetarian'] = value ?? false),
            ),
            CheckboxListTile(
              title: const Text('Végan'),
              value: _filters['isVegan'] == true,
              onChanged: (value) => setState(() => _filters['isVegan'] = value ?? false),
            ),
            CheckboxListTile(
              title: const Text('Livraison'),
              value: _filters['delivery'] == true,
              onChanged: (value) => setState(() => _filters['delivery'] = value ?? false),
            ),
            CheckboxListTile(
              title: const Text('À emporter'),
              value: _filters['takeaway'] == true,
              onChanged: (value) => setState(() => _filters['takeaway'] = value ?? false),
            ),
            CheckboxListTile(
              title: const Text('Drive-through'),
              value: _filters['driveThrough'] == true,
              onChanged: (value) => setState(() => _filters['driveThrough'] = value ?? false),
            ),
            CheckboxListTile(
              title: const Text('Fumeur'),
              value: _filters['smoking'] == true,
              onChanged: (value) => setState(() => _filters['smoking'] = value ?? false),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _filters['internetAccess'] = false;
                      _filters['wheelchair'] = false;
                      _filters['isVegetarian'] = false;
                      _filters['isVegan'] = false;
                      _filters['delivery'] = false;
                      _filters['takeaway'] = false;
                      _filters['driveThrough'] = false;
                      _filters['smoking'] = false;
                    });
                  },
                  child: const Text('Réinitialiser'),
                ),
                ElevatedButton(
                  onPressed: () {
                    debugPrint("Filtres appliqués: $_filters");
                    widget.onApplyFilters(_filters);
                    
                    bool hasActiveFilters = _filters.entries
                        .where((entry) => entry.key != 'searchQuery')
                        .any((entry) => entry.value == true);
                    
                    if (hasActiveFilters) {
                      Future.delayed(const Duration(milliseconds: 300), () {
                        final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);
                        
                        if (restaurantProvider.restaurants.isEmpty || 
                            (restaurantProvider.hasActiveFilters && restaurantProvider.hasNoResults)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Aucun restaurant trouvé avec ce(s) filtre(s)'),
                              duration: Duration(seconds: 3),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      });
                    }
                    
                    Navigator.pop(context);
                  },
                  child: const Text('Appliquer les filtres'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
