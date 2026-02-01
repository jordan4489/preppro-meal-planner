
import '../models/recipe.dart';

class PlannedMeal {
  final Recipe recipe;
  final double servings;
  PlannedMeal({required this.recipe, this.servings = 1.0});
  int get kcal => (recipe.nutritionKcal * servings).round();
}

class DayPlan {
  final List<PlannedMeal> meals;
  DayPlan(this.meals);
  int get totalKcal => meals.fold(0, (s, m) => s + m.kcal);
}

class WeekPlan {
  final List<DayPlan> days;
  WeekPlan(this.days);
}

class PlanService {
  /// mealsPerDay:
  ///   3 -> [breakfast, lunch, dinner]
  ///   5 -> [breakfast, snack, lunch, snack, dinner]  (strict)
  static WeekPlan generate({
    required List<Recipe> recipes,
    required int dailyTarget,
    int days = 7,
    int mealsPerDay = 3,
    List<double>? split,
    int maxRepeatsPerWeek = 2,
  }) {
    split ??= (mealsPerDay == 5)
        ? [0.22, 0.10, 0.28, 0.10, 0.30] // B, S, L, S, D
        : List.filled(mealsPerDay, 1.0 / mealsPerDay);

    List<Recipe> _ofType(String t) =>
        recipes.where((r) => r.mealTypes.any((m) => m.toLowerCase() == t)).toList();

    final breakfasts = _ofType('breakfast');
    final snacks     = _ofType('snack');
    final lunches    = _ofType('lunch');
    final dinners    = _ofType('dinner');

    List<List<Recipe>> pools;
    if (mealsPerDay == 5) {
      pools = [breakfasts, snacks, lunches, snacks, dinners];
    } else if (mealsPerDay == 3) {
      pools = [breakfasts, lunches, dinners];
    } else {
      pools = List.generate(mealsPerDay, (_) => recipes);
    }

    // Strictness: if any pool is empty, fail generation early
    for (var i = 0; i < pools.length; i++) {
      if (pools[i].isEmpty) {
        final label = (mealsPerDay == 5)
            ? (['breakfast', 'snack', 'lunch', 'snack', 'dinner'])[i]
            : (['breakfast', 'lunch', 'dinner'])[i];
        throw StateError('No recipes available for "' + label + '".');
      }
    }

    final usage = <String, int>{};
    final daysList = <DayPlan>[];

    for (var di = 0; di < days; di++) {
      final usedToday = <String>{};
      final meals = <PlannedMeal>[];

      for (var mi = 0; mi < mealsPerDay; mi++) {
        final slotTarget = (dailyTarget * split[mi]).round();
        final pool = pools[mi];

        final sorted = [...pool]
          ..sort((a, b) => (a.nutritionKcal - slotTarget).abs()
              .compareTo((b.nutritionKcal - slotTarget).abs()));

        var pick = sorted.first;
        for (final r in sorted) {
          final count = usage[r.id] ?? 0;
          if (!usedToday.contains(r.id) && count < maxRepeatsPerWeek) {
            pick = r;
            break;
          }
        }
        // auto-scale servings to match slot target
        double servings = pick.nutritionKcal > 0 ? slotTarget / pick.nutritionKcal : 1.0;
        // round to nearest 0.25 and clamp
        servings = (servings * 4).round() / 4.0;
        if (servings < 0.25) servings = 0.25;
        if (servings > 4.0) servings = 4.0;
        meals.add(PlannedMeal(recipe: pick, servings: servings));
        usedToday.add(pick.id);
        usage[pick.id] = (usage[pick.id] ?? 0) + 1;
      }
      daysList.add(DayPlan(meals));
    }

    return WeekPlan(daysList);
  }
}
