import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CategoryProvider extends ChangeNotifier {
  final ApiService _apiService;
  
  List<dynamic> _categories = [];
  bool _isLoading = false;
  String? _error;
  
  CategoryProvider(this._apiService);
  
  List<dynamic> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.getCategories();
      
      if (response.isSuccess && response.data != null) {
        _categories = response.data['results'] ?? response.data;
      } else {
        _error = response.error ?? 'Failed to load categories';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}