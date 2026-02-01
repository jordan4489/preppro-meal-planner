import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/recipe_loader.dart';
import '../../core/models/recipe.dart';
import '../../core/services/plan_service.dart';
import '../../core/services/profile_service.dart';
import '../../core/services/plan_store.dart';


class PlanPage extends StatefulWidget {
  const PlanPage({super.key});
  @override
  State<PlanPage> createState() => _PlanState();
}

class _PlanState extends State<PlanPage> {
  bool generating = false;
  int? targetKcal;
  List<DayPlan>? plan;
  List<Recipe> all = [];
  final Map<String, bool> _eaten = {};
  final List<double> split = const [0.22, 0.10, 0.28, 0.10, 0.30];
  final Set<String> prefProteins = {};
  final Set<String> dietaryReqs = {};
  final _opts = const [
    'chicken',
    'turkey',
    'beef',
    'lamb',
    'pork',
    'eggs',
    'fish',
    'seafood',
    'tofu/tempeh',
    'veggie'
  ];
  final _dietaryOpts = const [
    'vegetarian',
    'vegan',
    'gluten-free',
    'dairy-free',
    'low-carb',
    'halal',
    'kosher'
  ];
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    targetKcal = await ProfileService.computeDailyTarget();
    all = await RecipeLoader.load();
    final saved = await ProfileService.loadPreferredProteins();
    prefProteins
      ..clear()
      ..addAll(saved);
    final savedDietary = await ProfileService.loadDietaryRequirements();
    dietaryReqs
      ..clear()
      ..addAll(savedDietary);
    final savedChecks = await PlanStore.loadMealChecks();
    _eaten
      ..clear()
      ..addAll(savedChecks);
    
    // Load the saved plan
    final savedPlan = await PlanStore.load();
    if (savedPlan != null && savedPlan.isNotEmpty) {
      try {
        // Convert saved plan IDs back to DayPlan objects
        final days = <DayPlan>[];
        for (final dayMeals in savedPlan) {
          final meals = <PlannedMeal>[];
          for (final meal in dayMeals) {
            final id = meal['id'] as String?;
            final servings = (meal['servings'] as num?)?.toDouble() ?? 1.0;
            if (id != null) {
              try {
                final recipe = all.firstWhere((r) => r.id == id);
                meals.add(PlannedMeal(recipe: recipe, servings: servings));
              } catch (_) {
                // Recipe not found, skip it
              }
            }
          }
          if (meals.isNotEmpty) {
            days.add(DayPlan(meals));
          }
        }
        if (days.isNotEmpty) {
          setState(() {
            plan = days;
          });
          return;
        }
      } catch (e) {
        print('Error loading saved plan: $e');
      }
    }
    setState(() {});
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

  List<Recipe> _applyPref(List<Recipe> src) {
    if (prefProteins.isEmpty) return src;
    return src.where((r) => prefProteins.contains(_proteinOf(r))).toList();
  }

  List<Recipe> _applyDietary(List<Recipe> src) {
    if (dietaryReqs.isEmpty) return src;
    return src.where((r) {
      final titleLower = r.title.toLowerCase();
      final tagsLower = r.tags.map((e) => e.toLowerCase()).join(' ');
      final ingredientsLower = (r.ingredients ?? [])
          .map((e) => e.name.toLowerCase())
          .join(' ');
      final combined = '$titleLower $tagsLower $ingredientsLower';
      
      return dietaryReqs.every((diet) {
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

  String _mealKey(int di, int mi) => '$di-$mi';

  int _eatenKcalForDay(int di) {
    if (plan == null) return 0;
    if (di < 0 || di >= plan!.length) return 0;
    final day = plan![di];
    var sum = 0;
    for (var i = 0; i < day.meals.length; i++) {
      if (_eaten[_mealKey(di, i)] == true) {
        sum += day.meals[i].kcal;
      }
    }
    return sum;
  }

  int _eatenKcalTotal() {
    if (plan == null) return 0;
    var sum = 0;
    for (var di = 0; di < plan!.length; di++) {
      sum += _eatenKcalForDay(di);
    }
    return sum;
  }

  Future<void> _generate() async {
    HapticFeedback.lightImpact();
    final saved = await ProfileService.loadPreferredProteins();
    final savedDietary = await ProfileService.loadDietaryRequirements();
    setState(() {
      prefProteins
        ..clear()
        ..addAll(saved);
      dietaryReqs
        ..clear()
        ..addAll(savedDietary);
    });
    if (targetKcal == null) {
      _toast('Set your goal on the profile page first.');
      return;
    }
    if (all.isEmpty) {
      _toast('No recipes available.');
      return;
    }
    setState(() {
      generating = true;
      plan = null;
    });
    
    // Apply dietary filter first (affects all recipes including snacks)
    var filtered = _applyDietary(all);
    
    // Apply protein filter to main meals, but keep all snacks available
    final filteredMain = _applyPref(filtered);
    final allSnacks = filtered.where((r) => r.mealTypes.any((m) => m.toLowerCase() == 'snack')).toList();
    
    // Combine: filtered main meals + all snacks for maximum flexibility
    final mainMeals = filteredMain.where((r) => 
      !r.mealTypes.any((m) => m.toLowerCase() == 'snack')).toList();
    final source = [...mainMeals, ...allSnacks];
    
    if (source.isEmpty) {
      _toast('No recipes match your protein selection.');
      setState(() {
        generating = false;
      });
      return;
    }
    try {
      final week = PlanService.generate(
          recipes: source,
          dailyTarget: targetKcal!,
          days: 7,
          mealsPerDay: 5,
          split: split,
          maxRepeatsPerWeek: 1);
      _eaten.clear();
      final ids = week.days
          .map((d) => d.meals.map((m) => {'id': m.recipe.id, 'servings': m.servings}).toList())
          .toList();
      
      try {
        await PlanStore.save(ids);
        await PlanStore.saveMealChecks(_eaten);
        await ProfileService.recordPlanGeneration();
      } catch (saveError) {
        print('Error saving plan: $saveError');
      }
      
      setState(() {
        plan = week.days;
        generating = false;
      });
      _toast('Plan generated & saved.');
    } on StateError catch (e) {
      setState(() => generating = false);
      _toast(e.message);
    } catch (e) {
      setState(() => generating = false);
      _toast('Error: $e');
    }
  }

  void _openProteinSelector() {
    showModalBottomSheet(
        context: context,
        showDragHandle: true,
        builder: (ctx) {
          final local = Set<String>.from(prefProteins);
          return StatefulBuilder(
              builder: (c, setM) => Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Preferred proteins',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600))),
                    const SizedBox(height: 8),
                    Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: _opts
                            .map((p) => FilterChip(
                                label: Text(p,
                                    style: const TextStyle(fontSize: 15)),
                                selected: local.contains(p),
                                onSelected: (s) => setM(
                                    () => s ? local.add(p) : local.remove(p))))
                            .toList()),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                          child: FilledButton.icon(
                              onPressed: () async {
                                setState(() {
                                  prefProteins
                                    ..clear()
                                    ..addAll(local);
                                });
                                await ProfileService.savePreferredProteins(
                                    prefProteins);
                                if (mounted) {
                                  Navigator.pop(context);
                                  _toast(prefProteins.isEmpty
                                      ? 'Using all proteins'
                                      : 'Saved: ' + prefProteins.join(', '));
                                }
                              },
                              icon: const Icon(Icons.check),
                              label: const Text('Apply')))
                    ])
                  ])));
        });
  }
  void _openDietarySelector() {
    showModalBottomSheet(
        context: context,
        showDragHandle: true,
        builder: (ctx) {
          final local = Set<String>.from(dietaryReqs);
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
                        children: _dietaryOpts
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
                              onPressed: () async {
                                setState(() {
                                  dietaryReqs
                                    ..clear()
                                    ..addAll(local);
                                });
                                await ProfileService.saveDietaryRequirements(
                                    dietaryReqs);
                                if (mounted) {
                                  Navigator.pop(context);
                                  _toast(dietaryReqs.isEmpty
                                      ? 'No dietary restrictions'
                                      : 'Saved: ' + dietaryReqs.map((d) => d.split('-').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ')).join(', '));
                                }
                              },
                              icon: const Icon(Icons.check),
                              label: const Text('Apply')))
                    ])
                  ])));
        });
  }
  Future<void> _showMealActions(int dayIndex, int mealIndex) async {
    if (plan == null) return;
    await showModalBottomSheet(
        context: context,
        showDragHandle: true,
        builder: (_) => SafeArea(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              ListTile(
                leading: const Icon(Icons.auto_awesome),
                title: const Text('Replace with similar'),
                subtitle: const Text('Keeps kcal close and improves variety'),
                onTap: () async {
                  Navigator.pop(context);
                  await _magicReplace(dayIndex, mealIndex);
                },
              ),
              ListTile(
                leading: const Icon(Icons.scale),
                title: const Text('Adjust servings'),
                subtitle: const Text('Change the servings for this meal'),
                onTap: () async {
                  Navigator.pop(context);
                  await _adjustServings(dayIndex, mealIndex);
                },
              ),
              const SizedBox(height: 8),
            ])));
  }

  Map<String, int> _usage() {
    final m = <String, int>{};
    if (plan == null) return m;
    for (final d in plan!) {
      for (final pm in d.meals) {
        m[pm.recipe.id] = (m[pm.recipe.id] ?? 0) + 1;
      }
    }
    return m;
  }

  Future<void> _adjustServings(int di, int mi) async {
    if (plan == null) return;
    final current = plan![di].meals[mi];
    final controller = TextEditingController(text: current.servings.toString());
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: const Text('Adjust servings'),
      content: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(labelText: 'Servings (e.g., 1.0, 1.5)'),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save'))],
    ));
    if (ok != true) return;
    final v = double.tryParse(controller.text);
    if (v == null || v <= 0) { _toast('Enter a valid number'); return; }
    setState((){
      plan![di].meals[mi] = PlannedMeal(recipe: current.recipe, servings: v);
    });
    final ids = plan!.map((d) => d.meals.map((m) => {'id': m.recipe.id, 'servings': m.servings}).toList()).toList();
    await PlanStore.save(ids);
    _toast('Servings updated to $v');
  }
  List<Recipe> _poolForSlot(int idx) {
    // Apply dietary filter first, then protein filter for non-snacks
    var dietaryFiltered = _applyDietary(all);
    
    // For snacks, don't apply protein filter if it would result in no options
    final isSnack = idx == 1 || idx == 3;
    final base = isSnack ? dietaryFiltered : _applyPref(dietaryFiltered);
    
    String t;
    switch (idx) {
      case 0:
        t = 'breakfast';
        break;
      case 1:
        t = 'snack';
        break;
      case 2:
        t = 'lunch';
        break;
      case 3:
        t = 'snack';
        break;
      case 4:
        t = 'dinner';
        break;
      default:
        t = '';
    }
    if (t.isEmpty) return const <Recipe>[];
    final filtered = base
        .where((r) => r.mealTypes.any((m) => m.toLowerCase() == t))
        .toList();
    
    // If filtering resulted in no snacks, fall back to all dietary-filtered snacks
    if (isSnack && filtered.isEmpty) {
      final dietaryFiltered = _applyDietary(all);
      return dietaryFiltered
          .where((r) => r.mealTypes.any((m) => m.toLowerCase() == t))
          .toList();
    }
    
    return filtered;
  }

  Future<void> _magicReplace(int di, int mi) async {
    HapticFeedback.lightImpact();
    HapticFeedback.lightImpact();
    final saved = await ProfileService.loadPreferredProteins();
    final savedDietary = await ProfileService.loadDietaryRequirements();
    setState(() {
      prefProteins
        ..clear()
        ..addAll(saved);
      dietaryReqs
        ..clear()
        ..addAll(savedDietary);
    });
    if (plan == null || all.isEmpty) {
      _toast('No plan or recipes available.');
      return;
    }
    if (targetKcal == null) {
      _toast('Set your daily target first.');
      return;
    }
    final day = plan![di];
    if (mi < 0 || mi >= day.meals.length) return;
    final current = day.meals[mi].recipe;
    final currentK = current.nutritionKcal;
    final currentP = current.nutritionProtein;
    final slotTarget = (targetKcal! * split[mi]).round();
    final usedToday = day.meals.map((m) => m.recipe.id).toSet();
    final usage = _usage();
    final pool = _poolForSlot(mi);
    if (pool.isEmpty) {
      _toast('No candidates for this slot.');
      return;
    }
    final candidates = pool.where((r) => r.id != current.id).toList();
    double best = 1e18;
    Recipe? pick;
    final dayBefore = day.totalKcal;
    for (final cand in candidates) {
      final newDay = dayBefore - currentK + cand.nutritionKcal;
      final slotPenalty = (cand.nutritionKcal - slotTarget).abs().toDouble();
      final dayPenalty = (newDay - targetKcal!).abs().toDouble();
      final proteinGain = (cand.nutritionProtein - currentP);
      final repeatPenalty = (usage[cand.id] ?? 0) >= 2 ? 200.0 : 0.0;
      final dupPenalty = usedToday.contains(cand.id) ? 500.0 : 0.0;
      final score = 2.0 * slotPenalty +
          1.0 * dayPenalty -
          0.3 * proteinGain +
          repeatPenalty +
          dupPenalty;
      if (score < best) {
        best = score;
        pick = cand;
      }
    }
    if (pick == null) {
      _toast('No suitable replacement found.');
      return;
    }
    setState(() {
      plan![di].meals[mi] = PlannedMeal(recipe: pick!, servings: 1.0);
    });
    final ids =
        plan!.map((d) => d.meals.map((m) => {'id': m.recipe.id, 'servings': m.servings}).toList()).toList();
    await PlanStore.save(ids);
    _toast('Replaced with: ' + pick.title);
  }

  void _toast(String s) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));

  Future<void> _editTarget() async {
    // Open profile for editing; computed daily target will be refreshed on return
    context.go('/profile');
    final v = await ProfileService.computeDailyTarget();
    setState(() => targetKcal = v);
  }

  @override
  Widget build(BuildContext context) {
    final t = targetKcal;
    const labels = ['B', 'S', 'L', 'S', 'D'];
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/home'),
          ),
          title: const Text('Weekly plan'),
          actions: [
          IconButton(
              tooltip: 'Preferred proteins',
              icon: const Icon(Icons.filter_alt),
              onPressed: _openProteinSelector),
          IconButton(
              tooltip: 'Dietary requirements',
              icon: const Icon(Icons.restaurant_menu),
              onPressed: _openDietarySelector),
          IconButton(
              tooltip: 'Generate plan',
              icon: const Icon(Icons.refresh),
              onPressed: generating ? null : _generate)
        ]),
        body: Stack(
          children: [
            // Full background logo watermark
            Positioned.fill(
              child: Opacity(
                opacity: 0.035,
                child: Image.asset(
                  'assets/images/logo_preppro_blue.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  errorBuilder: (_, __, ___) => const SizedBox(),
                ),
              ),
            ),
            // Main content
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
              // Only show filters when no plan is generated
              if (plan == null) ...[
                _ProteinFilterBanner(
                  prefProteins: prefProteins,
                  onTap: _openProteinSelector,
                ),
                if (dietaryReqs.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _DietaryFilterBanner(
                    dietary: dietaryReqs,
                    onTap: _openDietarySelector,
                  ),
                ],
                const SizedBox(height: 8),
              ],
              _Target(targetKcal: t, onEdit: _editTarget),
              if (plan != null && t != null) ...[
                const SizedBox(height: 6),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, size: 18, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Checked: ${_eatenKcalTotal()} kcal',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          'Left: ${(t * 7) - _eatenKcalTotal()} kcal',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: generating ? null : _generate,
                icon: Icon(generating ? Icons.hourglass_empty : Icons.auto_awesome, size: 20),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: generating ? 0 : 2,
                ),
                label: Text(
                  generating ? 'Generating...' : 'Generate Meal Plan',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 12),
              if (plan == null)
                const _EmptyHint()
              else
                ...plan!.asMap().entries.map((entry) {
                  final di = entry.key;
                  final d = entry.value;
                            final dev = t == null ? 0 : (d.totalKcal - t);
                            final sign = dev == 0
                                ? ''
                                : dev > 0
                                    ? '+$dev'
                                    : '$dev';
                            return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
                                    width: 1,
                                  ),
                                ),
                                child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(children: [
                                            Icon(
                                              Icons.calendar_today,
                                              size: 20,
                                              color: Theme.of(context).colorScheme.primary,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Day ' + (di + 1).toString(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleLarge
                                                    ?.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                              ),
                                            ),
                                            if (t != null)
                                              Flexible(
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primaryContainer,
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    '${d.totalKcal} / $t kcal ($sign)',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                          ]),
                                          const SizedBox(height: 8),
                                          // Daily macro summary
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .surfaceVariant
                                                  .withOpacity(0.3),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              children: [
                                                _MacroChip(
                                                  icon: Icons.fitness_center,
                                                  label: 'P',
                                                  value: d.meals.fold<double>(0, (sum, m) => sum + (m.recipe.nutritionProtein * m.servings)).round(),
                                                  color: Colors.red,
                                                ),
                                                _MacroChip(
                                                  icon: Icons.bakery_dining,
                                                  label: 'C',
                                                  value: ((d.totalKcal - (d.meals.fold<double>(0, (sum, m) => sum + (m.recipe.nutritionProtein * m.servings)) * 4)) / 4).round(),
                                                  color: Colors.orange,
                                                ),
                                                _MacroChip(
                                                  icon: Icons.water_drop,
                                                  label: 'F',
                                                  value: ((d.totalKcal * 0.25) / 9).round(),
                                                  color: Colors.blue,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Icon(Icons.check_circle_outline, size: 18, color: Theme.of(context).colorScheme.primary),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Eaten: ${_eatenKcalForDay(di)} kcal',
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const Spacer(),
                                              if (t != null)
                                                Text(
                                                  'Left: ${t - _eatenKcalForDay(di)} kcal',
                                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          const Divider(),
                                          const SizedBox(height: 4),
                                          for (var i = 0;
                                              i < d.meals.length;
                                              i++)
                                            ListTile(
                                                contentPadding: const EdgeInsets.symmetric(
                                                  vertical: 4,
                                                ),
                                                leading: CircleAvatar(
                                                  backgroundColor: Theme.of(context)
                                                      .colorScheme
                                                      .secondaryContainer,
                                                  child: Text(
                                                    labels[i],
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSecondaryContainer,
                                                    ),
                                                  ),
                                                ),
                                                title: Text(
                                                  d.meals[i].recipe.title,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleSmall
                                                      ?.copyWith(
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                ),
                                                subtitle: Padding(
                                                  padding: const EdgeInsets.only(top: 4),
                                                  child: Text(
                                                    '${d.meals[i].kcal} kcal • P ${(d.meals[i].recipe.nutritionProtein * d.meals[i].servings).round()}g • ${d.meals[i].servings}x serving',
                                                  ),
                                                ),
                                                trailing: SizedBox(
                                                  width: 80,
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [
                                                      if (d.meals[i].recipe.isAirFryer)
                                                        Container(
                                                          padding: const EdgeInsets.all(4),
                                                          margin: const EdgeInsets.only(right: 4),
                                                          decoration: BoxDecoration(
                                                            color: Theme.of(context)
                                                                .colorScheme
                                                                .tertiaryContainer,
                                                            borderRadius:
                                                                BorderRadius.circular(6),
                                                          ),
                                                          child: Icon(
                                                            Icons.air,
                                                            size: 16,
                                                            color: Theme.of(context)
                                                                .colorScheme
                                                                .onTertiaryContainer,
                                                          ),
                                                        ),
                                                      Checkbox(
                                                        value: _eaten[_mealKey(di, i)] ?? false,
                                                        onChanged: (v) {
                                                          setState(() {
                                                            _eaten[_mealKey(di, i)] = v ?? false;
                                                          });
                                                          PlanStore.saveMealChecks(_eaten);
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                onTap: () =>
                                                    GoRouter.of(context).push(
                                                        '/recipe/${d.meals[i].recipe.id}'),
                                                onLongPress: () =>
                                                    _showMealActions(di, i))
                                        ])));
                }).toList(),
              ],
            ),
          ],
        ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color color;

  const _MacroChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          '$label: ${value}g',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _Target extends StatelessWidget {
  final int? targetKcal;
  final VoidCallback onEdit;
  const _Target({required this.targetKcal, required this.onEdit});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [cs.primaryContainer, cs.secondaryContainer],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.flag,
              size: 28,
              color: cs.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Target',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    targetKcal == null ? 'Not set' : '$targetKcal kcal',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            FilledButton.tonal(
              onPressed: onEdit,
              child: const Text('Edit'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint();
  @override
  Widget build(BuildContext context) => Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'No Meal Plan Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Generate your personalized 7-day meal plan by tapping the button above.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Tip: Tap any meal to view recipe details. Long-press to replace with a similar recipe.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ));
}

class _ProteinFilterBanner extends StatelessWidget {
  final Set<String> prefProteins;
  final VoidCallback onTap;
  const _ProteinFilterBanner({required this.prefProteins, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isFiltered = prefProteins.isNotEmpty;
    
    return Container(
      decoration: BoxDecoration(
        gradient: isFiltered
            ? LinearGradient(
                colors: [cs.primaryContainer, cs.primaryContainer.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isFiltered ? null : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFiltered ? cs.primary.withOpacity(0.3) : cs.outlineVariant.withOpacity(0.5),
          width: isFiltered ? 2 : 1,
        ),
        boxShadow: isFiltered
            ? [
                BoxShadow(
                  color: cs.primary.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isFiltered ? cs.primary : cs.onSurfaceVariant.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.restaurant,
                  color: isFiltered ? cs.onPrimary : cs.onSurfaceVariant,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isFiltered ? 'Protein Filter Active' : 'Protein Preferences',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isFiltered ? cs.onPrimaryContainer : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isFiltered
                          ? prefProteins.join(', ')
                          : 'Tap to select preferred proteins',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isFiltered
                            ? cs.onPrimaryContainer.withOpacity(0.8)
                            : cs.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                isFiltered ? Icons.edit : Icons.chevron_right,
                color: isFiltered ? cs.onPrimaryContainer : cs.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DietaryFilterBanner extends StatelessWidget {
  final Set<String> dietary;
  final VoidCallback onTap;
  const _DietaryFilterBanner({required this.dietary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isFiltered = dietary.isNotEmpty;
    
    return Container(
      decoration: BoxDecoration(
        gradient: isFiltered
            ? LinearGradient(
                colors: [cs.tertiaryContainer, cs.tertiaryContainer.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isFiltered ? null : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFiltered ? cs.tertiary.withOpacity(0.3) : cs.outlineVariant.withOpacity(0.5),
          width: isFiltered ? 2 : 1,
        ),
        boxShadow: isFiltered
            ? [
                BoxShadow(
                  color: cs.tertiary.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isFiltered ? cs.tertiary : cs.onSurfaceVariant.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.restaurant_menu,
                  color: isFiltered ? cs.onTertiary : cs.onSurfaceVariant,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dietary Requirements',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isFiltered ? cs.onTertiaryContainer : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isFiltered
                          ? dietary.map((d) => d.split('-').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ')).join(', ')
                          : 'No dietary restrictions',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isFiltered
                            ? cs.onTertiaryContainer.withOpacity(0.8)
                            : cs.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                isFiltered ? Icons.edit : Icons.chevron_right,
                color: isFiltered ? cs.onTertiaryContainer : cs.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
