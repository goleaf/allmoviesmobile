import 'dart:io';

Future<void> main(List<String> arguments) async {
  final steps = <_CommandStep>[
    _CommandStep('Format check', ['dart', 'format', '--output=none', '--set-exit-if-changed', 'lib', 'test', 'integration_test']),
    _CommandStep('Flutter analyze', ['flutter', 'analyze', '--no-pub']),
    _CommandStep('Flutter tests', ['flutter', 'test']),
  ];

  for (final step in steps) {
    stdout.writeln('• ${step.description}');
    final result = await Process.run(
      step.command.first,
      step.command.sublist(1),
      runInShell: true,
    );
    stdout.write(result.stdout);
    stderr.write(result.stderr);
    if (result.exitCode != 0) {
      stderr.writeln('Command failed: ${step.command.join(' ')}');
      exit(result.exitCode);
    }
  }

  stdout.writeln('Quality gate completed successfully.');
}

class _CommandStep {
  const _CommandStep(this.description, this.command);

  final String description;
  final List<String> command;
}
