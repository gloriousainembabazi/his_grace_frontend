import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SupplierProvider extends ChangeNotifier {
  final ApiService _apiService;
  
  List<dynamic> _suppliers = [];
  bool _isLoading = false;
  String? _error;
  
  SupplierProvider(this._apiService);
  
  List<dynamic> get suppliers => _suppliers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> loadSuppliers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.get("/suppliers/");
      
      if (response.isSuccess && response.data != null) {
        _suppliers = response.data['results'] ?? response.data;
      } else {
        _error = response.error ?? 'Failed to load suppliers';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}