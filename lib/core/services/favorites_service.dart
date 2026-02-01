import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const _key = 'favorites';
  final Set<String> _favorites = {};
  
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    _favorites.clear();
    _favorites.addAll(list);
  }
  
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, _favorites.toList());
  }
  
  bool isFavorite(String recipeTitle) => _favorites.contains(recipeTitle);
  
  Future<void> toggle(String recipeTitle) async {
    if (_favorites.contains(recipeTitle)) {
      _favorites.remove(recipeTitle);
    } else {
      _favorites.add(recipeTitle);
    }
    await _save();
  }
  
  Set<String> get all => Set.from(_favorites);
}

final favoritesService = FavoritesService();
