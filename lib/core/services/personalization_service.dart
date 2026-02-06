import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PersonalizationService {
  static const _kViews = 'pp_recipe_views_v1';
  static const _kFavs = 'pp_recipe_favs_v1';

  static Future<void> recordView(String recipeId) async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kViews);
    final map = raw == null ? <String, int>{} : _decodeIntMap(raw);
    map[recipeId] = (map[recipeId] ?? 0) + 1;
    await sp.setString(_kViews, jsonEncode(map));
  }

  static Future<void> recordFavorite(String recipeId, bool isFav) async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kFavs);
    final map = raw == null ? <String, bool>{} : _decodeBoolMap(raw);
    map[recipeId] = isFav;
    await sp.setString(_kFavs, jsonEncode(map));
  }

  static Future<Map<String, double>> getRecipeScores() async {
    final sp = await SharedPreferences.getInstance();
    final rawViews = sp.getString(_kViews);
    final rawFavs = sp.getString(_kFavs);
    final views = rawViews == null ? <String, int>{} : _decodeIntMap(rawViews);
    final favs = rawFavs == null ? <String, bool>{} : _decodeBoolMap(rawFavs);

    final scores = <String, double>{};
    for (final entry in views.entries) {
      scores[entry.key] = (scores[entry.key] ?? 0) + entry.value * 0.2;
    }
    for (final entry in favs.entries) {
      if (entry.value) {
        scores[entry.key] = (scores[entry.key] ?? 0) + 2.0;
      }
    }
    return scores;
  }

  static Map<String, int> _decodeIntMap(String raw) {
    try {
      final m = jsonDecode(raw);
      if (m is Map) {
        return m.map((k, v) => MapEntry(k.toString(), (v as num).toInt()));
      }
    } catch (_) {}
    return <String, int>{};
  }

  static Map<String, bool> _decodeBoolMap(String raw) {
    try {
      final m = jsonDecode(raw);
      if (m is Map) {
        return m.map((k, v) => MapEntry(k.toString(), v == true));
      }
    } catch (_) {}
    return <String, bool>{};
  }
}
