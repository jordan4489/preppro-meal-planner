class Ingredient { final String name; final double quantity; final String unit;
  Ingredient({required this.name, required this.quantity, required this.unit});
  factory Ingredient.fromJson(Map<String,dynamic> j)=>Ingredient(name:j['name'], quantity:(j['quantity'] as num).toDouble(), unit:(j['unit']??'')); }
class Recipe { final String id; final String title; final bool isAirFryer; final List<String> mealTypes; final List<String> tags; final int nutritionKcal; final double nutritionProtein; final List<Ingredient>? ingredients; final List<String>? steps; final String? image; final Set<String> allergens;
  Recipe({required this.id,required this.title,required this.isAirFryer,required this.mealTypes,required this.tags,required this.nutritionKcal,required this.nutritionProtein,this.ingredients,this.steps,this.image,required this.allergens});
  String get displayTitle => _streetFoodTitle(title);
  factory Recipe.fromJson(Map<String,dynamic> j) {
    final title = j['title'] as String? ?? '';
    final tags = (j['tags'] as List?)?.cast<String>() ?? const [];
    final ingredients = j['ingredients'] == null
        ? null
        : (j['ingredients'] as List).map((e) => Ingredient.fromJson(e)).toList();
    final haystack = ([title, ...tags, ...(ingredients ?? []).map((e) => e.name)]).join(' ').toLowerCase();
    final allergens = _detectAllergens(haystack);
    return Recipe(
        id: j['id'],
        title: title,
        isAirFryer: (j['isAirFryer'] ?? false),
        mealTypes: (j['mealTypes'] as List).cast<String>(),
        tags: tags,
        nutritionKcal: (j['nutrition']['kcal'] as num).toInt(),
        nutritionProtein: (j['nutrition']['protein_g'] as num).toDouble(),
        image: j['image'] as String?,
        ingredients: ingredients,
        // Some data sources use 'steps', others use 'instructions'
        steps: _upgradeSteps(
            (j['steps'] != null && (j['steps'] as List).isNotEmpty)
                ? (j['steps'] as List).cast<String>()
                : (j['instructions'] != null
                    ? (j['instructions'] as List).cast<String>()
                    : null),
            haystack),
        allergens: allergens);
  }
}

String _streetFoodTitle(String title) {
  if (title.isEmpty) return title;
  if (title.toLowerCase().contains('street')) return title;
  var t = title;
  t = t.replaceAll(RegExp(r'\b(Fuel|Bistro)\s+Box\b', caseSensitive: false), 'Street Box');
  t = t.replaceAll(RegExp(r'\b(Protein|Power|Macro|Loaded|Build|Energy)\s+Bowl\b', caseSensitive: false), 'Street Bowl');
  t = t.replaceAll(RegExp(r'\b(Protein|Hearty)\s+Pot\b', caseSensitive: false), 'Street Pot');
  t = t.replaceAll(RegExp(r'\b(Protein|Layered)\s+Stack\b', caseSensitive: false), 'Street Stack');
  return t;
}

List<String>? _upgradeSteps(List<String>? steps, String haystack) {
  if (steps == null) return null;
  final rx = RegExp(
    r'(add\s+sauce(\s+if\s+using)?|add\s+your\s+sauce|top\s+with\s+sauce|sauce\s+of\s+your\s+choosing|sauce\s+of\s+your\s+choice|drizzle\s+with\s+sauce|sauce\s+or\s+garnishes)',
    caseSensitive: false,
  );
  return steps.map((s) {
    if (rx.hasMatch(s)) {
      return _suggestSauceStep(haystack);
    }
    return s;
  }).toList();
}

String _suggestSauceStep(String haystack) {
  String sauce;
  if (haystack.contains('tahini')) {
    sauce = 'a quick tahini-lemon drizzle (tahini, lemon juice, splash of water)';
  } else if (haystack.contains('peanut butter')) {
    sauce = 'a light peanut dressing (peanut butter, soy sauce, splash of water)';
  } else if (haystack.contains('yogurt') || haystack.contains('yoghurt') || haystack.contains('sour cream')) {
    sauce = 'a creamy yogurt drizzle (yogurt, lemon juice, garlic)';
  } else if (haystack.contains('soy sauce') || haystack.contains('miso') || haystack.contains('ginger')) {
    sauce = 'a soy-lime splash (soy sauce, lime, touch of oil)';
  } else if (haystack.contains('tomato') || haystack.contains('harissa') || haystack.contains('chipotle')) {
    sauce = 'a zesty olive-oil & lemon finish';
  } else {
    sauce = 'a zesty olive-oil & lemon finish';
  }
  return 'Finish with $sauce and serve.';
}

Set<String> _detectAllergens(String haystack) {
  final found = <String>{};
  bool hasAny(List<String> k) => k.any((x) => haystack.contains(x));

  if (hasAny(['milk','cheese','cream','butter','yogurt','yoghurt','ghee','whey','casein','curd','paneer','ricotta','mozzarella','parmesan','cheddar','feta','halloumi','sour cream','cream cheese','creme','crème'])) {
    found.add('dairy');
  }
  if (hasAny(['egg','eggs','albumen','mayonnaise','mayo'])) {
    found.add('egg');
  }
  if (hasAny(['wheat','flour','bread','pasta','noodle','breadcrumbs','couscous','semolina','bulgur','farro','spelt','rye','barley','malt','soy sauce'])) {
    found.add('gluten');
  }
  if (hasAny(['peanut','peanuts','almond','almonds','cashew','cashews','walnut','walnuts','pecan','pecans','pistachio','hazelnut','macadamia','brazil nut','nut butter'])) {
    found.add('nuts');
  }
  if (hasAny(['soy','soya','tofu','tempeh','miso','edamame'])) {
    found.add('soy');
  }
  if (hasAny(['fish','salmon','tuna','cod','mackerel','haddock','trout','sardine','sardines','anchovy','anchovies','tilapia','halibut','snapper','mahi','mahi-mahi','swordfish','catfish','pollock','herring'])) {
    found.add('fish');
  }
  if (hasAny(['seafood','prawn','prawns','shrimp','crab','lobster','scallop','mussel','mussels','clam','clams','octopus','squid','calamari'])) {
    found.add('shellfish');
  }
  if (hasAny(['sesame','tahini'])) {
    found.add('sesame');
  }
  return found;
}
