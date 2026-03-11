import 'package:flutter_test/flutter_test.dart';
import 'package:preppro/core/services/recipe_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('preppro_625_recipes.json loads and is non-empty', () async {
    final recipes = await RecipeLoader.load();
    expect(recipes, isNotNull);
    expect(recipes.isNotEmpty, true, reason: 'Expected recipes to load');
  });
}
