import 'package:flutter/material.dart';
import '../services/api_service.dart';

class StockProvider extends ChangeNotifier {
  final ApiService _apiService;
  
  List<dynamic> _stockTakes = [];
  bool _isLoading = false;
  String? _error;
  
  StockProvider(this._apiService);
  
  List<dynamic> get stockTakes => _stockTakes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> loadStockTakes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.get("/stock-takes/");
      
      if (response.isSuccess && response.data != null) {
        _stockTakes = response.data['results'] ?? response.data;
      } else {
        _error = response.error ?? 'Failed to load stock takes';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> createStockTake(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.post("/stock-takes/", data);
      
      if (response.isSuccess) {
        await loadStockTakes();
        return true;
      } else {
        _error = response.error ?? 'Failed to create stock take';
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
  
  Future<bool> completeStockTake(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.post("/stock-takes/$id/complete/", {});
      
      if (response.isSuccess) {
        await loadStockTakes();
        return true;
      } else {
        _error = response.error ?? 'Failed to complete stock take';
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
}