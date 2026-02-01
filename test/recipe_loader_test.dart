import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:preppro/core/models/recipe.dart';

void main() {
  test('recipes JSON contains instructions mapped to steps', () {
    final f = File('assets/data/preppro_500_recipes.json');
    expect(f.existsSync(), true, reason: 'recipes json must exist');
    final raw = jsonDecode(f.readAsStringSync()) as List;
    expect(raw.isNotEmpty, true);
    final first = raw.first as Map<String, dynamic>;
    final r = Recipe.fromJson(first);
    expect(r.steps, isNotNull);
    expect(r.steps!.isNotEmpty, true);
  });
}