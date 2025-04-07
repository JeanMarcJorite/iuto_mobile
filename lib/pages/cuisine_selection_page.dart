import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iuto_mobile/db/iutoDB.dart';
import 'package:iuto_mobile/db/supabase_service.dart';
import 'package:provider/provider.dart';

class CuisineSelectionPage extends StatefulWidget {
  const CuisineSelectionPage({super.key});

  @override
  State<CuisineSelectionPage> createState() => _CuisineSelectionPageState();
}

class _CuisineSelectionPageState extends State<CuisineSelectionPage> {
  List<Map<String, dynamic>> _cuisines = [];
  final Set<int> _selectedCuisines = {};
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _fetchCuisines();
    await _loadPreferences();
  }

  Future<void> _fetchCuisines() async {
    try {
      final cuisines = await SupabaseService.selectTypeCuisine();

      debugPrint('Types de cuisine récupérés : $cuisines');
      setState(() {
        _cuisines = cuisines
            .map((cuisine) => {'id': cuisine.id, 'name': cuisine.name})
            .toList();
      });
    } catch (e) {
      debugPrint('Erreur lors de la récupération des types de cuisine : $e');
    }
  }

  Future<void> _loadPreferences() async {
    try {
      final db = Provider.of<IutoDB>(context, listen: false);

      final user = SupabaseService.supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non connecté.');
      }

      final userId = user.id;

      final preferences = await db.getPreferences(userId);

      setState(() {
        _selectedCuisines.addAll(preferences.map((p) => p.idCuisine));
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Erreur lors du chargement des préférences : $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sélectionner vos préférences culinaires'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _cuisines.length,
              itemBuilder: (context, index) {
                final cuisine = _cuisines[index];
                return CheckboxListTile(
                  title: Text(cuisine['name']),
                  value: _selectedCuisines.contains(cuisine['id']),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedCuisines.add(cuisine['id']);
                      } else {
                        _selectedCuisines.remove(cuisine['id']);
                      }
                    });
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _savePreferences(context);
        },
        child: const Icon(Icons.save),
      ),
    );
  }

  Future<void> _savePreferences(BuildContext context) async {
    final db = Provider.of<IutoDB>(context, listen: false);

    try {
      final user = SupabaseService.supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non connecté.');
      }

      final userId = user.id;

      await db.deleteAllPreferences(userId);

      for (final idCuisine in _selectedCuisines) {
        await db.insertPreference(userId, idCuisine);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Préférences sauvegardées !')),
      );
      context.pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : ${e.toString()}')),
      );
    }
  }
}
