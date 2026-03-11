import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('preppro_625_recipes.json decodes', () async {
    final raw = await rootBundle.loadString('assets/data/preppro_625_recipes.json');
    final decoded = jsonDecode(raw);
    expect(decoded is List, true, reason: 'Top-level JSON should be a List');
    final list = decoded as List;
    expect(list.isNotEmpty, true, reason: 'JSON list should not be empty');
  });
}
