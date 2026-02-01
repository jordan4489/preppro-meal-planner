import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/recipe_loader.dart';
import '../../core/models/recipe.dart';
import '../../core/services/profile_service.dart';
import '../../core/services/favorites_service.dart';
import '../../widgets/recipe_card.dart';

class RecipesPage extends StatefulWidget {
  final Map<String, dynamic>? filter;
  const RecipesPage({super.key, this.filter});
  @override
  State<RecipesPage> createState() => _S();
}

class _S extends State<RecipesPage> {
  bool loading = true;
  List<Recipe> all = [];
  String _query = '';
  bool _airOnly = false;
  final Set<String> _mealTypes = {};
  final Set<String> _tags = {};
  final Set<String> _prefProteins = {};
  final Set<String> _dietary = {};
  bool _favoritesOnly = false;
  int _minK = 0, _maxK = 1200, _lo = 0, _hi = 1200;
  double _pFloor = 0;
  @override
  void initState() {
    super.initState();
    _load();
    favoritesService.load();
  }

  String _proteinOf(Recipe r) {
    final hay = (r.title +
            ' ' +
            r.tags.join(' ') +
            ' ' +
            (r.ingredients ?? []).map((e) => e.name).join(' '))
        .toLowerCase();
    bool has(List<String> k) => k.any((x) => hay.contains(x));
    if (has(['chicken'])) return 'chicken';
    if (has(['turkey'])) return 'turkey';
    if (has(['beef'])) return 'beef';
    if (has(['lamb'])) return 'lamb';
    if (has(['pork'])) return 'pork';
    if (has(['egg', 'eggs'])) return 'eggs';
    if (has(['tofu', 'tempeh'])) return 'tofu/tempeh';
    if (has([
      'salmon',
      'cod',
      'tuna',
      'mackerel',
      'haddock',
      'bass',
      'trout',
      'sardine'
    ])) return 'fish';
    if (has(
        ['prawn', 'prawns', 'shrimp', 'scallop', 'crab', 'lobster', 'seafood']))
      return 'seafood';
    if (has(['vegan', 'vegetarian', 'veggie', 'plant'])) return 'veggie';
    return 'veggie';
  }

  Future<void> _load() async {
    setState(() => loading = true);
    all = await RecipeLoader.load();
    if (all.isNotEmpty) {
      final ks = all.map((r) => r.nutritionKcal);
      _minK = ks.reduce((a, b) => a < b ? a : b);
      _maxK = ks.reduce((a, b) => a > b ? a : b);
      _lo = _minK;
      _hi = _maxK;
    }
    final Map<String, Object> savedFilters = {
      'airOnly': false,
      'kcalLo': _lo,
      'kcalHi': _hi,
      'proteinFloor': 0.0,
      'mealTypes': <String>{},
      'tags': <String>{}
    };

    _airOnly = (savedFilters['airOnly'] as bool?) ?? false;
    _lo = (savedFilters['kcalLo'] as int?) ?? _lo;
    _hi = (savedFilters['kcalHi'] as int?) ?? _hi;
    _pFloor = (savedFilters['proteinFloor'] as double?) ?? 0.0;
    _mealTypes
      ..clear()
      ..addAll((savedFilters['mealTypes'] as Set<String>?) ?? <String>{});
    _tags
      ..clear()
      ..addAll((savedFilters['tags'] as Set<String>?) ?? <String>{});

    final savedPref = await ProfileService.loadPreferredProteins();
    _prefProteins
      ..clear()
      ..addAll(savedPref);
    final f = widget.filter ?? {};
    if (f['airFryerOnly'] == true) _airOnly = true;
    if (f['mealType'] != null)
      _mealTypes.add(f['mealType'].toString().toLowerCase());
    if (f['tag'] != null) _tags.add(f['tag'].toString().toLowerCase());
    setState(() => loading = false);
  }

  List<Recipe> _apply() {
    var s = [...all];
    if (_airOnly) s = s.where((r) => r.isAirFryer).toList();
    if (_mealTypes.isNotEmpty) {
      s = s.where((r) {
        final mt = r.mealTypes.map((e) => e.toLowerCase());
        return _mealTypes.any(mt.contains);
      }).toList();
    }
    if (_tags.isNotEmpty) {
      s = s.where((r) {
        final tg = r.tags.map((e) => e.toLowerCase());
        return _tags.any(tg.contains);
      }).toList();
    }
    s = s
        .where((r) =>
            r.nutritionKcal >= _lo &&
            r.nutritionKcal <= _hi &&
            r.nutritionProtein >= _pFloor)
        .toList();
    if (_prefProteins.isNotEmpty)
      s = s.where((r) => _prefProteins.contains(_proteinOf(r))).toList();
    // Apply favorites filter
    if (_favoritesOnly) {
      s = s.where((r) => favoritesService.isFavorite(r.title)).toList();
    }
    // Apply dietary requirements filter
    if (_dietary.isNotEmpty) {
      s = s.where((r) {
        final titleLower = r.title.toLowerCase();
        final tagsLower = r.tags.map((e) => e.toLowerCase()).toList();
        final ingredientsLower = (r.ingredients ?? [])
            .map((e) => e.name.toLowerCase())
            .join(' ');
        final combined = '$titleLower ${tagsLower.join(' ')} $ingredientsLower';
        
        return _dietary.every((diet) {
          switch (diet) {
            case 'vegetarian':
              return !combined.contains('chicken') &&
                  !combined.contains('beef') &&
                  !combined.contains('pork') &&
                  !combined.contains('lamb') &&
                  !combined.contains('fish') &&
                  !combined.contains('seafood') &&
                  !combined.contains('turkey');
            case 'vegan':
              return !combined.contains('chicken') &&
                  !combined.contains('beef') &&
                  !combined.contains('pork') &&
                  !combined.contains('lamb') &&
                  !combined.contains('fish') &&
                  !combined.contains('seafood') &&
                  !combined.contains('turkey') &&
                  !combined.contains('egg') &&
                  !combined.contains('milk') &&
                  !combined.contains('cheese') &&
                  !combined.contains('yogurt') &&
                  !combined.contains('cream') &&
                  !combined.contains('butter');
            case 'gluten-free':
              return !combined.contains('bread') &&
                  !combined.contains('pasta') &&
                  !combined.contains('flour') &&
                  !combined.contains('wheat') &&
                  !combined.contains('noodle');
            case 'dairy-free':
              return !combined.contains('milk') &&
                  !combined.contains('cheese') &&
                  !combined.contains('yogurt') &&
                  !combined.contains('cream') &&
                  !combined.contains('butter');
            case 'low-carb':
              return r.nutritionKcal > 0 &&
                  ((r.nutritionProtein * 4) / r.nutritionKcal) > 0.3;
            case 'halal':
              return !combined.contains('pork') &&
                  !combined.contains('bacon') &&
                  !combined.contains('ham') &&
                  !combined.contains('alcohol') &&
                  !combined.contains('wine') &&
                  !combined.contains('beer') &&
                  !combined.contains('liquor');
            case 'kosher':
              return !combined.contains('pork') &&
                  !combined.contains('bacon') &&
                  !combined.contains('ham') &&
                  !combined.contains('shrimp') &&
                  !combined.contains('prawn') &&
                  !combined.contains('crab') &&
                  !combined.contains('lobster') &&
                  !combined.contains('scallop') &&
                  !combined.contains('shellfish');
            default:
              return true;
          }
        });
      }).toList();
    }
    if (_query.trim().isNotEmpty) {
      final q = _query.toLowerCase();
      s = s.where((r) => r.title.toLowerCase().contains(q)).toList();
    }
    return s;
  }

  void _openDietarySelector() {
    showModalBottomSheet(
        context: context,
        showDragHandle: true,
        builder: (ctx) {
          final local = Set<String>.from(_dietary);
          final dietaryOptions = [
            'vegetarian',
            'vegan',
            'gluten-free',
            'dairy-free',
            'low-carb',
            'halal',
            'kosher'
          ];
          return StatefulBuilder(
              builder: (c, setM) => Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Row(
                      children: [
                        const Icon(Icons.restaurant_menu, size: 20),
                        const SizedBox(width: 8),
                        const Text('Dietary Requirements',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: dietaryOptions
                            .map((d) => FilterChip(
                                label: Text(
                                    d.split('-').map((w) => w[0].toUpperCase() + w.substring(1)).join(' '),
                                    style: const TextStyle(fontSize: 15)),
                                selected: local.contains(d),
                                onSelected: (s) => setM(
                                    () => s ? local.add(d) : local.remove(d))))
                            .toList()),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                          child: FilledButton.icon(
                              onPressed: () {
                                setState(() {
                                  _dietary
                                    ..clear()
                                    ..addAll(local);
                                });
                                if (mounted) {
                                  Navigator.pop(context);
                                }
                              },
                              icon: const Icon(Icons.check),
                              label: const Text('Apply')))
                    ])
                  ])));
        });
  }

  void _openFilters() {
    showModalBottomSheet(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (ctx) {
          var localAirOnly = _airOnly;
          var localFavoritesOnly = _favoritesOnly;
          var localDietary = Set<String>.from(_dietary);
          final dietaryOptions = [
            'vegetarian',
            'vegan',
            'gluten-free',
            'dairy-free',
            'low-carb',
            'halal',
            'kosher'
          ];
          return StatefulBuilder(
              builder: (c, setM) => Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Filters',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold))),
                      const SizedBox(height: 16),
                      SwitchListTile(
                          title: const Text('Air fryer only'),
                          value: localAirOnly,
                          onChanged: (v) => setM(() => localAirOnly = v)),
                      SwitchListTile(
                          title: const Row(
                            children: [
                              Icon(Icons.favorite, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Favorites only'),
                            ],
                          ),
                          value: localFavoritesOnly,
                          onChanged: (v) => setM(() => localFavoritesOnly = v)),
                      const Divider(),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            const Icon(Icons.restaurant_menu, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Dietary Requirements',
                              style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: dietaryOptions.map((diet) {
                          final isSelected = localDietary.contains(diet);
                          return FilterChip(
                            label: Text(
                              diet.split('-').map((w) => w[0].toUpperCase() + w.substring(1)).join(' '),
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              setM(() {
                                if (selected) {
                                  localDietary.add(diet);
                                } else {
                                  localDietary.remove(diet);
                                }
                              });
                            },
                            selectedColor: Theme.of(ctx).colorScheme.primaryContainer,
                            checkmarkColor: Theme.of(ctx).colorScheme.primary,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(
                            child: FilledButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _airOnly = localAirOnly;
                                    _favoritesOnly = localFavoritesOnly;
                                    _dietary
                                      ..clear()
                                      ..addAll(localDietary);
                                  });
                                  Navigator.pop(ctx);
                                },
                                icon: const Icon(Icons.check),
                                label: const Text('Apply'))),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _airOnly = false;
                                _favoritesOnly = false;
                                _dietary.clear();
                              });
                              Navigator.pop(ctx);
                            },
                            icon: const Icon(Icons.clear),
                            label: const Text('Reset'))
                      ])
                    ]),
                  ));
        });
  }

  @override
  Widget build(BuildContext c) {
    final shown = _apply();
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => GoRouter.of(c).go('/home'),
          ),
          title: TextField(
            decoration: InputDecoration(
              hintText: 'Search recipes...',
              hintStyle: TextStyle(color: Theme.of(c).colorScheme.onSurfaceVariant),
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.restaurant_menu),
              tooltip: 'Dietary requirements',
              onPressed: () => _openDietarySelector(),
            ),
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.filter_alt),
                  tooltip: 'Filters',
                  onPressed: _openFilters,
                ),
                if (_dietary.isNotEmpty || _airOnly || _favoritesOnly)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(c).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${_dietary.length + (_airOnly ? 1 : 0) + (_favoritesOnly ? 1 : 0)}',
                        style: TextStyle(
                          color: Theme.of(c).colorScheme.onPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ]),
        body: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.05,
                child: Transform.scale(
                  scale: 0.6,
                  child: Image.asset(
                    'assets/images/PrepProBlue.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder: (_, __, ___) => const SizedBox(),
                  ),
                ),
              ),
            ),
            loading
                ? const Center(child: CircularProgressIndicator())
                : (shown.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 80,
                                color: Theme.of(c).colorScheme.primary.withOpacity(0.3),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'No Recipes Found',
                                style: Theme.of(c).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Try adjusting your filters or search terms.',
                                textAlign: TextAlign.center,
                                style: Theme.of(c).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: shown.length,
                        itemBuilder: (_, i) {
                          final r = shown[i];
                          return RecipeCard(recipe: r, onTap: () => GoRouter.of(c).push('/recipe/${r.id}'));
                        }))
          ],
        ));
  }
}
