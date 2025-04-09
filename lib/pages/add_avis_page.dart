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
  bool _isSubmitting = false;

  Future<void> _submitAvis(BuildContext context) async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final userStream = _authServices.user;
      final user = await userStream.first;

      final critiqueProvider =
          Provider.of<CritiqueProvider>(context, listen: false);
      final comment = _commentController.text.trim();

      if (comment.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez écrire un commentaire.'),
            behavior: SnackBarBehavior.floating,
          ),
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
        const SnackBar(
          content: Text('Avis ajouté avec succès !'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );

      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un avis'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Partagez votre expérience',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Notez ce restaurant',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                final note = index + 1;
                return IconButton(
                  icon: Icon(
                    note <= _selectedNote ? Icons.star : Icons.star_border,
                    size: 36,
                    color: note <= _selectedNote ? Colors.amber : Colors.grey,
                  ),
                  onPressed: () => setState(() => _selectedNote = note),
                );
              }),
            ),
            const SizedBox(height: 24),

            Text(
              'Votre commentaire',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              maxLines: 5,
              minLines: 3,
              decoration: InputDecoration(
                hintText:
                    'Décrivez votre expérience (nourriture, service, ambiance...)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.dividerColor),
                ),
                filled: true,
                fillColor: theme.cardTheme.color,
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : () => _submitAvis(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      )
                    : const Text(
                        'Publier mon avis',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
