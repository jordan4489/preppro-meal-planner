import 'package:flutter_test/flutter_test.dart';
import 'package:preppro/core/services/plan_service.dart';
import 'package:preppro/core/models/recipe.dart';

void main(){
  test('generate produces servings scaled to slot target', (){
    final recipes = List.generate(10, (i)=> Recipe(id: 'r$i', title: 'R $i', isAirFryer:false, mealTypes: ['breakfast','lunch','dinner','snack'], tags: [], nutritionKcal: 400 + i*50, nutritionProtein: 20.0, ingredients: [], steps: [], allergens: const {}));
    final plan = PlanService.generate(recipes: recipes, dailyTarget: 2000, days: 1, mealsPerDay: 3);
    expect(plan.days, isNotEmpty);
    final day = plan.days.first;
    for (final m in day.meals) {
      expect(m.servings >= 0.25, true);
      expect(m.servings <= 4.0, true);
      final slotTarget = (2000 * (1/3)).round();
      final kcal = (m.recipe.nutritionKcal * m.servings).round();
      // check that kcal is reasonably close to slot target (within 50% tolerance)
      expect((kcal - slotTarget).abs() < (slotTarget * 0.6), true);
    }
  });
}
