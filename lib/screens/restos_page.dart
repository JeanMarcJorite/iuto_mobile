import 'package:flutter/material.dart';

class RestosPage extends StatelessWidget {
  const RestosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Restaurants')),
      body: const Center(child: Text('Liste des restaurants')),
    );
  }
}