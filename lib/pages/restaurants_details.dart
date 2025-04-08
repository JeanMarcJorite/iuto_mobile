import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:iuto_mobile/db/data/Critiques/critique.dart';
import 'package:iuto_mobile/db/data/Restaurants/restaurant.dart';
import 'package:iuto_mobile/providers/favoris_provider.dart';
import 'package:iuto_mobile/providers/geolocalisation_provider.dart';
import 'package:iuto_mobile/providers/image_provider.dart';
import 'package:iuto_mobile/providers/restaurant_provider.dart';
import 'package:iuto_mobile/providers/critique_provider.dart';
import 'package:iuto_mobile/widgets/index.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class RestaurantDetailsPage extends StatefulWidget {
  final int restaurantId;
  final String? previousPage;

  const RestaurantDetailsPage({
    super.key,
    required this.restaurantId,
    this.previousPage,
  });

  @override
  State<RestaurantDetailsPage> createState() => _RestaurantDetailsPageState();
}

class _RestaurantDetailsPageState extends State<RestaurantDetailsPage> {
  late StreamSubscription<Position> _positionSubscription;
  Restaurant? _restaurant;
  List<String> _imageUrls = [];
  List<Critique> _critiques = [];
  double _averageRating = 0;
  int _totalFavorites = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);

    final favorisProvider =
        Provider.of<FavorisProvider>(context, listen: false);
    favorisProvider.addListener(_updateFavoritesCount);
    final restaurantProvider =
        Provider.of<RestaurantProvider>(context, listen: false);
    await restaurantProvider.loadRestaurantById(widget.restaurantId);
    _restaurant = restaurantProvider.selectedRestaurant;

    final critiqueProvider =
        Provider.of<CritiqueProvider>(context, listen: false);
    await critiqueProvider.loadCritiquesByRestaurantId(widget.restaurantId);
    _critiques = critiqueProvider.critiques;
    _averageRating = critiqueProvider.noteMoyenne;

    try {
      final imagesProvider =
          Provider.of<ImagesProvider>(context, listen: false);
      await imagesProvider
          .fetchRestaurantImages(widget.restaurantId.toString());
      _imageUrls = imagesProvider.restaurantImages;
    } catch (e) {
      debugPrint('Erreur lors de la récupération des images : $e');
    }

    _setupLocationListener();
    setState(() => _isLoading = false);
  }

  void _updateFavoritesCount() {
    final favorisProvider =
        Provider.of<FavorisProvider>(context, listen: false);
    setState(() {
      _totalFavorites = favorisProvider.allFavoris
          .where((favori) => favori.idRestaurant == widget.restaurantId)
          .length;
    });
  }

  void _setupLocationListener() {
    final geoProvider =
        Provider.of<GeolocalisationProvider>(context, listen: false);

    _calculateDistance();

    _positionSubscription = geoProvider.positionStream.listen((_) {
      if (mounted) {
        _calculateDistance();
      }
    });
  }

  Future<void> _calculateDistance() async {
    final geoProvider =
        Provider.of<GeolocalisationProvider>(context, listen: false);
    final restaurantProvider =
        Provider.of<RestaurantProvider>(context, listen: false);

    if (_restaurant != null && geoProvider.currentPosition != null) {
      final distance = await geoProvider.calculerDistance(
        _restaurant!.latitude,
        _restaurant!.longitude,
      );

      if (mounted) {
        setState(() {
          _restaurant = _restaurant!
              .copyWith(distance: distance != null ? distance / 1000 : null);
          restaurantProvider.updateRestaurant(_restaurant!);
        });
      }
    }
  }

  @override
  void dispose() {
    _positionSubscription.cancel();
    final favorisProvider =
        Provider.of<FavorisProvider>(context, listen: false);
    favorisProvider.removeListener(_updateFavoritesCount);
    super.dispose();
  }

  void _showFullImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.9,
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const Icon(
                  Icons.broken_image,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Fermer'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_restaurant == null) {
      return const Center(child: Text('Restaurant non trouvé'));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 300,
              flexibleSpace: FlexibleSpaceBar(
                background: CachedNetworkImage(
                  imageUrl: _restaurant?.photo ??
                      'assets/images/restaurant_defaut_2.jpg',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Image.asset(
                    'assets/images/restaurant_defaut_2.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              pinned: true,
              leading: IconButton(
                icon: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.arrow_back, color: Colors.black),
                ),
                onPressed: () => widget.previousPage == 'map'
                    ? context.go('/home')
                    : context.pop(),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: LikeWidget(
                      restaurantId: _restaurant!.id,
                      showCount: false,
                    ),
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRestaurantHeader(_restaurant!),
                    _buildStatsRow(),
                    _buildActionButtons(context),
                    _buildOpeningStatusAndHours(_restaurant?.openingHours),
                    _buildImageGallerie(),
                    _buildCritiqueSection(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpeningStatusAndHours(String? openingHours) {
    if (openingHours == null || openingHours.isEmpty) {
      return const SizedBox.shrink();
    }

    final isOpen = _isRestaurantOpenNow(openingHours);
    final hours = _parseOpeningHours(openingHours);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isOpen
                ? Colors.green.withOpacity(0.2)
                : Colors.red.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isOpen ? Icons.check_circle : Icons.cancel,
                color: isOpen ? Colors.green : Colors.red,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                isOpen ? 'Ouvert maintenant' : 'Fermé maintenant',
                style: TextStyle(
                  color: isOpen ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const Text(
          'Horaires d\'ouverture',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...hours.map((day) => _buildDaySchedule(day)).toList(),
      ],
    );
  }

  Widget _buildDaySchedule(DaySchedule day) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              day.dayName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
                day.timeSlots.isEmpty ? 'Fermé' : day.timeSlots.join(', ')),
          ),
        ],
      ),
    );
  }

  bool _isRestaurantOpenNow(String openingHours) {
    final now = DateTime.now();
    final currentDay = now.weekday;
    final currentTime = TimeOfDay.fromDateTime(now);

    final schedules = _parseOpeningHours(openingHours);
    final todaySchedule = schedules.firstWhere(
      (schedule) => schedule.dayName == _getFrenchDayName(currentDay),
      orElse: () => DaySchedule('', []),
    );

    if (todaySchedule.timeSlots.isEmpty) return false;

    for (final slot in todaySchedule.timeSlots) {
      final times = slot.split('-');
      if (times.length != 2) continue;

      final startTime = _parseTime(times[0]);
      final endTime = _parseTime(times[1]);

      if (startTime == null || endTime == null) continue;

      if (_isTimeBetween(currentTime, startTime, endTime)) {
        return true;
      }
    }

    return false;
  }

  String _getFrenchDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Lundi';
      case DateTime.tuesday:
        return 'Mardi';
      case DateTime.wednesday:
        return 'Mercredi';
      case DateTime.thursday:
        return 'Jeudi';
      case DateTime.friday:
        return 'Vendredi';
      case DateTime.saturday:
        return 'Samedi';
      case DateTime.sunday:
        return 'Dimanche';
      default:
        return '';
    }
  }

  TimeOfDay? _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length != 2) return null;

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return null;
    }
  }

  bool _isTimeBetween(TimeOfDay current, TimeOfDay start, TimeOfDay end) {
    final nowMinutes = current.hour * 60 + current.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;

    return nowMinutes >= startMinutes && nowMinutes <= endMinutes;
  }

  List<DaySchedule> _parseOpeningHours(String openingHours) {
    final List<DaySchedule> schedules = [];
    final dayGroups = openingHours.split('; ');

    const dayNames = {
      'Mo': 'Lundi',
      'Tu': 'Mardi',
      'We': 'Mercredi',
      'Th': 'Jeudi',
      'Fr': 'Vendredi',
      'Sa': 'Samedi',
      'Su': 'Dimanche',
    };

    for (final group in dayGroups) {
      final parts = group.split(' ');
      if (parts.length < 2) continue;

      final dayRange = parts[0];
      final times = parts[1];

      if (dayRange.contains('-')) {
        final rangeParts = dayRange.split('-');
        if (rangeParts.length != 2) continue;

        final startDay = rangeParts[0];
        final endDay = rangeParts[1];

        final dayKeys = dayNames.keys.toList();
        final startIndex = dayKeys.indexOf(startDay);
        final endIndex = dayKeys.indexOf(endDay);

        if (startIndex != -1 && endIndex != -1) {
          for (int i = startIndex; i <= endIndex; i++) {
            final dayKey = dayKeys[i];
            schedules.add(DaySchedule(dayNames[dayKey]!, [times]));
          }
        }
      } else {
        schedules.add(DaySchedule(dayNames[dayRange]!, [times]));
      }
    }

    if (schedules.length < 7) {
      final existingDays = schedules.map((e) => e.dayName).toSet();
      for (final dayName in dayNames.values) {
        if (!existingDays.contains(dayName)) {
          schedules.add(DaySchedule(dayName, []));
        }
      }
    }

    schedules.sort((a, b) {
      final daysOrder = dayNames.values.toList();
      return daysOrder
          .indexOf(a.dayName)
          .compareTo(daysOrder.indexOf(b.dayName));
    });

    return schedules;
  }

  Widget _buildRestaurantIcons(Restaurant restaurant) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: [
        if (restaurant.internetAccess)
          const Tooltip(
            message: 'Wi-Fi disponible',
            child: Icon(Icons.wifi, size: 16, color: Colors.blue),
          ),
        if (restaurant.wheelchair)
          const Tooltip(
            message: 'Accessible PMR',
            child: Icon(Icons.accessible, size: 16, color: Colors.green),
          ),
        if (restaurant.vegetarian)
          const Tooltip(
            message: 'Options végétariennes',
            child: Icon(Icons.eco, size: 16, color: Colors.lightGreen),
          ),
        if (restaurant.vegan)
          const Tooltip(
            message: 'Options véganes',
            child: Icon(Icons.clear, size: 16, color: Colors.green),
          ),
        if (restaurant.delivery)
          const Tooltip(
            message: 'Livraison disponible',
            child: Icon(Icons.delivery_dining, size: 16, color: Colors.red),
          ),
        if (restaurant.takeaway)
          const Tooltip(
            message: 'À emporter',
            child: Icon(Icons.takeout_dining, size: 16, color: Colors.orange),
          ),
        if (restaurant.smoking)
          const Tooltip(
            message: 'Espace fumeur',
            child: Icon(Icons.smoking_rooms, size: 16, color: Colors.grey),
          ),
      ],
    );
  }

  Widget _buildRestaurantHeader(Restaurant restaurant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                restaurant.nom,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (restaurant.stars != null) ...[
              Icon(Icons.star, color: Colors.amber, size: 16),
              Text(
                restaurant.stars!.toStringAsFixed(1),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
        SizedBox(height: 8),
        _buildRestaurantIcons(restaurant),
        if (restaurant.distance != null)
          Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              '${restaurant.distance!.toStringAsFixed(1)} km',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            Icons.star,
            Colors.orange,
            "${_averageRating.toStringAsFixed(1)}/5",
          ),
          _buildStatItem(
            Icons.comment,
            Colors.blue,
            "${_critiques.length} avis",
          ),
          _buildStatItem(
            Icons.favorite,
            Colors.red,
            "$_totalFavorites",
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, Color color, String text) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.edit),
            label: const Text('Ajouter un avis'),
            onPressed: () {
              final idCritique = const Uuid().v4();
              context.push(
                "/details/${widget.restaurantId}/avis/add/$idCritique",
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add_a_photo),
            label: const Text('Ajouter photo'),
            onPressed: () {
              context.push("/details/${widget.restaurantId}/photo");
            },
          ),
        ),
      ],
    );
  }

  Widget _buildImageGallerie() {
    if (_imageUrls.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Center(child: Text('Aucune image disponible')),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Galerie photos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _imageUrls.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () => _showFullImage(_imageUrls[index]),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: _imageUrls[index],
                      width: 160,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 160,
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 160,
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image, size: 40),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCritiqueSection(BuildContext context) {
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
                context.push("/details/${widget.restaurantId}/avis");
              },
              child: Text(
                "Voir tous",
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        ),
        ..._critiques.reversed.take(2).map((critique) => Card(
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

class DaySchedule {
  final String dayName;
  final List<String> timeSlots;

  DaySchedule(this.dayName, this.timeSlots);
}
