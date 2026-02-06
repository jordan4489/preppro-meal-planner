
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PlanStore{
  static const _k='pp_saved_plan_v1';
  static const _kChecks='pp_meal_checks_v1';
  // Save days as list of days; each day is list of maps {id: string, servings: number}
  static Future<void> save(List<List<Map<String,Object>>> days) async{ final sp=await SharedPreferences.getInstance(); await sp.setString(_k,jsonEncode({'days':days})); }

  // Load returns list of days; each day is list of maps {id, servings}
  // Backwards compatible: if stored as list of lists of ids, convert to servings=1.0
  static Future<List<List<Map<String,Object>>>?> load() async{ final sp=await SharedPreferences.getInstance(); final s=sp.getString(_k); if(s==null) return null; try{ final m=jsonDecode(s);
    if(m is Map && m['days'] is List){
      final raw = m['days'] as List;
      final out = <List<Map<String,Object>>>[];
      for(final d in raw){
        if(d is List){
          if(d.isEmpty) { out.add([]); continue; }
          if(d.first is String){
            out.add(d.map((e)=> {'id': e.toString(), 'servings': 1.0}).toList());
          } else if(d.first is Map){
            out.add(d.map((e)=> Map<String,Object>.from(e)).toList());
          } else {
            out.add([]);
          }
        }
      }
      return out;
    }
    return null; }catch(_){ return null; } }

  static Future<void> saveMealChecks(Map<String,bool> checks) async{
    final sp=await SharedPreferences.getInstance();
    await sp.setString(_kChecks, jsonEncode(checks));
  }

  static Future<Map<String,bool>> loadMealChecks() async{
    final sp=await SharedPreferences.getInstance();
    final s=sp.getString(_kChecks);
    if(s==null) return {};
    try{
      final m=jsonDecode(s);
      if(m is Map){
        return m.map((k,v)=> MapEntry(k.toString(), v==true));
      }
      return {};
    }catch(_){
      return {};
    }
  }

  static Future<void> clear() async{
    final sp=await SharedPreferences.getInstance();
    await sp.remove(_k);
    await sp.remove(_kChecks);
  }
}
