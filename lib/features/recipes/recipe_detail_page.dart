import 'package:flutter/material.dart';
import '../../core/services/recipe_loader.dart';
import '../../core/services/favorites_service.dart';
import '../../core/services/recipe_metrics.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/recipe.dart';
import '../../core/services/personalization_service.dart';

class RecipeDetailPage extends StatefulWidget {
  final String recipeId;
  const RecipeDetailPage({super.key, required this.recipeId});

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  double servings = 1.0;
  bool _viewRecorded = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Recipe>>(
      future: RecipeLoader.load(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return Scaffold(
            body: Stack(
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.05,
                    child: Transform.scale(
                      scale: 0.6,
                      child: Image.asset(
                        'assets/images/PrepProBlue.png',
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        errorBuilder: (_, __, ___) => const SizedBox(),
                      ),
                    ),
                  ),
                ),
                const Center(child: CircularProgressIndicator()),
              ],
            ),
          );
        }
        final list = snap.data!;
        final r = list.firstWhere(
          (x) => x.id == widget.recipeId,
          orElse: () => Recipe(
            id: 'not_found',
            title: 'Not found',
            isAirFryer: false,
            mealTypes: const [],
            tags: const [],
            nutritionKcal: 0,
            nutritionProtein: 0,
            allergens: const {},
          ),
        );
        if (r.id == 'not_found') {
          return Scaffold(
            appBar: AppBar(title: const Text('Recipe')),
            body: Stack(
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.05,
                    child: Transform.scale(
                      scale: 0.6,
                      child: Image.asset(
                        'assets/images/PrepProBlue.png',
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        errorBuilder: (_, __, ___) => const SizedBox(),
                      ),
                    ),
                  ),
                ),
                const Center(child: Text('Recipe not found')),
              ],
            ),
          );
        }

        final cs = Theme.of(context).colorScheme;
        final isFav = favoritesService.isFavorite(r.title);
        final displayTitle = r.displayTitle;
        final imagePath = r.image;
        final allergens = r.allergens.toList()..sort();
        if (!_viewRecorded) {
          _viewRecorded = true;
          PersonalizationService.recordView(r.id);
        }
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final nextFav = !isFav;
              await favoritesService.toggle(r.title);
              await PersonalizationService.recordFavorite(r.id, nextFav);
              setState(() {});
            },
            child: Icon(isFav ? Icons.favorite : Icons.favorite_border),
          ),
          body: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.05,
                  child: Transform.scale(
                    scale: 0.6,
                    child: Image.asset(
                      'assets/images/PrepProBlue.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      errorBuilder: (_, __, ___) => const SizedBox(),
                    ),
                  ),
                ),
              ),
              CustomScrollView(slivers: [
                  SliverAppBar(
                    pinned: true,
                    expandedHeight: 240,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        displayTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(blurRadius: 8, color: Colors.black45)],
                        ),
                      ),
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (imagePath != null && imagePath.isNotEmpty)
                            Image.asset(
                              imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const SizedBox(),
                            ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [cs.primaryContainer, cs.secondaryContainer],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                          Center(
                            child: Icon(
                              Icons.restaurant_menu,
                              size: 80,
                              color: cs.primary.withValues(alpha: 0.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                    // Nutrition cards - Macros row
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.local_fire_department, color: cs.primary),
                                const SizedBox(width: 8),
                                Text(
                                  'Nutrition Facts',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Wrap(
                              alignment: WrapAlignment.spaceAround,
                              runSpacing: 12,
                              spacing: 12,
                              children: [
                                _MacroCard(
                                  icon: Icons.local_fire_department,
                                  label: 'Calories',
                                  value: '${(r.nutritionKcal * servings).round()}',
                                  unit: 'kcal',
                                  color: cs.primary,
                                ),
                                _MacroCard(
                                  icon: Icons.fitness_center,
                                  label: 'Protein',
                                  value: '${(r.nutritionProtein * servings).round()}',
                                  unit: 'g',
                                  color: Colors.red,
                                ),
                                _MacroCard(
                                  icon: Icons.bakery_dining,
                                  label: 'Carbs',
                                  value: '${(((r.nutritionKcal - (r.nutritionProtein * 4)).clamp(0, double.infinity) / 4) * servings).round()}',
                                  unit: 'g',
                                  color: Colors.orange,
                                ),
                                _MacroCard(
                                  icon: Icons.water_drop,
                                  label: 'Fats',
                                  value: '${(((r.nutritionKcal * 0.25).clamp(0, double.infinity) / 9) * servings).round()}',
                                  unit: 'g',
                                  color: Colors.blue,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Servings adjuster
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.restaurant),
                            const SizedBox(width: 12),
                            const Text('Servings:',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: servings > 0.5
                                  ? () => setState(() => servings -= 0.5)
                                  : null,
                            ),
                            Text('${servings.toStringAsFixed(1)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: servings < 10
                                  ? () => setState(() => servings += 0.5)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Time & Difficulty
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.access_time, color: cs.tertiary),
                                  const SizedBox(width: 8),
                                  Text(
                                    RecipeMetrics.formatTime(RecipeMetrics.estimateTotalMinutes(r)),
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    RecipeMetrics.estimateDifficulty(r) == 'Easy'
                                        ? Icons.star
                                        : RecipeMetrics.estimateDifficulty(r) == 'Medium'
                                            ? Icons.star_half
                                            : Icons.stars,
                                    color: RecipeMetrics.estimateDifficulty(r) == 'Easy'
                                        ? Colors.green
                                        : RecipeMetrics.estimateDifficulty(r) == 'Medium'
                                            ? Colors.orange
                                            : Colors.red,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    RecipeMetrics.estimateDifficulty(r),
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: RecipeMetrics.estimateDifficulty(r) == 'Easy'
                                          ? Colors.green
                                          : RecipeMetrics.estimateDifficulty(r) == 'Medium'
                                              ? Colors.orange
                                              : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Tags
                    if (r.isAirFryer || r.tags.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (r.isAirFryer)
                            Chip(
                              avatar: const Icon(Icons.air, size: 18),
                              label: const Text('Air Fryer'),
                              backgroundColor: cs.tertiaryContainer,
                            ),
                          for (final t in r.tags)
                            Chip(label: Text(t)),
                        ],
                      ),
                    if (r.isAirFryer || r.tags.isNotEmpty)
                      const SizedBox(height: 20),
                    // Servings slider
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Servings',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  servings.toStringAsFixed(2),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: cs.primary,
                                      ),
                                ),
                              ],
                            ),
                            Slider(
                              value: servings,
                              min: 0.25,
                              max: 4.0,
                              divisions: 15,
                              label: servings.toStringAsFixed(2),
                              onChanged: (v) => setState(() => servings = v),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Ingredients
                    if ((r.ingredients ?? []).isNotEmpty) ...[
                      Text(
                        'Ingredients',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            children: r.ingredients!
                                .map((ing) => ListTile(
                                      leading: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: cs.primaryContainer,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.check,
                                          size: 20,
                                          color: cs.onPrimaryContainer,
                                        ),
                                      ),
                                      title: Text(
                                        ing.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      trailing: Text(
                                        '${(ing.quantity * servings).toStringAsFixed(1)} ${ing.unit}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: cs.primary,
                                            ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                      if (allergens.isNotEmpty) ...[
                        Text(
                          'Allergens',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: allergens
                              .map((a) => Chip(
                                    label: Text(
                                      a[0].toUpperCase() + a.substring(1),
                                    ),
                                    backgroundColor: cs.errorContainer,
                                    labelStyle: TextStyle(color: cs.onErrorContainer),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Allergen info is best-effort. Verify ingredients if you have severe allergies.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 24),
                      ],
                    // Instructions
                    Text(
                      'Instructions',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    if ((r.steps ?? []).isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No instructions available.'),
                        ),
                      )
                    else
                      ...List.generate(
                        r.steps!.length,
                        (i) => Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: cs.primaryContainer,
                              radius: 20,
                              child: Text(
                                '${i + 1}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: cs.onPrimaryContainer,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            title: Text(
                              r.steps![i],
                              style: const TextStyle(height: 1.5),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 80),
                  ]),
                ),
              ),
            ],
          ),
          ],
        ),
        bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          GoRouter.of(context).go('/plan');
                        },
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text('Add to Plan'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          minimumSize: const Size(0, 48),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.tonal(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.all(14),
                        minimumSize: const Size(48, 48),
                      ),
                      child: const Icon(Icons.bookmark_border, size: 20),
                    ),
                  ],
                ),
              ),
            ),
        );
      },
    );
  }
}

class _MacroCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _MacroCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 28, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          unit,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
