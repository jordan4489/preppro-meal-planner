import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/recipe.dart';
class RecipeLoader{ static Future<List<Recipe>> load() async { try{ final raw=await rootBundle.loadString('assets/data/preppro_500_recipes.json'); final list=(jsonDecode(raw) as List).cast<Map<String,dynamic>>(); return list.map(Recipe.fromJson).toList(); }catch(_){ return <Recipe>[]; } }}
