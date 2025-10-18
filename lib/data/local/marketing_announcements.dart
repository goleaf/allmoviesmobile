import 'package:flutter/foundation.dart';

@immutable
class MarketingAnnouncement {
  const MarketingAnnouncement({
    required this.id,
    required this.title,
    required this.message,
    required this.startDate,
    this.endDate,
    this.actionRoute,
    this.metadata = const <String, dynamic>{},
  });

  final String id;
  final String title;
  final String message;
  final DateTime startDate;
  final DateTime? endDate;
  final String? actionRoute;
  final Map<String, dynamic> metadata;

  bool isActiveOn(DateTime day) {
    if (day.isBefore(startDate)) {
      return false;
    }
    if (endDate != null && day.isAfter(endDate!)) {
      return false;
    }
    return true;
  }
}

const List<MarketingAnnouncement> marketingAnnouncements = [
  MarketingAnnouncement(
    id: 'summer_spotlight',
    title: 'Summer Spotlight',
    message: 'Explore curated streaming picks for warm summer nights.',
    startDate: DateTime.utc(2024, 6, 1),
    endDate: DateTime.utc(2024, 8, 31),
    actionRoute: '/collections/summer-spotlight',
    metadata: <String, dynamic>{'campaign': 'seasonal'},
  ),
  MarketingAnnouncement(
    id: 'awards_watch',
    title: 'Awards Season Watchlist',
    message: 'Catch up on award contenders ahead of the big night.',
    startDate: DateTime.utc(2024, 1, 1),
    endDate: DateTime.utc(2024, 3, 31),
    actionRoute: '/collections/awards-watch',
    metadata: <String, dynamic>{'campaign': 'awards'},
  ),
];
