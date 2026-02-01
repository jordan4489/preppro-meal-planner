import 'package:go_router/go_router.dart';
import 'features/shell/app_shell.dart';

import 'features/home/home_page.dart';
import 'features/onboarding/onboarding_page.dart';
import 'features/recipes/recipes_page.dart';
import 'features/recipes/recipe_detail_page.dart';
import 'features/weight/weight_page.dart';
import 'features/plan/plan_page.dart';
import 'features/shopping/shopping_list_page.dart';
import 'features/profile/profile_page.dart';

final appRouter = GoRouter(
  initialLocation: '/home', // ← start on Home

  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/home', builder: (_, __) => const HomePage()),
        GoRoute(
          path: '/recipes',
          builder: (context, state) {
            final filter = state.extra as Map<String, dynamic>?;
            return RecipesPage(filter: filter);
          },
        ),
        GoRoute(
            path: '/recipe/:id',
            builder: (context, state) =>
                RecipeDetailPage(recipeId: state.pathParameters['id']!)),
        GoRoute(path: '/plan', builder: (_, __) => const PlanPage()),
        GoRoute(path: '/weight', builder: (_, __) => const WeightPage()),
        GoRoute(path: '/shopping', builder: (_, __) => const ShoppingListPage()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
      ],
    ),
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingPage()),
  ],
);

