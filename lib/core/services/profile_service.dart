import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile.dart';

class ProfileService{
  static const _kDailyKcal='pp_daily_kcal'; // legacy - kept for compatibility
  static const _kPrefProteins='pp_pref_proteins_v1';
  static const _kDietaryReqs='pp_dietary_reqs_v1';
  static const _kPlanGenerations='pp_plan_generations_v1';
  static const _kProfileJson='pp_profile_v1';

  // Legacy direct daily target (still available but not user-editable in new flow)
  static Future<void> saveDailyTarget(int kcal) async{ final sp=await SharedPreferences.getInstance(); await sp.setInt(_kDailyKcal,kcal);} 
  static Future<int?> loadDailyTarget() async{ final sp=await SharedPreferences.getInstance(); return sp.getInt(_kDailyKcal);} 

  static Future<void> savePreferredProteins(Set<String> proteins) async{ final sp=await SharedPreferences.getInstance(); await sp.setStringList(_kPrefProteins, proteins.toList()); }
  static Future<Set<String>> loadPreferredProteins() async{ final sp=await SharedPreferences.getInstance(); final list=sp.getStringList(_kPrefProteins); return list==null? <String>{} : list.toSet(); }

  static Future<void> saveDietaryRequirements(Set<String> dietary) async{ final sp=await SharedPreferences.getInstance(); await sp.setStringList(_kDietaryReqs, dietary.toList()); }
  static Future<Set<String>> loadDietaryRequirements() async{ final sp=await SharedPreferences.getInstance(); final list=sp.getStringList(_kDietaryReqs); return list==null? <String>{} : list.toSet(); }

  // Track plan generations by date (YYYY-MM-DD format)
  static Future<void> recordPlanGeneration() async{
    final sp = await SharedPreferences.getInstance();
    final today = DateTime.now().toString().split(' ')[0]; // YYYY-MM-DD
    final list = sp.getStringList(_kPlanGenerations) ?? [];
    if (!list.contains(today)) {
      list.add(today);
      await sp.setStringList(_kPlanGenerations, list);
    }
  }

  static Future<int> getWeeklyPlanCount() async{
    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList(_kPlanGenerations) ?? [];
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    int count = 0;
    for (final dateStr in list) {
      try {
        final date = DateTime.parse(dateStr);
        if (date.isAfter(sevenDaysAgo) && date.isBefore(now.add(const Duration(days: 1)))) {
          count++;
        }
      } catch (_) {}
    }
    return count;
  }

  // New profile storage
  static Future<void> saveProfile(Profile p) async{
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kProfileJson, jsonEncode(p.toJson()));
  }

  static Future<Profile?> loadProfile() async{
    final sp = await SharedPreferences.getInstance();
    final s = sp.getString(_kProfileJson);
    if (s==null) return null;
    try{
      final m = (jsonDecode(s) as Map).cast<String, Object?>();
      return Profile.fromJson(m);
    }catch(_){ return null; }
  }

  /// Compute daily target taking profile and weekly weight change into account.
  /// Falls back to legacy saved daily target if profile insufficient.
  static Future<int?> computeDailyTarget() async{
    final p = await loadProfile();
    final profTarget = p?.computeDailyTarget();
    if (profTarget != null) return profTarget;
    return await loadDailyTarget();
  }
}
