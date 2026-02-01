import '../models/recipe.dart';

class ShoppingItem {
  final String name;
  final double qty; // canonical quantity
  final String unit; // canonical unit: g | ml | pc | other
  final String category;
  ShoppingItem(this.name, this.qty, this.unit, this.category);
}

class ShoppingListService {
  static ({List<ShoppingItem> items, int missing}) aggregate({
    required List<Recipe> allRecipes,
    required List<dynamic> selectedEntries, // each entry is String id or Map {id, servings}
  }) {
    final byId = {for (final r in allRecipes) r.id: r};
    final map = <String, double>{};
    final unit = <String, String>{};
    final cat = <String, String>{};
    var missing = 0;

    for (final entry in selectedEntries) {
      String id;
      double servings = 1.0;
      if (entry is String) {
        id = entry;
      } else if (entry is Map) {
        id = (entry['id'] ?? '') as String;
        servings = (entry['servings'] as num?)?.toDouble() ?? 1.0;
      } else continue;

      final r = byId[id];
      if (r == null) continue;
      final ings = r.ingredients;
      if (ings == null || ings.isEmpty) {
        missing++;
        continue;
      }
      for (final i in ings) {
        final kName = i.name.trim().toLowerCase();
        final norm =
            _normalizeUnit(i.quantity, i.unit.trim().toLowerCase(), kName);
        map[kName] = (map[kName] ?? 0) + norm.$1 * servings;
        unit[kName] = norm.$2;
        cat[kName] = _cat(kName);
      }
    }

    final items = map.entries
        .map((e) => ShoppingItem(
            e.key, e.value, unit[e.key] ?? 'other', cat[e.key] ?? 'other'))
        .toList()
      ..sort((a, b) => a.category == b.category
          ? a.name.compareTo(b.name)
          : a.category.compareTo(b.category));

    return (items: items, missing: missing);
  }

  static String prettyQty(double qty, String unit) {
    switch (unit) {
      case 'g':
        if (qty >= 1000) return _oneDecimal(qty / 1000) + ' kg';
        return qty.round().toString() + ' g';
      case 'ml':
        if (qty >= 1000) return _oneDecimal(qty / 1000) + ' L';
        return qty.round().toString() + ' ml';
      case 'pc':
        return qty.round().toString() + ' pcs';
      default:
        return _oneDecimal(qty) + (unit.isEmpty ? '' : ' ' + unit);
    }
  }

  static (double, String) _normalizeUnit(double q, String u, String name) {
    switch (u) {
      case 'kg':
      case 'kilogram':
      case 'kilograms':
        return (q * 1000, 'g');
      case 'g':
      case 'gram':
      case 'grams':
        return (q, 'g');
      case 'l':
      case 'lt':
      case 'liter':
      case 'litre':
      case 'liters':
      case 'litres':
        return (q * 1000, 'ml');
      case 'ml':
      case 'milliliter':
      case 'milliliters':
        return (q, 'ml');
      case 'pc':
      case 'pcs':
      case 'piece':
      case 'pieces':
        return (q, 'pc');
      case 'egg':
      case 'eggs':
      case 'clove':
      case 'cloves':
        return (q, 'pc');
      case 'tsp':
      case 'teaspoon':
      case 'teaspoons':
        return (q, 'tsp');
      case 'tbsp':
      case 'tablespoon':
      case 'tablespoons':
        return (q, 'tbsp');
      case 'cup':
      case 'cups':
        return (q, 'cup');
      default:
        if (u.isEmpty &&
            (name.contains('egg') ||
                name.contains('clove') ||
                name.contains('lemon') ||
                name.contains('lime'))) {
          return (q, 'pc');
        }
        return (q, u.isNotEmpty ? u : 'other');
    }
  }

  static String _cat(String n) {
    n = n.toLowerCase();
    if ([
      'chicken',
      'beef',
      'lamb',
      'prawn',
      'salmon',
      'cod',
      'tuna',
      'turkey',
      'pork'
    ].any(n.contains)) return 'meat & fish';
    if (['yogurt', 'milk', 'cheese', 'butter'].any(n.contains)) return 'dairy';
    if ([
      'pepper',
      'onion',
      'tomato',
      'spinach',
      'garlic',
      'broccoli',
      'lemon',
      'lime',
      'berries'
    ].any(n.contains)) return 'produce';
    if ([
      'rice',
      'quinoa',
      'pasta',
      'oats',
      'oil',
      'spice',
      'paprika',
      'cumin',
      'soy',
      'sesame'
    ].any(n.contains)) return 'pantry';
    if (['egg'].any(n.contains)) return 'eggs';
    return 'other';
  }

  static String _oneDecimal(double v) => v.toStringAsFixed(v % 1 == 0 ? 0 : 1);
}
