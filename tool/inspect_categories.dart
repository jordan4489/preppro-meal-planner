import 'dart:convert';
import 'dart:io';

import '../lib/core/models/recipe.dart';
import '../lib/core/services/shopping_list_service.dart';

Future<void> main() async {
  final file = File('assets/data/preppro_625_recipes.json');
  if (!await file.exists()) {
    print('assets/data/preppro_625_recipes.json not found');
    return;
  }

  final raw = await file.readAsString();
  final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  final recipes = list.map(Recipe.fromJson).toList();

  final selected = recipes.map((r) => r.id).toList();
  final result = ShoppingListService.aggregate(
    allRecipes: recipes,
    selectedEntries: selected,
  );

  final items = result.items;

  final countsByCategory = <String, int>{};
  for (final i in items) {
    countsByCategory[i.category] = (countsByCategory[i.category] ?? 0) + 1;
  }

  print('Total canonical ingredients: \\${items.length}');
  print('Missing ingredient lists in recipes: \\${result.missing}');
  print('By category:');
  for (final e in countsByCategory.entries) {
    print('  \\${e.key}: \\${e.value}');
  }

  // Show all ingredients currently classified as "other" so we can refine rules.
  print('\nIngredients classified as OTHER:');
  final others = items.where((i) => i.category == 'other').toList()
    ..sort((a, b) => a.name.compareTo(b.name));
  for (final i in others) {
    print('  - \\${i.name}');
  }

  // Quick spot-check for some key ingredients we care about
  print('\nSpot-check yoghurt/yogurt items:');
  for (final i in items.where((i) => i.name.contains('yogurt') || i.name.contains('yoghurt'))) {
    print('  - \\${i.name} => \\${i.category}');
  }

  print('\nSpot-check some veg keywords (apple/banana/carrot/lettuce):');
  for (final i in items.where((i) =>
      i.name.contains('apple') ||
      i.name.contains('banana') ||
      i.name.contains('carrot') ||
      i.name.contains('lettuce'))) {
    print('  - \\${i.name} => \\${i.category}');
  }
}
