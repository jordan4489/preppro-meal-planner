import 'dart:io';

void main(List<String> args) {
  final minArg = args.isNotEmpty ? args[0] : '65';
  final min = int.tryParse(minArg) ?? 65;
  final f = File('coverage/lcov.info');
  if (!f.existsSync()) {
    print('No coverage/lcov.info found');
    exit(1);
  }
  final lines = f.readAsLinesSync();
  int total = 0;
  int covered = 0;
  for (var line in lines) {
    if (line.startsWith('DA:')) {
      final parts = line.substring(3).split(',');
      if (parts.length == 2) {
        total++;
        if (int.tryParse(parts[1]) != null && parts[1] != '0') covered++;
      }
    }
  }
  if (total == 0) {
    print('No instrumented lines found in lcov');
    exit(1);
  }
  final pct = (covered / total * 100).round();
  print('Coverage: $pct% ($covered/$total)');
  if (pct < min) {
    print('Coverage $pct% is below required $min%');
    exit(2);
  }
}
