// lib/providers/stock_provider.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/stock_take.dart';

class StockProvider extends ChangeNotifier {
  final ApiService _apiService;
  List<StockTake> _stockTakes = [];
  bool _isLoading = false;
  String? _error;

  StockProvider(this._apiService);

  List<StockTake> get stockTakes => _stockTakes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadStockTakes({Map<String, dynamic>? params}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getStockTakes(params: params);
      _stockTakes = (response.data as List)
          .map((json) => StockTake.fromJson(json))
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<StockTake?> createStockTake(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.createStockTake(data);
      final stockTake = StockTake.fromJson(response.data);
      _stockTakes.insert(0, stockTake);
      return stockTake;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> completeStockTake(int id) async {
    try {
      await _apiService.completeStockTake(id);
      await loadStockTakes();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }
}