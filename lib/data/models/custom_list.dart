import 'package:flutter/foundation.dart';

import 'saved_media_item.dart';

@immutable
class CustomList {
  const CustomList({
    required this.id,
    required this.name,
    this.description,
    this.accentColor,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.items = const <SavedMediaItem>[],
    this.isPublic = false,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? createdAt ?? DateTime.now();

  factory CustomList.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems
            .whereType<Map<String, dynamic>>()
            .map(SavedMediaItem.fromJson)
            .toList(growable: false)
        : const <SavedMediaItem>[];

    return CustomList(
      id: json['id']?.toString() ?? '',
      name: (json['name'] as String?)?.trim() ?? '',
      description: (json['description'] as String?)?.trim(),
      accentColor: json['accent_color'] as String?,
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
      items: items,
      isPublic: json['is_public'] as bool? ?? false,
    );
  }

  final String id;
  final String name;
  final String? description;
  final String? accentColor;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<SavedMediaItem> items;
  final bool isPublic;

  int get itemCount => items.length;

  CustomList copyWith({
    String? name,
    String? description,
    String? accentColor,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<SavedMediaItem>? items,
    bool? isPublic,
  }) {
    return CustomList(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      accentColor: accentColor ?? this.accentColor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
      isPublic: isPublic ?? this.isPublic,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'accent_color': accentColor,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_public': isPublic,
      'items': items.map((item) => item.toJson()).toList(growable: false),
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
