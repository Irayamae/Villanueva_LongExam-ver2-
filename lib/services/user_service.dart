// lib/services/user_service.dart

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/user.dart';

class UserService {
  static const String _userKey = 'logged_in_user';
  static const String _tokenKey = 'access_token';

  static const String _appUsername = 'fitzvillanueva';
  static const String _appPassword = 'fitz123';

  static const String _apiUsername = 'emilys';
  static const String _apiPassword = 'emilyspass';

  Future<User> login({
    required String username,
    required String password,
  }) async {
    final isCustomLogin =
        username == _appUsername &&
        password == _appPassword;

    final loginUsername =
        isCustomLogin ? _apiUsername : username;

    final loginPassword =
        isCustomLogin ? _apiPassword : password;

    final response = await http
        .post(
          Uri.parse(authLoginEndpoint),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'username': loginUsername,
            'password': loginPassword,
            'expiresInMins': 30,
          }),
        )
        .timeout(apiTimeout);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final data =
          jsonDecode(response.body)
              as Map<String, dynamic>;

      final user = User.fromJson(data);

      await saveSession(user);

      return user;
    }

    String message = 'Login failed.';

    try {
      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic>) {
        message =
            data['message']?.toString() ?? message;
      }
    } catch (_) {}

    throw Exception(message);
  }

  Future<User> getCurrentUser(String token) async {
    final response = await http
        .get(
          Uri.parse(authMeEndpoint),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(apiTimeout);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final data =
          jsonDecode(response.body)
              as Map<String, dynamic>;

      return User.fromJson(
        {
          ...data,
          'accessToken': token,
        },
      );
    }

    throw Exception(
      'Failed to retrieve current user: '
      '${response.statusCode}',
    );
  }

  Future<void> saveSession(User user) async {
    final preferences =
        await SharedPreferences.getInstance();

    await preferences.setString(
      _userKey,
      jsonEncode(user.toJson()),
    );

    await preferences.setString(
      _tokenKey,
      user.token,
    );
  }

  Future<User?> getSavedUser() async {
    final preferences =
        await SharedPreferences.getInstance();

    final savedUser =
        preferences.getString(_userKey);

    if (savedUser == null ||
        savedUser.isEmpty) {
      return null;
    }

    try {
      final data =
          jsonDecode(savedUser)
              as Map<String, dynamic>;

      return User.fromJson(data);
    } catch (_) {
      await clearSession();
      return null;
    }
  }

  Future<String?> getSavedToken() async {
    final preferences =
        await SharedPreferences.getInstance();

    return preferences.getString(_tokenKey);
  }

  Future<void> clearSession() async {
    final preferences =
        await SharedPreferences.getInstance();

    await preferences.remove(_userKey);
    await preferences.remove(_tokenKey);
  }
}