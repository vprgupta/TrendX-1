import 'package:flutter/material.dart';
import '../service/auth_service.dart';
import '../model/user.dart';

class AuthController extends ChangeNotifier {
  static final AuthController _instance = AuthController._internal();
  factory AuthController() => _instance;
  AuthController._internal();

  final AuthService _authService = AuthService();
  
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      final user = await _authService.login(email, password);
      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      } else {
        _setError('Invalid email or password');
        return false;
      }
    } catch (e) {
      _setError('Login failed. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      final user = await _authService.register(name, email, password);
      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      } else {
        _setError('Registration failed. Please check your details.');
        return false;
      }
    } catch (e) {
      _setError('Registration failed. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();
    
    try {
      final success = await _authService.resetPassword(email);
      if (!success) {
        _setError('Invalid email address');
      }
      return success;
    } catch (e) {
      _setError('Password reset failed. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Bypass login with dummy data for testing
  Future<bool> bypassLogin() async {
    _setLoading(true);
    _clearError();
    
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      
      _currentUser = User(
        id: 'demo-123',
        name: 'Demo User',
        email: 'demo@trendx.com',
        createdAt: DateTime.now(),
        isEmailVerified: true,
      );
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Bypass login failed.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    final user = await _authService.getCurrentUser();
    if (user != null) {
      _currentUser = user;
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }
}