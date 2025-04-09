import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iuto_mobile/db/models/critique.dart';

class ReviewsSection extends StatelessWidget {
  final int restaurantId;
  final List<Critique> critiques;

  const ReviewsSection({
    super.key,
    required this.restaurantId,
    required this.critiques,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                "Avis récents",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () {
                context.push("/details/$restaurantId/avis");
              },
              child: Text(
                "Voir tous",
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        ),
        ...critiques.reversed.take(2).map((critique) => Card(
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              child: ListTile(
                leading: CircleAvatar(child: Text(critique.note.toString())),
                title: Text(critique.commentaire),
                subtitle: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 16),
                    Text(" ${critique.note}/5"),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}
