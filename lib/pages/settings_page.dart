import 'package:flutter/material.dart';
import 'package:iuto_mobile/db/auth_services.dart';
import 'package:go_router/go_router.dart';
import 'package:iuto_mobile/widgets/index.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _logout(BuildContext context) async {
    final authService = AuthServices();
    try {
      await authService.logOut();
      
        context.go('/login');
      
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la déconnexion : ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                SectionHeader(title: 'Compte'),
                SettingsTile(
                  icon: Icons.person_outline,
                  title: 'Modifier le profil',
                  onTap: () => context.push('/settings/profile/edit'),
                  trailing: Icon(Icons.chevron_right,
                      color: colors.onSurface.withOpacity(0.6)),
                ),
                SettingsTile(
                  icon: Icons.settings_outlined,
                  title: 'Paramètres avancés',
                  onTap: () => context.push('/settings/profile/advanced'),
                  trailing: Icon(Icons.chevron_right,
                      color: colors.onSurface.withOpacity(0.6)),
                ),
                const Divider(height: 1),
                SectionHeader(title: 'Application'),
                SettingsTile(
                  icon: Icons.info_outline,
                  title: 'À propos',
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: 'IUTO Mobile',
                    applicationVersion: '1.0.0',
                    applicationLegalese: '© 2025 IUTO Mobile',
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        'Application officielle de l\'IUTO',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                SectionHeader(title: 'Sécurité'),
                SettingsTile(
                  icon: Icons.logout,
                  title: 'Se déconnecter',
                  textColor: colors.error,
                  iconColor: colors.error,
                  onTap: () => _showLogoutConfirmation(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Version 1.0.0',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurface.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              context.pop();
              await _logout(context);
            },
            child: Text(
              'Confirmer',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
