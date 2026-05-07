// lib/services/storage_service.dart

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/constants.dart';

class StorageService {
  final FlutterSecureStorage _storage;

  StorageService(this._storage);

  // Token methods
  Future<void> saveToken(String token) async {
    await _storage.write(key: AppConstants.tokenKey, value: token);
    print('💾 Token saved successfully');
  }

  Future<String?> getToken() async {
    final token = await _storage.read(key: AppConstants.tokenKey);
    print('🔑 Token retrieved: ${token != null ? 'Yes' : 'No'}');
    return token;
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: AppConstants.tokenKey);
    print('🗑️ Token deleted');
  }

  // User methods
  Future<void> saveUser(Map<String, dynamic> user) async {
    await _storage.write(key: AppConstants.userKey, value: json.encode(user));
    print('👤 User saved: ${user['username']}');
  }

  Future<Map<String, dynamic>?> getUser() async {
    final userString = await _storage.read(key: AppConstants.userKey);
    if (userString != null) {
      print('👤 User retrieved');
      return json.decode(userString);
    }
    print('👤 No user found');
    return null;
  }

  Future<void> deleteUser() async {
    await _storage.delete(key: AppConstants.userKey);
    print('🗑️ User deleted');
  }

  // Theme methods
  Future<void> saveThemeMode(String themeMode) async {
    await _storage.write(key: AppConstants.themeKey, value: themeMode);
    print('🎨 Theme saved: $themeMode');
  }

  Future<String?> getThemeMode() async {
    return await _storage.read(key: AppConstants.themeKey);
  }

  // Clear all
  Future<void> clearAll() async {
    await _storage.deleteAll();
    print('🗑️ All storage cleared');
  }
}