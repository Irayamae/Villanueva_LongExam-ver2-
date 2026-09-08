// lib/providers/auth_provider.dart

import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/user_service.dart';

class AuthProvider extends ChangeNotifier {
  final UserService _userService = UserService();

  User? _user;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;

  User? get user => _user;

  bool get isLoggedIn => _user != null;

  bool get isLoading => _isLoading;

  bool get isInitialized => _isInitialized;

  String? get error => _error;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final savedUser = await _userService.getSavedUser();
      final token = await _userService.getSavedToken();

      if (savedUser != null && token != null && token.isNotEmpty) {
        try {
          final currentUser =
              await _userService.getCurrentUser(token);

          _user = currentUser.copyWith(
            token: token,
          );

          await _userService.saveSession(_user!);
        } catch (_) {
          // If the API cannot be reached, keep the saved session.
          _user = savedUser;
        }
      } else {
        _user = null;
      }
    } catch (e) {
      _error = e.toString();
      _user = null;
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _userService.login(
        username: username,
        password: password,
      );

      return true;
    } catch (e) {
      _error = e.toString().replaceFirst(
            'Exception: ',
            '',
          );

      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _userService.clearSession();

    _user = null;
    _error = null;

    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}