import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class LocalStorageService {
  static const String _usersKey = 'allmovies_users';
  static const String _currentUserKey = 'allmovies_current_user';

  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  // Get all registered users
  List<UserModel> getUsers() {
    final String? usersJson = _prefs.getString(_usersKey);
    if (usersJson == null || usersJson.isEmpty) return [];

    final List<dynamic> usersList = json.decode(usersJson);
    return usersList.map((json) => UserModel.fromMap(json)).toList();
  }

  // Save all users
  Future<bool> saveUsers(List<UserModel> users) async {
    final usersJson = json.encode(users.map((u) => u.toMap()).toList());
    return await _prefs.setString(_usersKey, usersJson);
  }

  // Get current logged-in user
  UserModel? getCurrentUser() {
    final String? userJson = _prefs.getString(_currentUserKey);
    if (userJson == null || userJson.isEmpty) return null;
    return UserModel.fromJson(userJson);
  }

  // Save current user
  Future<bool> saveCurrentUser(UserModel user) async {
    return await _prefs.setString(_currentUserKey, user.toJson());
  }

  // Clear current user (logout)
  Future<bool> clearCurrentUser() async {
    return await _prefs.remove(_currentUserKey);
  }

  // Register a new user
  Future<bool> registerUser(UserModel user) async {
    final users = getUsers();
    
    // Check if email already exists
    if (users.any((u) => u.email.toLowerCase() == user.email.toLowerCase())) {
      return false;
    }
    
    users.add(user);
    return await saveUsers(users);
  }

  // Update user password
  Future<bool> updateUserPassword(String email, String newPassword) async {
    final users = getUsers();
    final index = users.indexWhere(
      (u) => u.email.toLowerCase() == email.toLowerCase(),
    );
    
    if (index == -1) return false;
    
    users[index] = users[index].copyWith(password: newPassword);
    return await saveUsers(users);
  }

  // Validate login credentials
  UserModel? validateLogin(String email, String password) {
    final users = getUsers();
    try {
      return users.firstWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase() && 
               u.password == password,
      );
    } catch (e) {
      return null;
    }
  }

  // Check if email exists
  bool emailExists(String email) {
    final users = getUsers();
    return users.any((u) => u.email.toLowerCase() == email.toLowerCase());
  }

  // Get user by email
  UserModel? getUserByEmail(String email) {
    final users = getUsers();
    try {
      return users.firstWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
}

