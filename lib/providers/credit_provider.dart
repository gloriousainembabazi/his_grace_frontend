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

  Future<void> loadCredits({Map<String, dynamic>? params}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getCredits(params: params);
      _credits = (response.data as List)
          .map((json) => Credit.fromJson(json))
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Credit?> createCredit(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.createCredit(data);
      final credit = Credit.fromJson(response.data);
      _credits.insert(0, credit);
      return credit;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addPayment(int creditId, Map<String, dynamic> paymentData) async {
    try {
      await _apiService.addCreditPayment(creditId, paymentData);
      await loadCredits();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }
}