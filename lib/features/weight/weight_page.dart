import 'package:flutter/material.dart';
import '../../core/services/weight_service.dart';
import '../../core/services/profile_service.dart';

class WeightPage extends StatefulWidget {
  const WeightPage({super.key});
  @override
  State<WeightPage> createState() => _S();
}

class _S extends State<WeightPage> {
  final _controller = TextEditingController();
  bool _saving = false;
  List<WeightEntry> _entries = [];
  @override
  void initState() {
    super.initState();
    _load();
  }

  String _today() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _load() async {
    final list = await WeightService.load();
    setState(() => _entries = list);
  }

  Future<void> _save() async {
    final v = double.tryParse(_controller.text);
    if (v == null || v <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a valid weight (kg).')));
      return;
    }
    setState(() => _saving = true);
    await WeightService.add(WeightEntry(date: _today(), weightKg: v));
    await _load();
    setState(() => _saving = false);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Weight tracker'),
      ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.035,
                child: Image.asset(
                  'assets/images/logo_preppro_blue.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  errorBuilder: (_, __, ___) => const SizedBox(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
              Row(children: [
                Expanded(
                    child: TextField(
                        controller: _controller,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                            labelText: "Today's weight (kg)"))),
                const SizedBox(width: 12),
                FilledButton(
                    onPressed: _saving ? null : _save,
                    child:
                        _saving ? const Text('Saving...') : const Text('Save'))
              ]),
              const SizedBox(height: 24),
              // Progress Overview
              if (_entries.isNotEmpty) ...[
                _WeightProgressCard(entries: _entries),
                const SizedBox(height: 16),
              ],
              // Entries list header
              Row(
                children: [
                  const Icon(Icons.history),
                  const SizedBox(width: 8),
                  Text(
                    'Weight History',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                  child: _entries.isEmpty
                      ? const Center(child: Text('No entries yet.'))
                      : ListView.separated(
                          itemCount: _entries.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final e = _entries[i];
                            return ListTile(
                                leading: const Icon(Icons.monitor_weight),
                                title: Text('${e.weightKg} kg'),
                                subtitle: Text(e.date));
                          }))
            ])),
          ],
        ));
  }
}

class _WeightProgressCard extends StatefulWidget {
  final List<WeightEntry> entries;
  const _WeightProgressCard({required this.entries});
  
  @override
  State<_WeightProgressCard> createState() => _WeightProgressCardState();
}

class _WeightProgressCardState extends State<_WeightProgressCard> {
  double? targetWeight;
  
  @override
  void initState() {
    super.initState();
    _loadTarget();
  }
  
  Future<void> _loadTarget() async {
    final profile = await ProfileService.loadProfile();
    setState(() => targetWeight = profile?.targetWeightKg);
  }
  
  @override
  Widget build(BuildContext context) {
    if (widget.entries.isEmpty) return const SizedBox.shrink();
    
    final cs = Theme.of(context).colorScheme;
    final sortedEntries = widget.entries.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    
    final currentWeight = sortedEntries.last.weightKg;
    final startWeight = sortedEntries.first.weightKg;
    final change = currentWeight - startWeight;
    final daysTracked = sortedEntries.length;
    
    // Calculate min/max for chart
    final weights = sortedEntries.map((e) => e.weightKg).toList();
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);
    final range = maxWeight - minWeight;
    final chartMin = minWeight - (range * 0.1);
    final chartMax = maxWeight + (range * 0.1);
    
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_down, color: cs.primary, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Progress Overview',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Stats row
            Row(
              children: [
                Expanded(
                  child: _StatBox(
                    label: 'Current',
                    value: '${currentWeight.toStringAsFixed(1)} kg',
                    color: cs.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatBox(
                    label: 'Change',
                    value: '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)} kg',
                    color: change < 0 ? Colors.green : Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatBox(
                    label: 'Days',
                    value: '$daysTracked',
                    color: cs.secondary,
                  ),
                ),
              ],
            ),
            if (targetWeight != null) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: ((startWeight - currentWeight) / (startWeight - targetWeight!)).clamp(0.0, 1.0),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Text(
                'Goal: ${targetWeight!.toStringAsFixed(1)} kg (${(currentWeight - targetWeight!).toStringAsFixed(1)} kg to go)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 20),
            // Mini chart
            SizedBox(
              height: 120,
              child: CustomPaint(
                painter: _WeightChartPainter(
                  entries: sortedEntries,
                  minWeight: chartMin,
                  maxWeight: chartMax,
                  color: cs.primary,
                ),
                size: const Size(double.infinity, 120),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeightChartPainter extends CustomPainter {
  final List<WeightEntry> entries;
  final double minWeight;
  final double maxWeight;
  final Color color;

  _WeightChartPainter({
    required this.entries,
    required this.minWeight,
    required this.maxWeight,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.isEmpty || maxWeight <= minWeight) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final points = <Offset>[];

    for (int i = 0; i < entries.length; i++) {
      final x = (i / (entries.length - 1).clamp(1, double.infinity)) * size.width;
      final normalizedY = (entries[i].weightKg - minWeight) / (maxWeight - minWeight);
      final y = size.height - (normalizedY * size.height);

      points.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Draw line
    canvas.drawPath(path, paint);

    // Draw points
    for (final point in points) {
      canvas.drawCircle(point, 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
