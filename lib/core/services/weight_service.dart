import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class WeightEntry { final String date; final double weightKg; WeightEntry({required this.date, required this.weightKg});
  Map<String,dynamic> toJson()=>{'date':date,'weight':weightKg};
  static WeightEntry fromJson(Map<String,dynamic> j)=> WeightEntry(date:j['date'], weightKg:(j['weight'] as num).toDouble()); }
class WeightService { static const _k='pp_weights_v1';
  static Future<List<WeightEntry>> load() async{ final sp=await SharedPreferences.getInstance(); final s=sp.getString(_k); if(s==null) return []; try{ final list=(jsonDecode(s) as List).cast<Map<String,dynamic>>(); return list.map(WeightEntry.fromJson).toList(); }catch(_){ return []; } }
  static Future<void> save(List<WeightEntry> e) async{ final sp=await SharedPreferences.getInstance(); await sp.setString(_k, jsonEncode(e.map((x)=>x.toJson()).toList())); }
  static Future<void> add(WeightEntry e) async{ final list=await load(); final idx=list.indexWhere((x)=>x.date==e.date); if(idx>=0){ list[idx]=e; } else { list.add(e); } list.sort((a,b)=> b.date.compareTo(a.date)); await save(list); } }
