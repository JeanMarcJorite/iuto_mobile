import 'package:flutter/material.dart';

class FiltersWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onApplyFilters;

  const FiltersWidget({super.key, required this.onApplyFilters});

  @override
  State<FiltersWidget> createState() => _FiltersWidgetState();
}

class _FiltersWidgetState extends State<FiltersWidget> {
  bool _internetAccess = false;
  bool _wheelchair = false;
  bool _vegetarian = false;
  bool _vegan = false;
  bool _delivery = false;
  bool _takeaway = false;
  bool _driveThrough = false;
  bool _smoking = false;

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
              value: _internetAccess,
              onChanged: (value) => setState(() => _internetAccess = value!),
            ),
            CheckboxListTile(
              title: const Text('Accès fauteuil roulant'),
              value: _wheelchair,
              onChanged: (value) => setState(() => _wheelchair = value!),
            ),
            CheckboxListTile(
              title: const Text('Végétarien'),
              value: _vegetarian,
              onChanged: (value) => setState(() => _vegetarian = value!),
            ),
            CheckboxListTile(
              title: const Text('Végan'),
              value: _vegan,
              onChanged: (value) => setState(() => _vegan = value!),
            ),
            CheckboxListTile(
              title: const Text('Livraison'),
              value: _delivery,
              onChanged: (value) => setState(() => _delivery = value!),
            ),
            CheckboxListTile(
              title: const Text('À emporter'),
              value: _takeaway,
              onChanged: (value) => setState(() => _takeaway = value!),
            ),
            CheckboxListTile(
              title: const Text('Drive-through'),
              value: _driveThrough,
              onChanged: (value) => setState(() => _driveThrough = value!),
            ),
            CheckboxListTile(
              title: const Text('Fumeur'),
              value: _smoking,
              onChanged: (value) => setState(() => _smoking = value!),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final filters = {
                  'internetAccess': _internetAccess,
                  'wheelchair': _wheelchair,
                  'isVegetarian': _vegetarian,
                  'isVegan': _vegan,
                  'delivery': _delivery,
                  'takeaway': _takeaway,
                  'driveThrough': _driveThrough,
                  'smoking': _smoking,
                };

                widget.onApplyFilters(filters);
                Navigator.pop(context);
              },
              child: const Text('Appliquer les filtres'),
            ),
          ],
        ),
      ),
    );
  }
}
