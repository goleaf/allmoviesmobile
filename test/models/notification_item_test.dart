import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/data/models/notification_item.dart';

import '../test_support/fixture_reader.dart';

void main() {
  group('AppNotification', () {
    test('parses notification fixture', () async {
      final list = await loadJsonListFixture('notifications.json');
      final notification = AppNotification.fromJson(
        list.first as Map<String, dynamic>,
      );
      expect(notification.category, NotificationCategory.social);
      expect(notification.metadata['listId'], 'abc123');
      expect(notification.toJson()['category'], 'social');
      expect(notification.copyWith(isRead: true).isRead, isTrue);
    });
  });
}
