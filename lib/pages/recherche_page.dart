import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iuto_mobile/providers/restaurant_provider.dart';
import 'package:provider/provider.dart';
import 'package:iuto_mobile/widgets/restaurant_card.dart';

class RecherchePage extends StatefulWidget {
  const RecherchePage({super.key, required this.search});
  final String search;

  @override
  State<RecherchePage> createState() => _RecherchePageState();
}

class _RecherchePageState extends State<RecherchePage> {
  late final TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.search);
    _searchFocusNode = FocusNode();
    _initSearch();
  }

  Future<void> _initSearch() async {
    if (widget.search.isNotEmpty) {
      setState(() => _isSearching = true);
      Provider.of<RestaurantProvider>(context, listen: false)
          .setFilters({'searchQuery': widget.search});
      setState(() => _isSearching = false);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      Provider.of<RestaurantProvider>(context, listen: false).clearFilters();
      return;
    }

    setState(() => _isSearching = true);
    Provider.of<RestaurantProvider>(context, listen: false)
        .setFilters({'searchQuery': query});
    setState(() => _isSearching = false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: _buildSearchField(),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
          ),
        ],
      ),
      body: _buildSearchResults(theme, colors),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Rechercher un restaurant...',
        border: InputBorder.none,
        suffixIcon: _isSearching
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _performSearch(_searchController.text),
              ),
      ),
      onSubmitted: _performSearch,
      onChanged: (value) {
        if (value.isEmpty) {
          _performSearch('');
        }
      },
    );
  }

  Widget _buildSearchResults(ThemeData theme, ColorScheme colors) {
    final restaurantProvider = Provider.of<RestaurantProvider>(context);

    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (restaurantProvider.restaurants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: colors.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty
                  ? 'Entrez un terme de recherche'
                  : 'Aucun résultat pour "${_searchController.text}"',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.onSurface.withOpacity(0.6),
              ),
            ),
            if (_searchController.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Essayez avec d\'autres termes',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: Text(
              '${restaurantProvider.restaurants.length} résultat(s) trouvé(s)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: restaurantProvider.restaurants.length,
              separatorBuilder: (context, index) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final restaurant = restaurantProvider.restaurants[index];
                return RestaurantCard(
                  restaurant: restaurant,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
