import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'features/shell/app_shell.dart';
import 'core/providers/auth_provider.dart';

import 'features/home/home_page.dart';
import 'features/onboarding/onboarding_page.dart';
import 'features/recipes/recipes_page.dart';
import 'features/recipes/recipe_detail_page.dart';
import 'features/weight/weight_page.dart';
import 'features/plan/plan_page.dart';
import 'features/shopping/shopping_list_page.dart';
import 'features/profile/profile_page.dart';
import 'features/auth/login_page.dart';
import 'features/auth/signup_page.dart';

final appRouter = GoRouter(
  redirect: (context, state) {
    final authProvider = context.read<AuthProvider>();
    final isLoggedIn = authProvider.isLoggedIn;
    
    // If user is not logged in and not on auth pages, redirect to login
    if (!isLoggedIn) {
      if (state.matchedLocation == '/login' || state.matchedLocation == '/signup') {
        return null; // Allow auth pages
      }
      return '/login';
    }
    
    // If user is logged in and on auth pages, redirect to home
    if (isLoggedIn && (state.matchedLocation == '/login' || state.matchedLocation == '/signup')) {
      return '/home';
    }
    
    return null;
  },
  initialLocation: '/login',
  routes: [
    // Auth routes
    GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
    GoRoute(path: '/signup', builder: (_, __) => const SignupPage()),
    
    // Main app routes
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

