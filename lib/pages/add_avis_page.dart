import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iuto_mobile/services/auth_services.dart';
import 'package:provider/provider.dart';
import 'package:iuto_mobile/providers/critique_provider.dart';
import 'package:iuto_mobile/db/models/critique.dart';

class AddAvisPage extends StatefulWidget {
  final int restaurantId;
  final String idCritique;

  const AddAvisPage(
      {super.key, required this.restaurantId, required this.idCritique});

  @override
  State<AddAvisPage> createState() => _AddAvisPageState();
}

class _AddAvisPageState extends State<AddAvisPage> {
  final TextEditingController _commentController = TextEditingController();
  int _selectedNote = 5;
  final AuthServices _authServices = AuthServices();

  Future<void> _submitAvis(BuildContext context) async {
    final userStream = _authServices.user;
    final user = await userStream.first;

    final critiqueProvider =
        Provider.of<CritiqueProvider>(context, listen: false);
    final comment = _commentController.text;

    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez écrire un commentaire.')),
      );
      return;
    }

    final newCritique = Critique(
      id: widget.idCritique,
      dateCritique: DateTime.now(),
      idU: user!.id,
      idR: widget.restaurantId,
      note: _selectedNote,
      commentaire: comment,
    );

    await critiqueProvider.addCritique(newCritique);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Avis ajouté avec succès !')),
    );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un avis'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Votre avis',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Écrivez votre commentaire ici...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Note',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButton<int>(
              value: _selectedNote,
              items: List.generate(5, (index) {
                final note = index + 1;
                return DropdownMenuItem(
                  value: note,
                  child: Text(note.toString()),
                );
              }),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedNote = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () => _submitAvis(context),
                child: const Text('Soumettre'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
