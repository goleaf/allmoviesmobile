import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all locale JSON files share the same key structure', () {
    final directory = Directory('lib/core/localization/languages');
    expect(directory.existsSync(), isTrue,
        reason: 'languages directory must exist');

    final baseFile = File('${directory.path}/en.json');
    expect(baseFile.existsSync(), isTrue,
        reason: 'English localization file must exist');

    final Map<String, dynamic> baseData =
        jsonDecode(baseFile.readAsStringSync()) as Map<String, dynamic>;
    final baseKeys = _collectKeys(baseData);

    final files = directory
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.json'));

    for (final file in files) {
      final Map<String, dynamic> data =
          jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final keys = _collectKeys(data);
      expect(keys, baseKeys, reason: 'Key mismatch in ${file.path}');
    }
  });
}

Set<String> _collectKeys(Map<String, dynamic> data, [String prefix = '']) {
  final keys = <String>{};
  data.forEach((key, value) {
    final fullKey = prefix.isEmpty ? key : '$prefix.$key';
    if (value is Map<String, dynamic>) {
      keys.addAll(_collectKeys(value, fullKey));
    } else {
      keys.add(fullKey);
    }
  });
  return keys;
}
