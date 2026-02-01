import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/profile_service.dart';
import '../../core/models/profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

Future<int?> showDailyTargetEditor(BuildContext context, int? initial) async {
  // Deprecated in new flow - target now derived from profile
  return null;
}

class _ProfilePageState extends State<ProfilePage> {
  Profile _profile = Profile();

  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  Sex? _sex;
  ActivityLevel _activity = ActivityLevel.moderate;
  final _targetWeightCtrl = TextEditingController();
  final _weeklyChangeCtrl = TextEditingController();
  DateTime? _targetDate;
  String _units = 'metric'; // 'metric' or 'imperial'

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await ProfileService.loadProfile();
    if (p != null) {
      setState(() {
        _profile = p;
        _units = p.units;
        // show in appropriate units
        if (p.units == 'imperial') {
          // convert kg->lb, cm->inch
          _weightCtrl.text = p.weightKg == null ? '' : (p.weightKg! * 2.2046226218).toStringAsFixed(1);
          _heightCtrl.text = p.heightCm == null ? '' : (p.heightCm! / 2.54).toStringAsFixed(1);
          _targetWeightCtrl.text = p.targetWeightKg == null ? '' : (p.targetWeightKg! * 2.2046226218).toStringAsFixed(1);
        } else {
          _weightCtrl.text = p.weightKg?.toStringAsFixed(1) ?? '';
          _heightCtrl.text = p.heightCm?.toStringAsFixed(1) ?? '';
          _targetWeightCtrl.text = p.targetWeightKg?.toStringAsFixed(1) ?? '';
        }
        _ageCtrl.text = p.age?.toString() ?? '';
        _sex = p.sex;
        _activity = p.activity;
        _weeklyChangeCtrl.text = p.weeklyWeightChangeKg?.toStringAsFixed(2) ?? '';
        _targetDate = p.targetDate;
      });
    }
  }

  Future<void> _save() async {
    double? w = double.tryParse(_weightCtrl.text);
    double? h = double.tryParse(_heightCtrl.text);
    final a = int.tryParse(_ageCtrl.text);
    double? tw = double.tryParse(_targetWeightCtrl.text);
    final wc = double.tryParse(_weeklyChangeCtrl.text);

    // convert inputs if imperial
    if (_units == 'imperial') {
      if (w != null) w = w / 2.2046226218; // lb -> kg
      if (h != null) h = h * 2.54; // in -> cm
      if (tw != null) tw = tw / 2.2046226218;
    }

    final p = _profile.copyWith(
      weightKg: w,
      heightCm: h,
      age: a,
      sex: _sex,
      activity: _activity,
      targetWeightKg: tw,
      weeklyWeightChangeKg: wc,
      targetDate: _targetDate,
    );
    // store units preference
    final pWithUnits = p.copyWith();
    final pFinal = Profile(
      weightKg: pWithUnits.weightKg,
      heightCm: pWithUnits.heightCm,
      age: pWithUnits.age,
      sex: pWithUnits.sex,
      activity: pWithUnits.activity,
      targetWeightKg: pWithUnits.targetWeightKg,
      weeklyWeightChangeKg: pWithUnits.weeklyWeightChangeKg,
      targetDate: pWithUnits.targetDate,
      units: _units,
      consentTelemetry: _profile.consentTelemetry,
    );
    await ProfileService.saveProfile(pFinal);
    setState(() => _profile = pFinal);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved')));
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _ageCtrl.dispose();
    _targetWeightCtrl.dispose();
    _weeklyChangeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final daily = _profile.computeDailyTarget();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('Profile'),
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
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your profile helps calculate personalized calorie targets and meal plans.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.flag),
            title: const Text('Calculated daily calorie target'),
            subtitle: Text(daily == null ? 'Enter weight/height/age to compute' : 'Target: $daily kcal'),
            trailing: IconButton(onPressed: (){
              // explain computation
              final b = _profile.computeBmr();
              final mult = _profile.activityMultiplier();
              final tdee = b==null ? null : (b * mult).round();
              var adj = 0;
              String adjSource = 'None';
              if (_profile.weeklyWeightChangeKg != null) {
                adj = ((_profile.weeklyWeightChangeKg! * 7700.0)/7.0).round();
                adjSource = 'Weekly change (${_profile.weeklyWeightChangeKg!.toStringAsFixed(2)} kg/wk)';
              } else if (_profile.targetWeightKg != null && _profile.weightKg != null && _profile.targetDate != null) {
                final weightDiff = _profile.targetWeightKg! - _profile.weightKg!;
                final daysRemaining = _profile.targetDate!.difference(DateTime.now()).inDays;
                if (daysRemaining > 0) {
                  final weeksRemaining = daysRemaining / 7.0;
                  final weeklyRate = weightDiff / weeksRemaining;
                  adj = ((weeklyRate * 7700.0) / 7.0).round();
                  adjSource = 'Target date (${weeklyRate.toStringAsFixed(2)} kg/wk over ${weeksRemaining.toStringAsFixed(1)} weeks)';
                }
              }
              showDialog(context: context, builder: (_) => AlertDialog(title: const Text('How target is calculated'), content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text('BMR: ${b==null?"—": b.round().toString()} kcal'), Text('Activity multiplier: ${mult.toStringAsFixed(2)} → TDEE: ${tdee==null?"—": tdee} kcal'), Text('Adjustment source: $adjSource'), Text('Daily adjustment: ${adj==0?"—": "$adj kcal/day"}')] ), actions: [TextButton(onPressed: ()=> Navigator.pop(context), child: const Text('Close'))]));
            }, icon: const Icon(Icons.info_outline)),
          ),
          const SizedBox(height: 12),
          const Text('Your details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(controller: _weightCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Weight (kg)')),
          const SizedBox(height: 8),
          TextField(controller: _heightCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: _units == 'metric' ? 'Height (cm)' : 'Height (in)')),
          const SizedBox(height: 8),
          TextField(controller: _ageCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Age')),
          const SizedBox(height: 8),
          Row(children: [
            const Text('Sex: '),
            const SizedBox(width: 8),
            DropdownButton<Sex>(value: _sex, hint: const Text('Select'), items: Sex.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(), onChanged: (v) => setState(() => _sex = v)),
            const SizedBox(width: 24),
            const Text('Units: '),
            const SizedBox(width: 8),
            DropdownButton<String>(value: _units, items: const [DropdownMenuItem(value: 'metric', child: Text('kg/cm')), DropdownMenuItem(value: 'imperial', child: Text('lb/in'))], onChanged: (v) => setState(() => _units = v ?? 'metric'))
          ]),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Allow crash & usage telemetry'),
            subtitle: const Text('Help us improve the app by sending anonymous crash reports and usage metrics.'),
            value: _profile.consentTelemetry,
            onChanged: (v) => setState(() => _profile = _profile.copyWith(consentTelemetry: v)),
            secondary: IconButton(onPressed: (){
              showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Telemetry details'), content: const Text('Telemetry includes anonymous crash reports and basic usage metrics (screen views and errors). No personal data like names or emails are sent. You can opt out anytime from this screen.'), actions: [TextButton(onPressed: ()=> Navigator.pop(context), child: const Text('Close'))]));
            }, icon: const Icon(Icons.info_outline)),
          ),
          const SizedBox(height: 8),
          Row(children: [
            const Text('Activity: '),
            const SizedBox(width: 8),
            DropdownButton<ActivityLevel>(value: _activity, items: ActivityLevel.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(), onChanged: (v) => setState(() => _activity = v!)),
          ]),
          const SizedBox(height: 12),
          const Text('Goal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(controller: _targetWeightCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: _units == 'metric' ? 'Target weight (kg)' : 'Target weight (lb)')),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today),
            title: Text(_targetDate == null ? 'Target date (optional)' : 'Target: ${_targetDate!.year}-${_targetDate!.month.toString().padLeft(2, '0')}-${_targetDate!.day.toString().padLeft(2, '0')}'),
            subtitle: _targetDate != null ? Text('${_targetDate!.difference(DateTime.now()).inDays} days remaining') : const Text('Set a goal date for automatic deficit calculation'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_targetDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => _targetDate = null),
                  ),
                IconButton(
                  icon: const Icon(Icons.edit_calendar),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _targetDate ?? DateTime.now().add(const Duration(days: 90)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 730)),
                    );
                    if (date != null) {
                      setState(() => _targetDate = date);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _weeklyChangeCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Weekly change (kg/week, negative for loss)',
              helperText: _targetDate == null ? 'Or set a target date above for auto-calculation' : 'Leave empty to use target date calculation',
            ),
          ),
          const SizedBox(height: 16),
          Row(children: [Expanded(child: FilledButton(onPressed: _save, child: const Text('Save'))), const SizedBox(width: 8), OutlinedButton(onPressed: () => context.go('/home'), child: const Text('Close'))])
        ]),
          ),
        ],
      ),
    );
  }
}
