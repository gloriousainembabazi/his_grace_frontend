// lib/providers/expense_provider.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';  // ← ADD THIS IMPORT
import '../services/api_service.dart';
import '../models/expense.dart';  // ← ADD THIS IMPORT

class ExpenseProvider extends ChangeNotifier {
  final ApiService _apiService;
  
  List<Expense> _expenses = [];  // ← CHANGE to use Expense model
  bool _isLoading = false;
  String? _error;
  
  ExpenseProvider(this._apiService);
  
  List<Expense> get expenses => _expenses;  // ← CHANGE return type
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // New property for dashboard
  double get totalExpenses {
    return _expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }
  
  Future<void> loadExpenses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.get("/expenses/");
      
      if (response.isSuccess && response.data != null) {
        final data = response.data['results'] ?? response.data;
        _expenses = (data as List)
            .map((item) => Expense.fromJson(item))
            .toList();
      } else {
        _error = response.error ?? 'Failed to load expenses';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> createExpense(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.createExpense(data);
      
      if (response.isSuccess) {
        await loadExpenses();
        return true;
      } else {
        _error = response.error ?? 'Failed to create expense';
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
  
  Future<bool> updateExpense(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.put("/expenses/$id/", data);
      
      if (response.isSuccess) {
        await loadExpenses();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> deleteExpense(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.delete("/expenses/$id/");
      
      if (response.isSuccess) {
        await loadExpenses();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Get monthly expenses summary
  Future<Map<String, double>> getMonthlyExpensesSummary(int year) async {
    final Map<String, double> monthlyExpenses = {};
    
    for (int month = 1; month <= 12; month++) {
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 0);
      
      try {
        final response = await _apiService.get(
          "/expenses/?start_date=${startDate.toIso8601String().split('T')[0]}&end_date=${endDate.toIso8601String().split('T')[0]}"
        );
        
        if (response.isSuccess && response.data != null) {
          final expenses = response.data['results'] ?? response.data;
          final total = (expenses as List).fold(0.0, (sum, item) => sum + _getAmountFromJson(item));
          monthlyExpenses[DateFormat('MMM').format(startDate)] = total;
        }
      } catch (e) {
        print('Error loading expenses for month $month: $e');
        monthlyExpenses[DateFormat('MMM').format(startDate)] = 0.0;
      }
    }
    
    return monthlyExpenses;
  }
  
  // Helper to extract amount from JSON
  double _getAmountFromJson(dynamic item) {
    if (item is Map) {
      final amount = item['amount'];
      if (amount is int) return amount.toDouble();
      if (amount is double) return amount;
      if (amount is String) return double.tryParse(amount) ?? 0;
    }
    return 0;
  }
  
  // Get expenses by category
  Map<String, double> getExpensesByCategory() {
    final Map<String, double> categoryMap = {};
    for (var expense in _expenses) {
      categoryMap[expense.category] = (categoryMap[expense.category] ?? 0) + expense.amount;
    }
    return categoryMap;
  }
  
  // Get recent expenses
  List<Expense> getRecentExpenses({int limit = 5}) {
    final sorted = List<Expense>.from(_expenses);
    sorted.sort((a, b) => b.expenseDate.compareTo(a.expenseDate));
    return sorted.take(limit).toList();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}