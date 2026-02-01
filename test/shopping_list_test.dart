import 'package:flutter_test/flutter_test.dart';
import 'package:preppro/core/services/shopping_list_service.dart';
import 'package:preppro/core/models/recipe.dart';

void main() {
  test('aggregate multiplies ingredient quantities by servings and groups units', () {
    final r1 = Recipe(
      id: 'r1',
      title: 'Rice & Egg',
      isAirFryer: false,
      mealTypes: ['lunch'],
      tags: [],
      nutritionKcal: 300,
      nutritionProtein: 10.0,
      ingredients: [
        Ingredient(name: 'Rice', quantity: 100, unit: 'g'),
        Ingredient(name: 'Egg', quantity: 2, unit: 'pc'),
      ],
    );

    final r2 = Recipe(
      id: 'r2',
      title: 'Half rice',
      isAirFryer: false,
      mealTypes: ['lunch'],
      tags: [],
      nutritionKcal: 200,
      nutritionProtein: 8.0,
      ingredients: [
        Ingredient(name: 'Rice', quantity: 50, unit: 'g'),
        Ingredient(name: 'Egg', quantity: 1, unit: 'pc'),
      ],
    );

    final all = [r1, r2];

    final entries = [
      {'id': 'r1', 'servings': 2.0}, // doubles r1 quantities
      {'id': 'r2', 'servings': 0.5}, // halves r2 quantities
    ];

    final res = ShoppingListService.aggregate(allRecipes: all, selectedEntries: entries);

    expect(res.missing, 0);

    final map = {for (var it in res.items) it.name: it};

    // Rice: r1 -> 100 * 2 = 200; r2 -> 50 * 0.5 = 25 => total 225 g
    expect(map.containsKey('rice'), true);
    expect(map['rice']!.unit, 'g');
    expect(map['rice']!.qty, closeTo(225.0, 0.1));

    // Egg: r1 -> 2 * 2 = 4; r2 -> 1 * 0.5 = 0.5 => total 4.5 pcs
    expect(map.containsKey('egg'), true);
    expect(map['egg']!.unit, 'pc');
    expect(map['egg']!.qty, closeTo(4.5, 0.1));
  });

  test('missing increments when recipe has no ingredients', () {
    final r1 = Recipe(id: 'r1', title: 'No ing', isAirFryer: false, mealTypes: ['lunch'], tags: [], nutritionKcal: 100, nutritionProtein: 1.0, ingredients: null);
    final all = [r1];
    final res = ShoppingListService.aggregate(allRecipes: all, selectedEntries: ['r1']);
    expect(res.missing, 1);
    expect(res.items.length, 0);
  });
}
