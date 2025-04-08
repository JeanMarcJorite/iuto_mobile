import 'package:flutter/material.dart';
import 'package:iuto_mobile/db/data/Critiques/critique.dart';
import 'package:iuto_mobile/db/supabase_service.dart';
import 'package:iuto_mobile/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:iuto_mobile/providers/critique_provider.dart';

class AccountCommentRestoPage extends StatefulWidget {
  const AccountCommentRestoPage({super.key});

  @override
  State<AccountCommentRestoPage> createState() =>
      _AccountCommentRestoPageState();
}

class _AccountCommentRestoPageState extends State<AccountCommentRestoPage> {
  late String _userId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _userId = userProvider.user['id']?.toString() ?? '';
    _loadUserCritiques();
  }

  Future<void> _loadUserCritiques() async {
    try {
      final provider = Provider.of<CritiqueProvider>(context, listen: false);
      provider.clearCritiques();
      await provider.loadCritiquesByUserId(_userId);
    } catch (e) {
      debugPrint('Erreur lors du chargement des commentaires: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteCritique(
      String critiqueId, CritiqueProvider provider) async {
    try {
      setState(() => _isLoading = true); 

      await SupabaseService.deleteCritique(critiqueId);

      provider.critiques.removeWhere((c) => c.id == critiqueId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Commentaire supprimé avec succès')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de la suppression: ${e.toString()}')),
        );
        await _loadUserCritiques();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Commentaires'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<CritiqueProvider>(
        builder: (context, provider, child) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }

          if (provider.critiques.isEmpty) {
            return const Center(
              child: Text('Vous n\'avez pas encore posté de commentaire'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: provider.critiques.length,
            itemBuilder: (context, index) {
              final critique = provider.critiques[index];
              return _buildCritiqueCard(critique, provider);
            },
          );
        },
      ),
    );
  }

  Widget _buildCritiqueCard(Critique critique, CritiqueProvider provider) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FutureBuilder<String>(
                  future: _getRestaurantName(critique.idR),
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.hasData
                          ? 'Restaurant: ${snapshot.data}'
                          : 'Restaurant: ${critique.idR}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    );
                  },
                ),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(critique.note.toString()),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              critique.commentaire,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Posté le ${critique.dateCritique.toLocal().toString().split(' ')[0]}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteDialog(critique.id, provider),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _getRestaurantName(int restaurantId) async {
    try {
      final restaurant =
          await SupabaseService.selectRestaurantById(restaurantId);
      return restaurant.nom;
    } catch (e) {
      debugPrint('Erreur lors de la récupération du nom du restaurant: $e');
      return restaurantId.toString();
    }
  }

  void _showDeleteDialog(String critiqueId, CritiqueProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le commentaire'),
        content:
            const Text('Êtes-vous sûr de vouloir supprimer ce commentaire ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCritique(critiqueId, provider);
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
