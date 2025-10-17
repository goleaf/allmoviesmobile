import 'dart:convert';
import 'dart:io';

Future<dynamic> loadFixture(String name) async {
  final file = File('test/test_support/fixtures/$name');
  final contents = await file.readAsString();
  return jsonDecode(contents);
}

Future<Map<String, dynamic>> loadJsonFixture(String name) async {
  final data = await loadFixture(name);
  if (data is Map<String, dynamic>) {
    return data;
  }
  throw StateError('Fixture $name did not decode into a JSON object.');
}

Future<List<dynamic>> loadJsonListFixture(String name) async {
  final data = await loadFixture(name);
  if (data is List<dynamic>) {
    return data;
  }
  throw StateError('Fixture $name did not decode into a JSON array.');
}
