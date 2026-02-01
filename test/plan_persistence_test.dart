import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:preppro/core/services/plan_store.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('save and load preserves servings', () async {
    await PlanStore.clear();
    final List<List<Map<String, Object>>> days = [
      <Map<String, Object>>[
        <String, Object>{'id': 'r1', 'servings': 1.5},
        <String, Object>{'id': 'r2', 'servings': 2.0}
      ],
      <Map<String, Object>>[]
    ];

    await PlanStore.save(days);
    final loaded = await PlanStore.load();
    expect(loaded, isNotNull);
    expect(loaded!.length, 2);
    expect(loaded[0].length, 2);
    expect(loaded[0][0]['id'], 'r1');
    expect((loaded[0][0]['servings'] as double), 1.5);
  });

  test('backwards compatibility converts list of ids to servings 1.0', () async {
    final raw = {'days': [['r1', 'r2'], []]};
    SharedPreferences.setMockInitialValues({'pp_saved_plan_v1': jsonEncode(raw)});

    final loaded = await PlanStore.load();
    expect(loaded, isNotNull);
    expect(loaded!.length, 2);
    expect(loaded[0][0]['id'], 'r1');
    expect((loaded[0][0]['servings'] as double), 1.0);
  });
}
