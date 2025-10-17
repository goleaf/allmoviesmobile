import 'dart:convert';

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String password;
  final List<String> favorites;
  final List<String> watchlist;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.password,
    List<String>? favorites,
    List<String>? watchlist,
  })  : favorites = List.unmodifiable(favorites ?? const []),
        watchlist = List.unmodifiable(watchlist ?? const []);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'password': password,
      'favorites': favorites,
      'watchlist': watchlist,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      password: map['password'] ?? '',
      favorites: (map['favorites'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          const [],
      watchlist: (map['watchlist'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          const [],
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? password,
    List<String>? favorites,
    List<String>? watchlist,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      password: password ?? this.password,
      favorites: favorites ?? this.favorites,
      watchlist: watchlist ?? this.watchlist,
    );
  }
}

