// lib/providers/expense_provider.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/expense.dart';

class ExpenseProvider extends ChangeNotifier {
  final ApiService _apiService;
  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _error;

  ExpenseProvider(this._apiService);

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadExpenses({Map<String, dynamic>? params}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getExpenses(params: params);
      print('Expenses loaded: ${response.data}'); // Debug log
      
      if (response.data is List) {
        _expenses = (response.data as List)
            .map((json) => Expense.fromJson(json))
            .toList();
      } else if (response.data is Map && response.data['results'] != null) {
        // If using pagination
        _expenses = (response.data['results'] as List)
            .map((json) => Expense.fromJson(json))
            .toList();
      }
      
      print('Loaded ${_expenses.length} expenses'); // Debug log
    } catch (e) {
      _error = e.toString();
      print('Error loading expenses: $e'); // Debug log
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Expense?> createExpense(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.createExpense(data);
      final expense = Expense.fromJson(response.data);
      _expenses.insert(0, expense);
      notifyListeners();
      return expense;
    } catch (e) {
      _error = e.toString();
      print('Error creating expense: $e'); // Debug log
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Expense?> updateExpense(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.updateExpense(id, data);
      final updatedExpense = Expense.fromJson(response.data);
      final index = _expenses.indexWhere((e) => e.id == id);
      if (index != -1) {
        _expenses[index] = updatedExpense;
        notifyListeners();
      }
      return updatedExpense;
    } catch (e) {
      _error = e.toString();
      print('Error updating expense: $e'); // Debug log
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteExpense(int id) async {
    try {
      await _apiService.deleteExpense(id);
      _expenses.removeWhere((expense) => expense.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      print('Error deleting expense: $e'); // Debug log
      return false;
    }
  }

  // ==================== HELPER METHODS ====================
  
  /// Get total expenses for all loaded expenses
  double getTotalExpenses() {
    return _expenses.fold(0, (sum, expense) => sum + expense.amount);
  }
  
  /// Get total expenses for a specific date range
  double getTotalExpensesByDateRange(DateTime startDate, DateTime endDate) {
    return _expenses
        .where((expense) => 
            expense.expenseDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
            expense.expenseDate.isBefore(endDate.add(const Duration(days: 1))))
        .fold(0, (sum, expense) => sum + expense.amount);
  }
  
  /// Get total expenses for today
  double getTodayTotalExpenses() {
    final today = DateTime.now();
    return getTotalExpensesByDateRange(today, today);
  }
  
  /// Get total expenses for current month
  double getCurrentMonthTotalExpenses() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    return getTotalExpensesByDateRange(startOfMonth, endOfMonth);
  }
  
  /// Get total expenses for current year
  double getCurrentYearTotalExpenses() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year, 12, 31);
    return getTotalExpensesByDateRange(startOfYear, endOfYear);
  }
  
  /// Get expenses grouped by category
  Map<String, double> getExpensesByCategory() {
    final Map<String, double> categoryTotals = {};
    for (var expense in _expenses) {
      categoryTotals[expense.category] = 
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }
    return categoryTotals;
  }
  
  /// Get expenses for a specific category
  List<Expense> getExpensesByCategoryFilter(String category) {
    if (category == 'all') return _expenses;
    return _expenses.where((expense) => expense.category == category).toList();
  }
  
  /// Get expenses for a specific date range
  List<Expense> getExpensesByDateRange(DateTime startDate, DateTime endDate) {
    return _expenses
        .where((expense) => 
            expense.expenseDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
            expense.expenseDate.isBefore(endDate.add(const Duration(days: 1))))
        .toList();
  }
  
  /// Get today's expenses
  List<Expense> getTodayExpenses() {
    final today = DateTime.now();
    return getExpensesByDateRange(today, today);
  }
  
  /// Get current month's expenses
  List<Expense> getCurrentMonthExpenses() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    return getExpensesByDateRange(startOfMonth, endOfMonth);
  }
  
  /// Get current year's expenses
  List<Expense> getCurrentYearExpenses() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year, 12, 31);
    return getExpensesByDateRange(startOfYear, endOfYear);
  }
  
  /// Get top expense categories by amount
  List<Map<String, dynamic>> getTopExpenseCategories({int limit = 5}) {
    final categoryTotals = getExpensesByCategory();
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedCategories.take(limit).map((entry) => {
      'category': entry.key,
      'amount': entry.value,
      'percentage': _expenses.isNotEmpty ? (entry.value / getTotalExpenses()) * 100 : 0,
    }).toList();
  }
  
  /// Get expense summary statistics
  Map<String, dynamic> getExpenseSummary() {
    final total = getTotalExpenses();
    final todayTotal = getTodayTotalExpenses();
    final monthTotal = getCurrentMonthTotalExpenses();
    final yearTotal = getCurrentYearTotalExpenses();
    final categoryCount = getExpensesByCategory().length;
    final averageExpense = _expenses.isNotEmpty ? total / _expenses.length : 0;
    final highestExpense = _expenses.isNotEmpty 
        ? _expenses.reduce((a, b) => a.amount > b.amount ? a : b)
        : null;
    
    return {
      'total': total,
      'today': todayTotal,
      'month': monthTotal,
      'year': yearTotal,
      'categoryCount': categoryCount,
      'totalTransactions': _expenses.length,
      'averageExpense': averageExpense,
      'highestExpense': highestExpense,
    };
  }
  
  /// Clear all expenses (useful for logout)
  void clearExpenses() {
    _expenses.clear();
    _error = null;
    notifyListeners();
  }
  
  /// Refresh expenses from API
  Future<void> refreshExpenses() async {
    await loadExpenses();
  }
  
  /// Check if there are any expenses
  bool get hasExpenses => _expenses.isNotEmpty;
  
  /// Get expense by ID
  Expense? getExpenseById(int id) {
    try {
      return _expenses.firstWhere((expense) => expense.id == id);
    } catch (e) {
      return null;
    }
  }
  
  /// Get latest expenses (most recent first)
  List<Expense> getLatestExpenses({int limit = 10}) {
    final sorted = List<Expense>.from(_expenses)
      ..sort((a, b) => b.expenseDate.compareTo(a.expenseDate));
    return sorted.take(limit).toList();
  }
  
  /// Get oldest expenses
  List<Expense> getOldestExpenses({int limit = 10}) {
    final sorted = List<Expense>.from(_expenses)
      ..sort((a, b) => a.expenseDate.compareTo(b.expenseDate));
    return sorted.take(limit).toList();
  }
  
  /// Get expenses by payment method
  Map<String, double> getExpensesByPaymentMethod() {
    final Map<String, double> methodTotals = {};
    for (var expense in _expenses) {
      methodTotals[expense.paymentMethod] = 
          (methodTotals[expense.paymentMethod] ?? 0) + expense.amount;
    }
    return methodTotals;
  }
  
  /// Get monthly expense trend for the last 12 months
  List<Map<String, dynamic>> getMonthlyExpenseTrend() {
    final now = DateTime.now();
    final monthlyTotals = <String, double>{};
    
    for (int i = 11; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      final monthName = '${_getMonthAbbreviation(date.month)} ${date.year}';
      
      final monthTotal = _expenses
          .where((expense) => 
              expense.expenseDate.year == date.year && 
              expense.expenseDate.month == date.month)
          .fold(0.0, (sum, expense) => sum + expense.amount);
      
      monthlyTotals[monthName] = monthTotal;
    }
    
    return monthlyTotals.entries.map((entry) => {
      'month': entry.key,
      'amount': entry.value,
    }).toList();
  }
  
  String _getMonthAbbreviation(int month) {
    const abbreviations = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return abbreviations[month - 1];
  }
}