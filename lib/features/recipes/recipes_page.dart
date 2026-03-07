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
  final Set<String> _excludedAllergens = {};
  final Set<String> _excludedIngredients = {};
  final TextEditingController ingredientController = TextEditingController();
  bool _favoritesOnly = false;
  int _minK = 0, _maxK = 1200, _lo = 0, _hi = 1200;
  double _pFloor = 0;

  static const _fishKeywords = [
    'fish',
    'salmon',
    'cod',
    'tuna',
    'mackerel',
    'haddock',
    'bass',
    'sea bass',
    'seabass',
    'trout',
    'sardine',
    'sardines',
    'tilapia',
    'halibut',
    'snapper',
    'mahi',
    'mahi-mahi',
    'swordfish',
    'catfish',
    'pollock',
    'hake',
    'sole',
    'anchovy',
    'anchovies',
    'herring'
  ];
  static const _seafoodKeywords = [
    'prawn',
    'prawns',
    'shrimp',
    'scallop',
    'crab',
    'lobster',
    'seafood',
    'mussel',
    'mussels',
    'clam',
    'clams',
    'octopus',
    'squid',
    'calamari'
  ];
  static const _dairyKeywords = [
    'milk',
    'cheese',
    'cream',
    'butter',
    'yogurt',
    'yoghurt',
    'ghee',
    'whey',
    'casein',
    'curd',
    'paneer',
    'ricotta',
    'mozzarella',
    'parmesan',
    'cheddar',
    'feta',
    'halloumi',
    'sour cream',
    'cream cheese',
    'creme',
    'crème'
  ];
  static const _glutenKeywords = [
    'bread',
    'pasta',
    'flour',
    'wheat',
    'noodle',
    'breadcrumbs',
    'couscous',
    'semolina',
    'bulgur',
    'farro',
    'spelt',
    'rye',
    'barley',
    'malt'
  ];
  static const _meatKeywords = [
    'chicken',
    'beef',
    'pork',
    'lamb',
    'turkey',
    'bacon',
    'ham',
    'sausage',
    'fish',
    'seafood',
    'prawn',
    'prawns',
    'shrimp',
    'crab',
    'lobster',
    'scallop',
    'mussel',
    'mussels',
    'clam',
    'clams',
    'octopus',
    'squid',
    'calamari',
    'tuna',
    'salmon',
    'cod',
    'anchovy',
    'anchovies',
    'sardine',
    'sardines',
    'tilapia',
    'halibut',
    'snapper',
    'mahi',
    'mahi-mahi',
    'swordfish',
    'catfish',
    'pollock',
    'haddock',
    'trout',
    'mackerel',
    'herring'
  ];
  @override
  void initState() {
    super.initState();
    _load();
    favoritesService.load();
  }

  String _proteinOf(Recipe r) {
    final hay = _recipeHaystack(r);
    bool has(List<String> k) => k.any((x) => hay.contains(x));
    if (has(['chicken'])) return 'chicken';
    if (has(['turkey'])) return 'turkey';
    if (has(['beef'])) return 'beef';
    if (has(['lamb'])) return 'lamb';
    if (has(['pork'])) return 'pork';
    if (has(['egg', 'eggs'])) return 'eggs';
    if (has(['tofu', 'tempeh'])) return 'tofu/tempeh';
    if (has(_fishKeywords)) return 'fish';
    if (has(_seafoodKeywords))
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
      s = s.where((r) {
        final p = _proteinOf(r);
        if (_prefProteins.contains(p)) return false;
        final hay = _recipeHaystack(r);
        if (_prefProteins.contains('tuna') && hay.contains('tuna')) return false;
        if (_prefProteins.contains('salmon') && hay.contains('salmon')) return false;
        if (_prefProteins.contains('tofu/tempeh') && (hay.contains('tofu') || hay.contains('tempeh'))) return false;
        if (_prefProteins.contains('fish') && _fishKeywords.any((k) => hay.contains(k))) return false;
        if (_prefProteins.contains('seafood') && _seafoodKeywords.any((k) => hay.contains(k))) return false;
        if (_prefProteins.contains('veggie') && (hay.contains('veggie') || hay.contains('plant'))) return false;
        return true;
      }).toList();
    // Apply favorites filter
    if (_favoritesOnly) {
      s = s.where((r) => favoritesService.isFavorite(r.title)).toList();
    }
    // Apply dietary requirements filter
    if (_dietary.isNotEmpty) {
      s = s.where((r) {
        final titleLower = r.title.toLowerCase();
        final displayTitleLower = r.displayTitle.toLowerCase();
        final tagsLower = r.tags.map((e) => e.toLowerCase()).toList();
        final ingredientsLower = (r.ingredients ?? [])
            .map((e) => e.name.toLowerCase())
            .join(' ');
        final combined = '$titleLower $displayTitleLower ${tagsLower.join(' ')} $ingredientsLower';
        bool hasAny(List<String> k) => k.any((x) => combined.contains(x));
        bool hasAllergen(String a) => r.allergens.contains(a);
        return _dietary.every((diet) {
          switch (diet) {
            case 'vegetarian':
              return !hasAny(_meatKeywords);
            case 'vegan':
              return !hasAny(_meatKeywords) &&
                  !hasAny(_dairyKeywords) &&
                  !hasAllergen('dairy') &&
                  !hasAllergen('egg') &&
                  !hasAllergen('fish') &&
                  !hasAllergen('shellfish') &&
                  !combined.contains('egg') &&
                  !combined.contains('honey') &&
                  !combined.contains('gelatin');
            case 'gluten-free':
              return !hasAny(_glutenKeywords) && !hasAllergen('gluten');
            case 'dairy-free':
              return !hasAny(_dairyKeywords) && !hasAllergen('dairy');
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
    // Exclude recipes with selected allergens
    if (_excludedAllergens.isNotEmpty) {
      s = s.where((r) => _excludedAllergens.intersection(r.allergens).isEmpty).toList();
    }
    // Exclude recipes with selected ingredients (case-insensitive)
    if (_excludedIngredients.isNotEmpty) {
      final lowerExcluded = _excludedIngredients.map((e) => e.toLowerCase()).toList();
      s = s.where((r) {
        final lowerIngredients = (r.ingredients ?? [])
            .map((e) => e.name.toLowerCase())
            .toList();
        // Exclude recipe if any ingredient contains any excluded ingredient as substring
        return !lowerExcluded.any(
          (ex) => lowerIngredients.any((ing) => ing.contains(ex)),
        );
      }).toList();
    }
    if (_query.trim().isNotEmpty) {
      final q = _query.toLowerCase();
      s = s.where((r) => r.displayTitle.toLowerCase().contains(q)).toList();
    }
    return s;
  }

  String _recipeHaystack(Recipe r) {
        return (r.title +
          ' ' +
          r.displayTitle +
            ' ' +
            r.tags.join(' ') +
            ' ' +
            (r.ingredients ?? []).map((e) => e.name).join(' '))
        .toLowerCase();
  }

  void _openDietarySelector() {
    showModalBottomSheet(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
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
              builder: (c, setM) => DraggableScrollableSheet(
                expand: false,
                builder: (context, scrollController) => SafeArea(
                  child: ListView(
                    controller: scrollController,
                    padding: EdgeInsets.fromLTRB(
                        16, 8, 16, 16 + MediaQuery.of(ctx).viewInsets.bottom),
                    children: [
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
                    ],
                  ),
                ),
              ));
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
    final List<String> commonAllergens = [
      'nuts', 'dairy', 'egg', 'gluten', 'soy', 'fish', 'shellfish', 'sesame', 'mustard', 'celery', 'peanut', 'sulphite', 'lupin', 'mollusc'
    ];
    // ...existing code...
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
              if (_dietary.isNotEmpty || _airOnly || _favoritesOnly || _excludedAllergens.isNotEmpty || _excludedIngredients.isNotEmpty || _prefProteins.isNotEmpty || _mealTypes.isNotEmpty)
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
                      '${_dietary.length + (_airOnly ? 1 : 0) + (_favoritesOnly ? 1 : 0) + _excludedAllergens.length + _excludedIngredients.length + _prefProteins.length + _mealTypes.length}',
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
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active filters summary row (single-line, horizontally scrollable)
          if (_dietary.isNotEmpty || _airOnly || _favoritesOnly || _excludedAllergens.isNotEmpty || _excludedIngredients.isNotEmpty || _prefProteins.isNotEmpty || _mealTypes.isNotEmpty)
            SizedBox(
              height: 40,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Filters:', style: Theme.of(c).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 4),
                    // Dietary
                    ..._dietary.map((d) {
                      final label = d
                          .split('-')
                          .map((w) => w.isEmpty ? w : (w[0].toUpperCase() + w.substring(1)))
                          .join(' ');
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: InputChip(
                          label: Text(label),
                          onDeleted: () => setState(() => _dietary.remove(d)),
                        ),
                      );
                    }),
                    // Meal types
                    ..._mealTypes.map((mt) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: InputChip(
                            label: Text(mt[0].toUpperCase() + mt.substring(1)),
                            onDeleted: () => setState(() => _mealTypes.remove(mt)),
                          ),
                        )),
                    // Proteins
                    ..._prefProteins.map((p) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: InputChip(
                            label: Text(p),
                            onDeleted: () => setState(() => _prefProteins.remove(p)),
                          ),
                        )),
                    // Allergens
                    ..._excludedAllergens.map((a) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: InputChip(
                            label: Text('No $a'),
                            onDeleted: () => setState(() => _excludedAllergens.remove(a)),
                          ),
                        )),
                    // Ingredients
                    ..._excludedIngredients.map((ing) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: InputChip(
                            label: Text(ing),
                            onDeleted: () => setState(() => _excludedIngredients.remove(ing)),
                          ),
                        )),
                    // Air fryer & favourites toggles
                    if (_airOnly)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: InputChip(
                          label: const Text('Air fryer only'),
                          onDeleted: () => setState(() => _airOnly = false),
                        ),
                      ),
                    if (_favoritesOnly)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: InputChip(
                          label: const Text('Favourites only'),
                          onDeleted: () => setState(() => _favoritesOnly = false),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: ActionChip(
                        label: const Text('Clear all'),
                        avatar: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          setState(() {
                            _dietary.clear();
                            _mealTypes.clear();
                            _prefProteins.clear();
                            _excludedAllergens.clear();
                            _excludedIngredients.clear();
                            _airOnly = false;
                            _favoritesOnly = false;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Meal type filter row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                const Text('Meal type: ', style: TextStyle(fontWeight: FontWeight.w600)),
                ...['breakfast', 'snack', 'lunch', 'dinner'].map((mt) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: FilterChip(
                    label: Text(mt[0].toUpperCase() + mt.substring(1)),
                    selected: _mealTypes.contains(mt),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _mealTypes.add(mt);
                        } else {
                          _mealTypes.remove(mt);
                        }
                      });
                    },
                  ),
                )),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                const Text('Exclude proteins: ', style: TextStyle(fontWeight: FontWeight.w600)),
                ...['chicken','turkey','beef','lamb','pork','eggs','fish','seafood','tofu/tempeh','veggie'].map((p) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: FilterChip(
                    label: Text(p),
                    selected: _prefProteins.contains(p),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _prefProteins.add(p);
                        } else {
                          _prefProteins.remove(p);
                        }
                      });
                    },
                  ),
                )),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                const Text('Exclude allergens: ', style: TextStyle(fontWeight: FontWeight.w600)),
                ...commonAllergens.map((a) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: FilterChip(
                    label: Text(a),
                    selected: _excludedAllergens.contains(a),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _excludedAllergens.add(a);
                        } else {
                          _excludedAllergens.remove(a);
                        }
                      });
                    },
                  ),
                )),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Row(
              children: [
                const Text('Exclude ingredient: ', style: TextStyle(fontWeight: FontWeight.w600)),
                Expanded(
                  child: TextField(
                    controller: ingredientController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. cottage cheese',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    ),
                    onSubmitted: (val) {
                      final v = val.trim().toLowerCase();
                      if (v.isNotEmpty && !_excludedIngredients.contains(v)) {
                        setState(() {
                          _excludedIngredients.add(v);
                        });
                      }
                      ingredientController.clear();
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    final v = ingredientController.text.trim().toLowerCase();
                    if (v.isNotEmpty && !_excludedIngredients.contains(v)) {
                      setState(() {
                        _excludedIngredients.add(v);
                      });
                    }
                    ingredientController.clear();
                  },
                ),
              ],
            ),
          ),
          if (_excludedIngredients.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Row(
                children: _excludedIngredients.map((ing) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Chip(
                    label: Text(ing),
                    onDeleted: () {
                      setState(() {
                        _excludedIngredients.remove(ing);
                      });
                    },
                  ),
                )).toList(),
              ),
            ),
          Expanded(
            child: loading
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
                                color: Theme.of(c).colorScheme.primary.withValues(alpha: 0.3),
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
                        })),
          ),
        ],
      ),
    );
  }
}
