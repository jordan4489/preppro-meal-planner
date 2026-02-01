enum Sex { male, female, other }

enum ActivityLevel { sedentary, light, moderate, active, veryActive }

class Profile {
  final double? weightKg; // always stored in kg
  final double? heightCm; // always stored in cm
  final int? age;
  final Sex? sex;
  final ActivityLevel activity;
  final double? targetWeightKg;
  final double? weeklyWeightChangeKg; // negative for loss
  final DateTime? targetDate; // target date for reaching goal weight
  final String units; // 'metric' or 'imperial'
  final bool consentTelemetry; // whether user consented to crash/usage telemetry

  Profile({
    this.weightKg,
    this.heightCm,
    this.age,
    this.sex,
    this.activity = ActivityLevel.moderate,
    this.targetWeightKg,
    this.weeklyWeightChangeKg,
    this.targetDate,
    this.units = 'metric',
    this.consentTelemetry = false,
  });

  Profile copyWith({
    double? weightKg,
    double? heightCm,
    int? age,
    Sex? sex,
    ActivityLevel? activity,
    double? targetWeightKg,
    double? weeklyWeightChangeKg,
    DateTime? targetDate,
    String? units,
    bool? consentTelemetry,
  }) => Profile(
        weightKg: weightKg ?? this.weightKg,
        heightCm: heightCm ?? this.heightCm,
        age: age ?? this.age,
        sex: sex ?? this.sex,
        activity: activity ?? this.activity,
        targetWeightKg: targetWeightKg ?? this.targetWeightKg,
        weeklyWeightChangeKg: weeklyWeightChangeKg ?? this.weeklyWeightChangeKg,
        targetDate: targetDate ?? this.targetDate,
        units: units ?? this.units,
        consentTelemetry: consentTelemetry ?? this.consentTelemetry,
      );

  double? computeBmr() {
    if (weightKg == null || heightCm == null || age == null || sex == null) return null;
    final w = weightKg!;
    final h = heightCm!;
    final a = age!;
    if (sex == Sex.male) {
      return 10 * w + 6.25 * h - 5 * a + 5; // Mifflin-St Jeor
    } else if (sex == Sex.female) {
      return 10 * w + 6.25 * h - 5 * a - 161;
    } else {
      return 10 * w + 6.25 * h - 5 * a - 78; // neutral-ish
    }
  }

  double activityMultiplier() {
    switch (activity) {
      case ActivityLevel.sedentary:
        return 1.2;
      case ActivityLevel.light:
        return 1.375;
      case ActivityLevel.moderate:
        return 1.55;
      case ActivityLevel.active:
        return 1.725;
      case ActivityLevel.veryActive:
        return 1.9;
    }
  }

  /// Returns estimated daily calorie target (rounded int) or null if not enough data
  int? computeDailyTarget() {
    final b = computeBmr();
    if (b == null) return null;
    final tdee = b * activityMultiplier();
    // Apply weekly change if provided
    var adjust = 0.0;
    if (weeklyWeightChangeKg != null) {
      // 1 kg fat ~= 7700 kcal
      adjust = (weeklyWeightChangeKg! * 7700.0) / 7.0;
    } else if (targetWeightKg != null && weightKg != null && targetDate != null) {
      // Calculate weekly rate from target date and weight difference
      final weightDiff = targetWeightKg! - weightKg!;
      final now = DateTime.now();
      final daysRemaining = targetDate!.difference(now).inDays;
      if (daysRemaining > 0) {
        final weeksRemaining = daysRemaining / 7.0;
        final weeklyRate = weightDiff / weeksRemaining;
        // 1 kg fat ~= 7700 kcal
        adjust = (weeklyRate * 7700.0) / 7.0;
      }
    }
    final res = (tdee + adjust).round();
    return res;
  }

  Map<String, Object?> toJson() => {
        'weightKg': weightKg,
        'heightCm': heightCm,
        'age': age,
        'sex': sex?.name,
        'activity': activity.name,
        'targetWeightKg': targetWeightKg,
        'weeklyWeightChangeKg': weeklyWeightChangeKg,
        'targetDate': targetDate?.toIso8601String(),
        'units': units,
        'consentTelemetry': consentTelemetry,
      };

  static Profile fromJson(Map<String, Object?> json) {
    Sex? sex;
    if (json['sex'] is String) {
      final s = (json['sex'] as String);
      if (s == 'male') sex = Sex.male;
      if (s == 'female') sex = Sex.female;
      if (s == 'other') sex = Sex.other;
    }
    ActivityLevel activity = ActivityLevel.moderate;
    if (json['activity'] is String) {
      final s = json['activity'] as String;
      activity = ActivityLevel.values.firstWhere((e) => e.name == s, orElse: () => ActivityLevel.moderate);
    }
    final units = (json['units'] as String?) ?? 'metric';
    final consent = (json['consentTelemetry'] is bool) ? (json['consentTelemetry'] as bool) : (json['consentTelemetry'] is String ? (json['consentTelemetry'] == 'true') : false);
    DateTime? targetDate;
    if (json['targetDate'] is String) {
      try {
        targetDate = DateTime.parse(json['targetDate'] as String);
      } catch (_) {}
    }
    return Profile(
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      age: (json['age'] as num?)?.toInt(),
      sex: sex,
      activity: activity,
      targetWeightKg: (json['targetWeightKg'] as num?)?.toDouble(),
      weeklyWeightChangeKg: (json['weeklyWeightChangeKg'] as num?)?.toDouble(),
      targetDate: targetDate,
      units: units,
      consentTelemetry: consent,
    );
  }

}
