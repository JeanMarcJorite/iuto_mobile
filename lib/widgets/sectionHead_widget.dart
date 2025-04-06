import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}
