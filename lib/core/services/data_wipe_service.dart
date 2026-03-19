import 'package:shared_preferences/shared_preferences.dart';

/// Utility for removing all locally-stored PrepPro data for the current user.
///
/// This is used as part of the in-app "Delete account" flow to ensure
/// profile, plans, weights, favourites, and personalization data are cleared
/// from the device.
class DataWipeService {
  static const _keysToRemove = <String>[
    // Profile & preferences
    'pp_profile_v1',
    'pp_daily_kcal',
    'pp_pref_proteins_v1',
    'pp_dietary_reqs_v1',
    'pp_plan_generations_v1',

    // Plans & meal checks
    'pp_saved_plan_v1',
    'pp_meal_checks_v1',

    // Weights
    'pp_weights_v1',

    // Shopping/budget helpers
    'pp_budget_enabled_v1',
    'pp_budget_amount_v1',

    // Favourites & personalization
    'favorites',
    'pp_recipe_views_v1',
    'pp_recipe_favs_v1',
  ];

  /// Remove all known app keys from SharedPreferences.
  static Future<void> wipeAllLocal() async {
    final sp = await SharedPreferences.getInstance();
    for (final key in _keysToRemove) {
      await sp.remove(key);
    }
  }
}
