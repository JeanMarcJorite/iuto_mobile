import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[200],
      child: const Center(
        child: Text('© 2025 IUTables’O - Jean-Marc Jorite / Enzo Familiar-Marais / Romain Lima / Mohammed-Amine Yahyaoui '),
      ),
    );
  }
}