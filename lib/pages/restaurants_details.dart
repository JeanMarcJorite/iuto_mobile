import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:iuto_mobile/db/models/critique.dart';
import 'package:iuto_mobile/db/models/restaurant.dart';
import 'package:iuto_mobile/providers/favoris_provider.dart';
import 'package:iuto_mobile/providers/geolocalisation_provider.dart';
import 'package:iuto_mobile/providers/image_provider.dart';
import 'package:iuto_mobile/providers/restaurant_provider.dart';
import 'package:iuto_mobile/providers/critique_provider.dart';
import 'package:iuto_mobile/widgets/index.dart';
import 'package:provider/provider.dart';

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
                    RestaurantHeader(restaurant: _restaurant!),
                    StatsRow(
                      averageRating: _averageRating,
                      reviewsCount: _critiques.length,
                      favoritesCount: _totalFavorites,
                    ),
                    const SizedBox(height: 16),
                    ActionButtonsRestoDetail(restaurantId: widget.restaurantId),
                    const SizedBox(height: 16),
                    OpeningHoursSection(
                        openingHours: _restaurant?.openingHours),
                    ImageGallery(imageUrls: _imageUrls),
                    ReviewsSection(
                      restaurantId: widget.restaurantId,
                      critiques: _critiques,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
