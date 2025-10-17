import 'package:flutter/foundation.dart';

enum NotificationCategory {
  system,
  social,
  list,
  recommendation,
}

@immutable
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    this.category = NotificationCategory.system,
    this.actionRoute,
    this.metadata = const <String, dynamic>{},
    DateTime? createdAt,
    this.isRead = false,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString() ?? '',
      title: (json['title'] as String?) ?? '',
      message: (json['message'] as String?) ?? '',
      category: NotificationCategory.values.firstWhere(
        (value) => value.name == json['category'],
        orElse: () => NotificationCategory.system,
      ),
      actionRoute: json['action_route'] as String?,
      metadata: (json['metadata'] as Map?)?.cast<String, dynamic>() ??
          const <String, dynamic>{},
      createdAt: _parseDate(json['created_at']),
      isRead: json['is_read'] as bool? ?? false,
    );
  }

  final String id;
  final String title;
  final String message;
  final NotificationCategory category;
  final String? actionRoute;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final bool isRead;

  AppNotification copyWith({
    String? title,
    String? message,
    NotificationCategory? category,
    String? actionRoute,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return AppNotification(
      id: id,
      title: title ?? this.title,
      message: message ?? this.message,
      category: category ?? this.category,
      actionRoute: actionRoute ?? this.actionRoute,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'category': category.name,
      'action_route': actionRoute,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
    };
  }
}

DateTime? _parseDate(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is DateTime) {
    return value;
  }
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}
