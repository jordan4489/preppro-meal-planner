import 'package:flutter_test/flutter_test.dart';
import 'package:preppro/core/models/profile.dart';

void main(){
  test('BMR and daily target male example', (){
    final p = Profile(weightKg: 70, heightCm: 175, age: 30, sex: Sex.male, activity: ActivityLevel.moderate);
    final b = p.computeBmr();
    expect(b, isNotNull);
    final daily = p.computeDailyTarget();
    expect(daily, isNotNull);
    // basic sanity
    expect(daily! > 1500, true);
    expect(daily < 3500, true);
  });

  test('Weekly change adjusts target', (){
    final p1 = Profile(weightKg: 70, heightCm: 175, age: 30, sex: Sex.male, activity: ActivityLevel.moderate, weeklyWeightChangeKg: -0.5);
    final t1 = p1.computeDailyTarget();
    final p2 = Profile(weightKg: 70, heightCm: 175, age: 30, sex: Sex.male, activity: ActivityLevel.moderate);
    final t2 = p2.computeDailyTarget();
    expect(t1, isNotNull);
    expect(t2, isNotNull);
    expect(t1! < t2!, true);
  });

  test('Telemetry consent defaults to false and serializes', (){
    final p = Profile();
    expect(p.consentTelemetry, false);
    final j = p.toJson();
    expect(j['consentTelemetry'], false);

    final p2 = Profile.fromJson({'consentTelemetry': true});
    expect(p2.consentTelemetry, true);
  });
}
