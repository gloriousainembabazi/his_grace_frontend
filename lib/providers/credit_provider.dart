// lib/providers/credit_provider.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/credit.dart';

class CreditProvider extends ChangeNotifier {
  final ApiService _apiService;
  
  List<Credit> _credits = [];
  bool _isLoading = false;
  String? _error;
  
  CreditProvider(this._apiService);
  
  List<Credit> get credits => _credits;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> loadCredits() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.getCredits();
      
      if (response.isSuccess && response.data != null) {
        final data = response.data['results'] ?? response.data;
        final List<Credit> newCredits = [];
        
        for (var item in data) {
          newCredits.add(Credit.fromJson(item));
        }
        
        _credits = newCredits;
      } else {
        _error = response.error ?? 'Failed to load credits';
      }
    } catch (e) {
      _error = e.toString();
      print('Error loading credits: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> createCredit(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.createCredit(data);
      
      if (response.isSuccess) {
        await loadCredits();
        return true;
      } else {
        _error = response.error ?? 'Failed to create credit';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> addPayment(int creditId, Map<String, dynamic> paymentData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.addCreditPayment(creditId, paymentData);
      
      if (response.isSuccess) {
        await loadCredits();
        return true;
      } else {
        _error = response.error ?? 'Failed to add payment';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}