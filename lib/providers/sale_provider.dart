// lib/providers/sale_provider.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/sale.dart';

class SaleProvider extends ChangeNotifier {
  final ApiService _apiService;
  
  List<Sale> _sales = [];
  List<Sale> _dailySales = [];
  bool _isLoading = false;
  String? _error;
  
  SaleProvider(this._apiService);
  
  List<Sale> get sales => _sales;
  List<Sale> get dailySales => _dailySales;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Daily total getter for reports
  double get dailyTotal {
    return _dailySales.fold(0.0, (sum, sale) => sum + sale.totalPrice);
  }
  
  // Calculate total revenue from all sales
  double get totalRevenue {
    return _sales.fold(0.0, (sum, sale) => sum + sale.totalPrice);
  }
  
  // Calculate today's revenue
  double get todayRevenue {
    final today = DateTime.now();
    final todaySales = _sales.where((sale) => 
      sale.saleDate.year == today.year &&
      sale.saleDate.month == today.month &&
      sale.saleDate.day == today.day
    );
    return todaySales.fold(0.0, (sum, sale) => sum + sale.totalPrice);
  }
  
  // Calculate yesterday's revenue
  double get yesterdayRevenue {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdaySales = _sales.where((sale) => 
      sale.saleDate.year == yesterday.year &&
      sale.saleDate.month == yesterday.month &&
      sale.saleDate.day == yesterday.day
    );
    return yesterdaySales.fold(0.0, (sum, sale) => sum + sale.totalPrice);
  }
  
  // Calculate total quantity sold
  int get totalQuantity {
    return _sales.fold(0, (sum, sale) => sum + sale.quantity);
  }
  
  // Get total number of sales transactions
  int get totalTransactions {
    return _sales.length;
  }
  
  Future<void> loadSales({bool refresh = false}) async {
    if (refresh) {
      _sales = [];
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.get("/sales/");
      
      if (response.isSuccess && response.data != null) {
        final data = response.data['results'] ?? response.data;
        _sales = (data as List)
            .map((item) => Sale.fromJson(item))
            .toList();
      } else {
        _error = response.error ?? 'Failed to load sales';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> loadDailySales() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.get("/sales/daily/");
      
      if (response.isSuccess && response.data != null) {
        final data = response.data;
        final salesData = data['sales'] ?? data;
        _dailySales = (salesData as List)
            .map((item) => Sale.fromJson(item))
            .toList();
      } else {
        _error = response.error ?? 'Failed to load daily sales';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<Sale?> getSaleById(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.get("/sales/$id/");
      
      if (response.isSuccess && response.data != null) {
        return Sale.fromJson(response.data);
      } else {
        _error = response.error ?? 'Failed to load sale';
        return null;
      }
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> createSale(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.createSale(data);
      
      if (response.isSuccess) {
        await loadDailySales();
        await loadSales(refresh: true);
        return true;
      } else {
        _error = response.error ?? 'Failed to create sale';
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
  
  Future<List<Sale>> getSalesByDateRange(DateTime startDate, DateTime endDate) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.getSalesReport(
        startDate: startDate.toIso8601String().split('T')[0],
        endDate: endDate.toIso8601String().split('T')[0],
      );
      
      if (response.isSuccess && response.data != null) {
        final sales = response.data['results'] ?? response.data;
        _isLoading = false;
        notifyListeners();
        return (sales as List)
            .map((item) => Sale.fromJson(item))
            .toList();
      } else {
        _error = response.error ?? 'Failed to get sales by date range';
        _isLoading = false;
        notifyListeners();
        return [];
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }
  
  // Get sales grouped by month
  Map<String, List<Sale>> getSalesByMonth() {
    final Map<String, List<Sale>> groupedSales = {};
    
    for (var sale in _sales) {
      final monthKey = '${sale.saleDate.year}-${sale.saleDate.month}';
      if (!groupedSales.containsKey(monthKey)) {
        groupedSales[monthKey] = [];
      }
      groupedSales[monthKey]!.add(sale);
    }
    
    return groupedSales;
  }
  
  // Get monthly revenue for chart
  Map<String, double> getMonthlyRevenue() {
    final Map<String, double> monthlyRevenue = {};
    
    for (var sale in _sales) {
      final monthKey = '${sale.saleDate.year}-${sale.saleDate.month}';
      monthlyRevenue[monthKey] = (monthlyRevenue[monthKey] ?? 0) + sale.totalPrice;
    }
    
    return monthlyRevenue;
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}