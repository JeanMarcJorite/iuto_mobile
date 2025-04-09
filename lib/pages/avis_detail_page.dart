import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iuto_mobile/providers/critique_provider.dart';

class AllReviewsPage extends StatelessWidget {
  final int restaurantId;

  const AllReviewsPage({super.key, required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    final critiqueProvider = Provider.of<CritiqueProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tous les avis'),
      ),
      body: critiqueProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : critiqueProvider.critiques.isEmpty
              ? const Center(
                  child: Text('Aucun avis disponible pour ce restaurant.'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: critiqueProvider.critiques.length,
                  itemBuilder: (context, index) {
                    final reversedCritiques =
                        critiqueProvider.critiques.reversed.toList();
                    final critique = reversedCritiques[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(critique.commentaire),
                        subtitle: Text(
                          "Note : ${critique.note} / 5",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        trailing: Text(
                          critique.dateCritique
                              .toLocal()
                              .toString()
                              .split(' ')[0],
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
