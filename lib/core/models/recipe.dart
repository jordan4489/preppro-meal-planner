class Ingredient { final String name; final double quantity; final String unit;
  Ingredient({required this.name, required this.quantity, required this.unit});
  factory Ingredient.fromJson(Map<String,dynamic> j)=>Ingredient(name:j['name'], quantity:(j['quantity'] as num).toDouble(), unit:(j['unit']??'')); }
class Recipe { final String id; final String title; final bool isAirFryer; final List<String> mealTypes; final List<String> tags; final int nutritionKcal; final double nutritionProtein; final List<Ingredient>? ingredients; final List<String>? steps; final String? image;
  Recipe({required this.id,required this.title,required this.isAirFryer,required this.mealTypes,required this.tags,required this.nutritionKcal,required this.nutritionProtein,this.ingredients,this.steps,this.image});
  factory Recipe.fromJson(Map<String,dynamic> j) => Recipe(
      id: j['id'],
      title: j['title'],
      isAirFryer: (j['isAirFryer'] ?? false),
      mealTypes: (j['mealTypes'] as List).cast<String>(),
      tags: (j['tags'] as List).cast<String>(),
      nutritionKcal: (j['nutrition']['kcal'] as num).toInt(),
      nutritionProtein: (j['nutrition']['protein_g'] as num).toDouble(),
      image: j['image'] as String?,
      ingredients: j['ingredients'] == null
          ? null
          : (j['ingredients'] as List).map((e) => Ingredient.fromJson(e)).toList(),
      // Some data sources use 'steps', others use 'instructions'
      steps: j['steps'] != null
          ? (j['steps'] as List).cast<String>()
          : (j['instructions'] != null
              ? (j['instructions'] as List).cast<String>()
              : null));
}
