import 'package:flutter/material.dart';
import 'package:stats_analyzer/services/local_auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final LocalAuthService _authService = LocalAuthService();
  Map<String, dynamic>? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;

  AuthProvider() {
    _checkAuthStatus();
  }

  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String get userName => _user?['name'] ?? 'User';
  String get userEmail => _user?['email'] ?? '';

  Future<void> _checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();
    
    _isAuthenticated = await _authService.isAuthenticated();
    if (_isAuthenticated) {
      _user = await _authService.getCurrentUser();
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> register(String email, String password, {String? name}) async {
    _isLoading = true;
    notifyListeners();
    
    final success = await _authService.register(email, password, name: name);
    
    _isLoading = false;
    notifyListeners();
    
    if (success) {
      // Auto-login after registration
      await signIn(email, password);
    }
    
    return success;
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    
    final success = await _authService.signIn(email, password);
    
    if (success) {
      _user = await _authService.getCurrentUser();
      _isAuthenticated = true;
    }
    
    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    
    await _authService.signOut();
    _user = null;
    _isAuthenticated = false;
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateProfile(String name) async {
    await _authService.updateProfile(name);
    _user = await _authService.getCurrentUser();
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    await _authService.deleteAccount();
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  // Demo account for quick testing
  Future<void> signInAsDemo() async {
    const email = 'demo@diamondedge.com';
    const password = 'demo123';
    // Ensure user exists
    await _authService.register(email, password, name: 'Demo User');
    await signIn(email, password);
  }
}
