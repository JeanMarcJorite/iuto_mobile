import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:iuto_mobile/db/iutoDB.dart';
import 'package:iuto_mobile/db/supabase_service.dart';

class CuisineSelectionPage extends StatefulWidget {
  const CuisineSelectionPage({super.key});

  @override
  State<CuisineSelectionPage> createState() => _CuisineSelectionPageState();
}

class _CuisineSelectionPageState extends State<CuisineSelectionPage> {
  late List<Map<String, dynamic>> _cuisines;
  final Set<int> _selectedCuisines = {};
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _fetchCuisines(),
        _loadPreferences(),
      ]);

      if (mounted) {
        setState(() {
          _cuisines = results[0] as List<Map<String, dynamic>>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      debugPrint('Error loading data: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchCuisines() async {
    try {
      final cuisines = await SupabaseService.selectTypeCuisine();
      return cuisines.map((c) => {'id': c.id, 'name': c.name}).toList();
    } catch (e) {
      debugPrint('Error fetching cuisines: $e');
      return [];
    }
  }

  Future<void> _loadPreferences() async {
    try {
      final db = Provider.of<IutoDB>(context, listen: false);
      final user = SupabaseService.supabase.auth.currentUser;

      if (user != null) {
        final preferences = await db.getPreferences(user.id);
        _selectedCuisines.addAll(preferences.map((p) => p.idCuisine));
      }
    } catch (e) {
      debugPrint('Error loading preferences: $e');
    }
  }

  void _toggleAllSelection(bool selectAll) {
    setState(() {
      if (selectAll) {
        _selectedCuisines.addAll(_cuisines.map((c) => c['id'] as int));
      } else {
        _selectedCuisines.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Préférences culinaires'),
        centerTitle: true,
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _isSaving ? null : () => _savePreferences(context),
            ),
        ],
      ),
      body: _buildContent(),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: FilledButton.icon(
          icon: const Icon(Icons.save),
          label: const Text('Enregistrer les préférences'),
          onPressed: _isSaving ? null : () => _savePreferences(context),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_cuisines.isEmpty) {
      return const Center(child: Text('Aucune cuisine disponible'));
    }

    final allSelected = _selectedCuisines.length == _cuisines.length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_selectedCuisines.length} sélectionné(s)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              TextButton(
                onPressed: () => _toggleAllSelection(!allSelected),
                child: Text(
                    allSelected ? 'Tout désélectionner' : 'Tout sélectionner'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _cuisines.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, index) => _buildCuisineItem(_cuisines[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildCuisineItem(Map<String, dynamic> cuisine) {
    return CheckboxListTile(
      title: Text(
        cuisine['name'],
        style: Theme.of(context).textTheme.titleMedium,
      ),
      value: _selectedCuisines.contains(cuisine['id']),
      onChanged: (bool? value) {
        if (value != null) {
          setState(() {
            value
                ? _selectedCuisines.add(cuisine['id'])
                : _selectedCuisines.remove(cuisine['id']);
          });
        }
      },
      secondary: Icon(
        Icons.restaurant,
        color: Theme.of(context).colorScheme.primary,
      ),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Future<void> _savePreferences(BuildContext context) async {
    if (!mounted) return;

    setState(() => _isSaving = true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final db = Provider.of<IutoDB>(context, listen: false);
      final user = SupabaseService.supabase.auth.currentUser;

      if (user == null) {
        throw 'Connectez-vous pour sauvegarder';
      }

      await db.deleteAllPreferences(user.id);

      for (final idCuisine in _selectedCuisines) {
        await db.insertPreference(user.id, idCuisine);
      }

      if (mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Préférences sauvegardées !'),
            duration: Duration(seconds: 2),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
