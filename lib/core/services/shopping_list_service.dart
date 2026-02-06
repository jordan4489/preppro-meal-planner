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
        final rawName = i.name.trim().toLowerCase();
        final kName = _normalizeName(rawName);
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
    final isEgg = name.contains('egg');
    const eggSizeUnits = {
      'large',
      'small',
      'medium',
      'xl',
      'extra-large',
      'extra large',
      'jumbo',
      'extra jumbo',
    };
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
        if ((u.isEmpty || (isEgg && eggSizeUnits.contains(u))) &&
            (isEgg ||
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

  static String _normalizeName(String n) {
    var name = n.toLowerCase().trim();
    // Remove parenthetical notes (e.g., "(optional)")
    name = name.replaceAll(RegExp(r'\(.*?\)'), '').trim();
    // Remove trailing phrases
    name = name.replaceAll(RegExp(r'\b(to taste|for garnish|optional|as needed)\b'), '').trim();

    // Remove common descriptors
    const descriptors = [
      'large', 'small', 'medium', 'extra', 'extra virgin', 'virgin', 'low fat',
      'reduced fat', 'lean', 'skinless', 'boneless', 'freshly', 'fine', 'finely',
      'coarsely', 'free-range', 'organic', 'ripe', 'unsalted', 'salted',
    ];
    for (final d in descriptors) {
      name = name.replaceAll(RegExp('\\b' + d + '\\b'), '').trim();
    }

    // Remove common preparation words
    const prep = [
      'scrambled',
      'fried',
      'boiled',
      'poached',
      'roasted',
      'grilled',
      'baked',
      'chopped',
      'diced',
      'sliced',
      'minced',
      'ground',
      'shredded',
      'fresh',
      'frozen',
      'cooked',
      'raw',
      'smoked',
    ];
    for (final p in prep) {
      name = name.replaceAll(RegExp('\\b' + p + '\\b'), '').trim();
    }

    // Normalize specific items
    final directMap = <RegExp, String>{
      RegExp(r'\\beggs?\\b'): 'egg',
      RegExp(r'\\bmashed potatoes?\\b'): 'potato',
      RegExp(r'\\bbaked potatoes?\\b'): 'potato',
      RegExp(r'\\broast chicken\\b'): 'chicken',
      RegExp(r'\\bcooked rice\\b'): 'rice',
      RegExp(r'\\bcooked pasta\\b'): 'pasta',
      RegExp(r'\\bgrated cheese\\b'): 'cheese',
      RegExp(r'\\bshredded cheese\\b'): 'cheese',
      RegExp(r'\\bchicken breasts?\\b'): 'chicken breast',
      RegExp(r'\\bchicken thighs?\\b'): 'chicken thighs',
      RegExp(r'\\bbeef mince(d)?\\b'): 'beef mince',
      RegExp(r'\\bturkey mince(d)?\\b'): 'turkey mince',
      RegExp(r'\\bground beef\\b'): 'beef mince',
      RegExp(r'\\bground turkey\\b'): 'turkey mince',
      RegExp(r'\\bscallions?\\b'): 'spring onion',
      RegExp(r'\\bgreen onions?\\b'): 'spring onion',
      RegExp(r'\\bbell peppers?\\b'): 'bell pepper',
      RegExp(r'\\bchill?i peppers?\\b'): 'chili pepper',
      RegExp(r'\\bpotatoes\\b'): 'potato',
      RegExp(r'\\btomatoes\\b'): 'tomato',
      RegExp(r'\\bmushrooms\\b'): 'mushroom',
      RegExp(r'\\bonions\\b'): 'onion',
      RegExp(r'\\bgarlic cloves?\\b'): 'garlic',
      RegExp(r'\\bparmesan cheese\\b'): 'parmesan',
      RegExp(r'\\bmozzarella cheese\\b'): 'mozzarella',
      RegExp(r'\\bcheddar cheese\\b'): 'cheddar',
      RegExp(r'\\bspaghetti\\b'): 'pasta',
      RegExp(r'\\bpenne\\b'): 'pasta',
      RegExp(r'\\bfusilli\\b'): 'pasta',
      RegExp(r'\\btagliatelle\\b'): 'pasta',
      RegExp(r'\\bnoodles?\\b'): 'noodles',
      RegExp(r'\\bwraps?\\b'): 'wrap',
      RegExp(r'\\btortillas?\\b'): 'tortilla',
      RegExp(r'\\bflatbreads?\\b'): 'flatbread',
    };
    for (final entry in directMap.entries) {
      if (entry.key.hasMatch(name)) return entry.value;
    }

    return name.replaceAll(RegExp('\\s+'), ' ').trim();
  }
}
