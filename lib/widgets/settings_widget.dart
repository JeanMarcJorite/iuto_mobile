import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? textColor;
  final Color? iconColor;

  const SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon,
          color: iconColor ?? theme.colorScheme.onSurface.withOpacity(0.8)),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: this.textColor ?? theme.colorScheme.onSurface,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      minLeadingWidth: 24,
    );
  }
}
