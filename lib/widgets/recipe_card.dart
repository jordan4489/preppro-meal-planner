import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/models/recipe.dart';
import '../core/services/favorites_service.dart';
import '../core/services/recipe_metrics.dart';
import '../core/services/personalization_service.dart';

class RecipeCard extends StatefulWidget {
  final Recipe recipe;
  final VoidCallback? onTap;
  const RecipeCard({super.key, required this.recipe, this.onTap});
  
  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cs = Theme.of(context).colorScheme;
        final isCompact = constraints.maxWidth < 430;
        final isFav = favoritesService.isFavorite(widget.recipe.title);
        final displayTitle = widget.recipe.displayTitle;
        final firstLetter = displayTitle.isNotEmpty ? displayTitle[0].toUpperCase() : '?';
        final imagePath = widget.recipe.image;
        final tileSize = isCompact ? 64.0 : 80.0;
        final padding = isCompact ? 12.0 : 18.0;
        final trailingWidth = isCompact ? 60.0 : 72.0;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: cs.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // Full background logo watermark
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
                // Main content
                InkWell(
                  onTap: widget.onTap,
                  child: Padding(
                    padding: EdgeInsets.all(padding),
                    child: Row(children: [
                      Container(
                        width: tileSize,
                        height: tileSize,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [cs.primaryContainer, cs.secondaryContainer],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: cs.primary.withValues(alpha: 0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: imagePath != null && imagePath.isNotEmpty
                          ? Image.asset(
                              imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(
                                child: Text(
                                  firstLetter,
                                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                    color: cs.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                    fontSize: isCompact ? 28 : 38,
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                firstLetter,
                                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  color: cs.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isCompact ? 28 : 38,
                                ),
                              ),
                            ),
                    ),
                  ),
            SizedBox(width: isCompact ? 10 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: isCompact ? 14 : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isCompact ? 6 : 8),
                  Row(
                    children: [
                      Icon(Icons.local_fire_department, size: isCompact ? 14 : 16, color: cs.primary),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.recipe.nutritionKcal} kcal',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: isCompact ? 12 : null,
                        ),
                      ),
                      SizedBox(width: isCompact ? 8 : 12),
                      Icon(Icons.fitness_center, size: isCompact ? 14 : 16, color: cs.secondary),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '${widget.recipe.nutritionProtein}g protein',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: isCompact ? 12 : null,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isCompact ? 4 : 6),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: isCompact ? 12 : 14, color: cs.tertiary),
                      const SizedBox(width: 4),
                      Text(
                        RecipeMetrics.formatTime(RecipeMetrics.estimateTotalMinutes(widget.recipe)),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: isCompact ? 11 : null,
                        ),
                      ),
                      SizedBox(width: isCompact ? 8 : 12),
                      Icon(
                        RecipeMetrics.estimateDifficulty(widget.recipe) == 'Easy'
                            ? Icons.star
                            : RecipeMetrics.estimateDifficulty(widget.recipe) == 'Medium'
                                ? Icons.star_half
                                : Icons.stars,
                        size: isCompact ? 12 : 14,
                        color: RecipeMetrics.estimateDifficulty(widget.recipe) == 'Easy'
                            ? Colors.green
                            : RecipeMetrics.estimateDifficulty(widget.recipe) == 'Medium'
                                ? Colors.orange
                                : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          RecipeMetrics.estimateDifficulty(widget.recipe),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: isCompact ? 11 : null,
                            color: RecipeMetrics.estimateDifficulty(widget.recipe) == 'Easy'
                                ? Colors.green
                                : RecipeMetrics.estimateDifficulty(widget.recipe) == 'Medium'
                                    ? Colors.orange
                                    : Colors.red,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Trailing icons with constrained width
            SizedBox(
              width: trailingWidth,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (widget.recipe.isAirFryer)
                      Container(
                        padding: EdgeInsets.all(isCompact ? 4 : 6),
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          color: cs.tertiaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.air,
                          size: isCompact ? 14 : 16,
                          color: cs.onTertiaryContainer,
                        ),
                      ),
                    IconButton(
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? Colors.red : cs.outline,
                        size: isCompact ? 20 : 22,
                      ),
                      onPressed: () async {
                        final nextFav = !isFav;
                        HapticFeedback.selectionClick();
                        await favoritesService.toggle(widget.recipe.title);
                        await PersonalizationService.recordFavorite(widget.recipe.id, nextFav);
                        setState(() {});
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
          ],
        ),
      ),
    );
      },
    );
  }
}
