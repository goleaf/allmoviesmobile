import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/models/user_model.dart';
import '../data/services/local_storage_service.dart';

class AuthProvider with ChangeNotifier {
  final LocalStorageService _storageService;
  UserModel? _currentUser;
  bool _isLoading = false;

  AuthProvider(this._storageService) {
    _loadCurrentUser();
  }

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;

  void _loadCurrentUser() {
    _currentUser = _storageService.getCurrentUser();
    notifyListeners();
  }

  Future<AuthResult> login(String email, String password) async {
    _setLoading(true);
    
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate delay
    
    final user = _storageService.validateLogin(email, password);
    
    if (user != null) {
      await _storageService.saveCurrentUser(user);
      _currentUser = user;
      _setLoading(false);
      return AuthResult.success();
    }
    
    _setLoading(false);
    return AuthResult.failure('Invalid email or password');
  }

  Future<AuthResult> register(String email, String password, String fullName) async {
    _setLoading(true);
    
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate delay
    
    if (_storageService.emailExists(email)) {
      _setLoading(false);
      return AuthResult.failure('Email already registered');
    }
    
    final user = UserModel(
      id: const Uuid().v4(),
      email: email,
      password: password,
      fullName: fullName,
    );
    
    final success = await _storageService.registerUser(user);
    
    if (success) {
      await _storageService.saveCurrentUser(user);
      _currentUser = user;
      _setLoading(false);
      return AuthResult.success();
    }
    
    _setLoading(false);
    return AuthResult.failure('Registration failed');
  }

  Future<AuthResult> forgotPassword(String email) async {
    _setLoading(true);
    
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate delay
    
    if (!_storageService.emailExists(email)) {
      _setLoading(false);
      return AuthResult.failure('Email not found');
    }
    
    // Generate a new random password
    final newPassword = _generatePassword();
    
    final success = await _storageService.updateUserPassword(email, newPassword);
    
    if (success) {
      _setLoading(false);
      return AuthResult.success(message: newPassword);
    }
    
    _setLoading(false);
    return AuthResult.failure('Password reset failed');
  }

  Future<void> logout() async {
    await _storageService.clearCurrentUser();
    _currentUser = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _generatePassword() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*';
    final random = DateTime.now().millisecondsSinceEpoch;
    String password = '';
    
    for (int i = 0; i < 10; i++) {
      final index = (random + i * 7) % chars.length;
      password += chars[index];
    }
    
    return password;
  }
}

class AuthResult {
  final bool isSuccess;
  final String? message;

  AuthResult.success({this.message}) : isSuccess = true;
  AuthResult.failure(this.message) : isSuccess = false;
}

