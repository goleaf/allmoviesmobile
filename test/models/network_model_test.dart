import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/data/models/network_model.dart';

import '../test_support/fixture_reader.dart';

void main() {
  group('Network', () {
    test('parses from tv fixture', () async {
      final tv = await loadJsonFixture('tv_full.json');
      final networks = (tv['networks'] as List).cast<Map<String, dynamic>>();
      final network = Network.fromJson(networks.first);
      expect(network.id, 49);
      expect(network.toJson(), equals(networks.first));
      expect(network, equals(Network.fromJson(networks.first)));
      expect(network.copyWith(name: 'HBO Max').name, 'HBO Max');
    });
  });
}
