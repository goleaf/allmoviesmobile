import 'dart:io';

const _jsMaxSafeInteger = 9007199254740991;

void main(List<String> arguments) {
  final shouldFix = arguments.contains('--fix');
  final libDir = Directory('lib/data/local/isar');

  if (!libDir.existsSync()) {
    stderr.writeln('Could not find lib/data/local/isar.');
    exitCode = 1;
    return;
  }

  final dartFiles = libDir
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith('.g.dart'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  if (dartFiles.isEmpty) {
    stdout.writeln('No generated Isar schemas found.');
    return;
  }

  var hadViolations = false;

  for (final file in dartFiles) {
    final lines = file.readAsLinesSync();
    var changed = false;

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final match = RegExp(r'id: (-?\d+),').firstMatch(line);
      if (match == null) continue;

      final value = int.parse(match.group(1)!);
      if (value.abs() <= _jsMaxSafeInteger) {
        continue;
      }

      hadViolations = true;
      final safeValue = _clampToJsSafeInteger(value);

      if (shouldFix) {
        lines[i] = line.replaceFirst(match.group(0)!, 'id: $safeValue,');
        changed = true;
      } else {
        stdout.writeln(
          '[${file.path}] line ${i + 1}: $value exceeds JS safe integer range',
        );
      }
    }

    if (shouldFix && changed) {
      file.writeAsStringSync(lines.join('\n') + '\n');
      stdout.writeln('Adjusted IDs in ${file.path}');
    }
  }

  if (hadViolations) {
    if (shouldFix) {
      stdout.writeln('All offending IDs were clamped to the JS safe range.');
    } else {
      stderr
          .writeln('Found IDs outside the JS safe integer range. Run with --fix to update them.');
      exitCode = 1;
    }
  } else {
    stdout.writeln('All Isar schema IDs are within the JS safe integer range.');
  }
}

int _clampToJsSafeInteger(int value) {
  final max = _jsMaxSafeInteger;
  if (value >= 0) {
    return value % max;
  }
  return -((-value) % max);
}
