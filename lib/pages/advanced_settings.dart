import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

class AdvancedSettingsPage extends StatefulWidget {
  const AdvancedSettingsPage({super.key});

  @override
  State<AdvancedSettingsPage> createState() => _AdvancedSettingsPageState();
}

class _AdvancedSettingsPageState extends State<AdvancedSettingsPage> {
  bool _notificationsEnabled = false;
  bool _locationEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
      });
      await _checkLocationPermission();
    } catch (e) {
      _showErrorSnackbar('Erreur lors du chargement des paramètres');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _checkLocationPermission() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final userDisabled = prefs.getBool('localisation') == false;
      if (userDisabled) {
        if (mounted) {
          setState(() => _locationEnabled = false);
        }
        return;
      }

      final permission = await Geolocator.checkPermission();
      final granted = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;

      if (mounted) {
        setState(() => _locationEnabled = granted);
      }
      await prefs.setBool('localisation', granted);
    } catch (e) {
      _showErrorSnackbar('Erreur de vérification des permissions');
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', value);
      if (mounted) {
        setState(() => _notificationsEnabled = value);
      }
    } catch (e) {
      _showErrorSnackbar('Erreur de sauvegarde des paramètres');
    }
  }

  Future<void> _toggleLocation(bool value) async {
    if (!value) {
      final confirmed = await _showLocationDisableConfirmation();
      if (!confirmed) {
        if (mounted) {
          setState(() => _locationEnabled = true);
        }
        return;
      }
      await _disableLocation();
      return;
    }

    setState(() => _isLoading = true);
    try {
      final permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showErrorSnackbar('Autorisation de localisation refusée');
        return;
      }

      final granted = permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('localisation', granted);

      if (mounted) {
        setState(() => _locationEnabled = granted);
      }
    } catch (e) {
      _showErrorSnackbar('Erreur de permission de localisation');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool> _showLocationDisableConfirmation() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmer la désactivation'),
            content: const Text(
                'Êtes-vous sûr de vouloir désactiver la localisation ? Certaines fonctionnalités pourraient ne plus fonctionner correctement.'),
            actions: [
              TextButton(
                onPressed: () => context.pop(false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => context.pop(true),
                child: const Text('Confirmer',
                    style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _disableLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('localisation', false);
      if (mounted) {
        setState(() => _locationEnabled = false);
      }
    } catch (e) {
      _showErrorSnackbar('Erreur de désactivation');
    }
  }

  Future<void> _resetLocalData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (mounted) {
        setState(() {
          _notificationsEnabled = false;
          _locationEnabled = false;
        });
      }
      _showSuccessSnackbar('Données locales réinitialisées');
    } catch (e) {
      _showErrorSnackbar('Erreur de réinitialisation');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres Avancés'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildNotificationSwitch(),
                  const SizedBox(height: 20),
                  _buildLocationSwitch(),
                  const SizedBox(height: 20),
                  _buildResetButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildNotificationSwitch() {
    return Card(
      elevation: 2,
      child: SwitchListTile(
        title: const Text('Activer les Notifications'),
        subtitle: const Text('Recevoir des notifications importantes'),
        value: _notificationsEnabled,
        onChanged: _toggleNotifications,
      ),
    );
  }

  Widget _buildLocationSwitch() {
    return Card(
      elevation: 2,
      child: SwitchListTile(
        title: const Text('Activer la Localisation'),
        subtitle: const Text('Pour des fonctionnalités géolocalisées'),
        value: _locationEnabled,
        onChanged: _toggleLocation,
      ),
    );
  }

  Widget _buildResetButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.delete),
        label: const Text('Réinitialiser les Données Locales'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Confirmation'),
              content: const Text(
                  'Voulez-vous vraiment réinitialiser toutes les données locales ?'),
              actions: [
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Annuler'),
                ),
                TextButton(
                  onPressed: () {
                    context.pop();
                    _resetLocalData();
                  },
                  child: const Text('Confirmer',
                      style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
