import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalAuthService {
  static const String _usersKey = 'registered_users';
  static const String _currentUserKey = 'current_user';
  static const String _sessionKey = 'session_active';

  Future<bool> register(String email, String password, {String? name}) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    Map<String, dynamic> users = {};
    if (usersJson != null) {
      users = jsonDecode(usersJson);
      if (users.containsKey(email)) {
        return false;
      }
    }
    final hashedPassword = base64Encode(utf8.encode(password));
    users[email] = {
      'email': email,
      'password': hashedPassword,
      'name': name ?? email.split('@').first,
      'createdAt': DateTime.now().toIso8601String(),
    };
    await prefs.setString(_usersKey, jsonEncode(users));
    return true;
  }

  Future<bool> signIn(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    if (usersJson == null) return false;
    final users = jsonDecode(usersJson);
    if (!users.containsKey(email)) return false;
    final userData = users[email];
    final hashedPassword = base64Encode(utf8.encode(password));
    if (userData['password'] != hashedPassword) return false;
    await prefs.setString(_currentUserKey, jsonEncode(userData));
    await prefs.setBool(_sessionKey, true);
    return true;
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
    await prefs.setBool(_sessionKey, false);
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_currentUserKey);
    if (userJson == null) return null;
    return jsonDecode(userJson);
  }

  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    final session = prefs.getBool(_sessionKey) ?? false;
    if (!session) return false;
    final user = await getCurrentUser();
    return user != null;
  }

  Future<void> updateProfile(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_currentUserKey);
    if (userJson == null) return;
    final user = jsonDecode(userJson);
    user['name'] = name;
    await prefs.setString(_currentUserKey, jsonEncode(user));
    final usersJson = prefs.getString(_usersKey);
    if (usersJson != null) {
      final users = jsonDecode(usersJson);
      final email = user['email'];
      users[email]['name'] = name;
      await prefs.setString(_usersKey, jsonEncode(users));
    }
  }

  Future<void> deleteAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_currentUserKey);
    if (userJson == null) return;
    final user = jsonDecode(userJson);
    final email = user['email'];
    final usersJson = prefs.getString(_usersKey);
    if (usersJson != null) {
      final users = jsonDecode(usersJson);
      users.remove(email);
      await prefs.setString(_usersKey, jsonEncode(users));
    }
    await prefs.remove(_currentUserKey);
    await prefs.setBool(_sessionKey, false);
  }
}
