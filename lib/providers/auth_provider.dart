// lib/providers/auth_provider.dart

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final StorageService _storageService;
  
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;
  User? _currentUser;

  AuthProvider(this._authService, this._storageService) {
    _checkAuthStatus();
  }

  // ================= GETTERS =================
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated; // ✅ getter (no conflict now)
  User? get currentUser => _currentUser;

  // ================= INITIAL CHECK =================
  Future<void> _checkAuthStatus() async {
    final token = await _storageService.getToken();

    if (token != null && token.isNotEmpty) {
      _isAuthenticated = true;

      final userData = await _storageService.getUser();
      if (userData != null) {
        _currentUser = User.fromJson(userData);
      }
    } else {
      _isAuthenticated = false;
    }

    notifyListeners();
  }

  // ================= FIXED METHOD =================
  /// Use this ONLY when you need async check (e.g SplashScreen)
  Future<bool> checkAuthentication() async {
    final token = await _storageService.getToken();
    return token != null && token.isNotEmpty;
  }

  // ================= LOGIN =================
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.login(username, password);
      
      if (response.isSuccess && response.user != null) {
        _currentUser = response.user;
        _isAuthenticated = true;
        return true;
      } else {
        _error = response.error ?? 'Login failed';
        return false;
      }
    } catch (e) {
      _error = 'Connection error: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ================= REGISTER =================
  Future<bool> register(Map<String, dynamic> userData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.register(userData);
      return response.isSuccess;
    } catch (e) {
      _error = 'Registration failed: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ================= PASSWORD =================
  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.forgotPassword(email);
      return response.isSuccess;
    } catch (e) {
      _error = 'Failed to send reset email';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.verifyOtp(email, otp);
      return response.isSuccess;
    } catch (e) {
      _error = 'Verification failed';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resendOtp(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      return await _authService.resendOtp(email);
    } catch (e) {
      _error = 'Failed to resend OTP';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resetPassword(String uid, String token, String newPassword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      return await _authService.resetPassword(uid, token, newPassword);
    } catch (e) {
      _error = 'Password reset failed';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resetPasswordWithOtp(String email, String otp, String newPassword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      return await _authService.resetPasswordWithOtp(email, otp, newPassword);
    } catch (e) {
      _error = 'Password reset failed';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ================= USERS =================
  Future<List<User>> getUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      return await _authService.getUsers();
    } catch (e) {
      _error = 'Failed to load users';
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createUser(Map<String, dynamic> userData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      return await _authService.createUser(userData);
    } catch (e) {
      _error = 'Failed to create user';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateUser(int userId, Map<String, dynamic> userData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      return await _authService.updateUser(userId, userData);
    } catch (e) {
      _error = 'Failed to update user';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteUser(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      return await _authService.deleteUser(userId);
    } catch (e) {
      _error = 'Failed to delete user';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    await _authService.logout();

    _isAuthenticated = false;
    _currentUser = null;

    _isLoading = false;
    notifyListeners();
  }

  // ================= CLEAR ERROR =================
  void clearError() {
    _error = null;
    notifyListeners();
  }
}