import '../models/recipe.dart';

class RecipeMetrics {
  static int estimateTotalMinutes(Recipe r) {
    // Estimate based on steps, ingredients, and cooking method
    final stepCount = r.steps?.length ?? 5;
    final ingredientCount = r.ingredients?.length ?? 8;
    
    int base = stepCount * 3 + ingredientCount * 2;
    
    // Air fryer recipes are typically faster
    if (r.isAirFryer) base = (base * 0.7).round();
    
    // Complex tags take longer
    if (r.tags.any((t) => t.toLowerCase().contains('roast') || t.toLowerCase().contains('slow'))) {
      base += 30;
    }
    
    return base.clamp(10, 120);
  }
  
  static String estimateDifficulty(Recipe r) {
    final stepCount = r.steps?.length ?? 5;
    final ingredientCount = r.ingredients?.length ?? 8;
    
    int score = 0;
    
    // More steps = harder
    if (stepCount > 8) score += 2;
    else if (stepCount > 5) score += 1;
    
    // More ingredients = harder
    if (ingredientCount > 12) score += 2;
    else if (ingredientCount > 8) score += 1;
    
    // Air fryer simplifies
    if (r.isAirFryer) score -= 1;
    
    // Complexity keywords
    if (r.steps != null) {
      final stepsText = r.steps!.join(' ').toLowerCase();
      if (stepsText.contains('marinade') || stepsText.contains('marinate')) score += 1;
      if (stepsText.contains('proof') || stepsText.contains('rise')) score += 2;
      if (stepsText.contains('fold') || stepsText.contains('whisk')) score += 1;
    }
    
    if (score <= 1) return 'Easy';
    if (score <= 3) return 'Medium';
    return 'Hard';
  }
  
  static String formatTime(int minutes) {
    if (minutes < 60) return '${minutes}min';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) return '${hours}h';
    return '${hours}h ${mins}min';
  }
}
