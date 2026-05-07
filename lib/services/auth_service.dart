// lib/services/auth_service.dart

import '../models/user.dart';
import '../models/auth_response.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  final ApiService _apiService;
  final StorageService _storageService;

  AuthService(this._apiService, this._storageService);

  // ================= LOGIN =================
  Future<AuthResponse> login(String username, String password) async {
    try {
      final response = await _apiService.login(username, password);

      if (!response.isSuccess) {
        return AuthResponse(error: response.error ?? 'Login failed');
      }

      final data = response.data;

      if (data == null) {
        return AuthResponse(error: 'Invalid server response');
      }

      final token = data['token'] ?? data['access'] ?? data['key'];

      if (token == null || token.toString().isEmpty) {
        return AuthResponse(error: 'Authentication token not provided');
      }

      final userJson = data['user'] ?? data;

      if (userJson == null || userJson is! Map<String, dynamic>) {
        return AuthResponse(error: 'Invalid user data');
      }

      final user = User.fromJson(userJson);

      await _storageService.saveToken(token.toString());
      await _storageService.saveUser(user.toJson());

      return AuthResponse(
        user: user,
        token: token.toString(),
      );
    } catch (e) {
      return AuthResponse(error: 'Connection error. Please try again.');
    }
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    try {
      await _apiService.logout();
    } catch (_) {}
    await _storageService.clearAll();
  }

  // ================= REGISTER =================
  Future<AuthResponse> register(Map<String, dynamic> userData) async {
    try {
      final response = await _apiService.register(userData);

      if (response.isSuccess) {
        return AuthResponse(message: 'Registration successful');
      }

      return AuthResponse(
        error: response.error ?? 'Registration failed',
      );
    } catch (e) {
      return AuthResponse(error: 'Connection error. Please try again.');
    }
  }

  // ================= OTP =================
  Future<AuthResponse> verifyOtp(String email, String otp) async {
    try {
      final response = await _apiService.verifyOtp(email, otp);

      if (response.isSuccess) {
        return AuthResponse(message: 'OTP verified successfully');
      }

      return AuthResponse(error: response.error ?? 'Invalid OTP');
    } catch (e) {
      return AuthResponse(error: 'Verification failed. Try again.');
    }
  }

  Future<bool> resendOtp(String email) async {
    try {
      final response = await _apiService.resendOtp(email);
      return response.isSuccess;
    } catch (_) {
      return false;
    }
  }

  // ================= PASSWORD =================
  Future<AuthResponse> forgotPassword(String email) async {
    try {
      final response = await _apiService.forgotPassword(email);

      if (response.isSuccess) {
        return AuthResponse(message: 'Password reset email sent');
      }

      return AuthResponse(
        error: response.error ?? 'Failed to send reset email',
      );
    } catch (e) {
      return AuthResponse(error: 'Connection error. Try again.');
    }
  }

  Future<bool> resetPassword(String uid, String token, String password) async {
    try {
      final response = await _apiService.resetPassword(uid, token, password);
      return response.isSuccess;
    } catch (_) {
      return false;
    }
  }

  Future<bool> resetPasswordWithOtp(String email, String otp, String password) async {
    try {
      final response = await _apiService.resetPasswordWithOtp(email, otp, password);
      return response.isSuccess;
    } catch (_) {
      return false;
    }
  }

  // ================= USERS (STAFF) =================
  Future<List<User>> getUsers() async {
    try {
      final res = await _apiService.getUsers();

      if (res.isSuccess && res.data is List) {
        return (res.data as List)
            .map((e) => User.fromJson(e))
            .toList();
      }

      return [];
    } catch (_) {
      return [];
    }
  }

  Future<bool> createUser(Map<String, dynamic> data) async {
    try {
      final res = await _apiService.createUser(data);
      return res.isSuccess;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateUser(int userId, Map<String, dynamic> data) async {
    try {
      final res = await _apiService.updateUser(userId, data);
      return res.isSuccess;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteUser(int userId) async {
    try {
      final res = await _apiService.deleteUser(userId);
      return res.isSuccess;
    } catch (_) {
      return false;
    }
  }

  // ================= LOCAL =================
  Future<User?> getCurrentUser() async {
    try {
      final data = await _storageService.getUser();
      if (data == null) return null;
      return User.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<bool> isAuthenticated() async {
    try {
      final token = await _storageService.getToken();
      return token != null && token.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}