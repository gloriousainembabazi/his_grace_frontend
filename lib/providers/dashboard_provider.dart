// lib/providers/dashboard_provider.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DashboardProvider extends ChangeNotifier {
  final ApiService _apiService;

  bool _isLoading = false;
  Map<String, dynamic>? _data;
  List<dynamic> _inventoryItems = [];
  List<dynamic> _lowStockItems = [];
  List<dynamic> _expiringItems = [];
  SalesChartData? _salesChartData;

  DashboardProvider(this._apiService);

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get data => _data;
  Map<String, dynamic> get dashboardData => _data ?? {};
  List<dynamic> get inventoryItems => _inventoryItems;
  List<dynamic> get lowStockItems => _lowStockItems;
  List<dynamic> get expiringItems => _expiringItems;
  SalesChartData? get salesChartData => _salesChartData;

  Future<void> loadDashboard() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.getDashboard();
      if (response.isSuccess && response.data != null) {
        _data = response.data;
      }

      await Future.wait([
        _loadInventoryItems(),
        _loadLowStockItems(),
        _loadExpiringItems(),
      ]);
    } catch (e) {
      print('Error loading dashboard: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSalesChart({String period = 'weekly'}) async {
    try {
      final response = await _apiService.get('/dashboard/sales-chart/?period=$period');
      
      if (response.isSuccess && response.data != null) {
        _salesChartData = SalesChartData.fromJson(response.data);
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching sales chart: $e');
    }
  }

  Future<void> _loadInventoryItems() async {
    try {
      final response = await _apiService.getMedicines();
      if (response.isSuccess && response.data != null) {
        _inventoryItems = response.data['results'] ?? response.data;
      }
    } catch (e) {
      print('Error loading inventory items: $e');
    }
  }

  Future<void> _loadLowStockItems() async {
    try {
      final response = await _apiService.get("/medicines/?low_stock=true");
      if (response.isSuccess && response.data != null) {
        _lowStockItems = response.data['results'] ?? response.data;
      }
    } catch (e) {
      print('Error loading low stock items: $e');
    }
  }

  Future<void> _loadExpiringItems() async {
    try {
      final response = await _apiService.get("/medicines/?expiring=true");
      if (response.isSuccess && response.data != null) {
        _expiringItems = response.data['results'] ?? response.data;
      }
    } catch (e) {
      print('Error loading expiring items: $e');
    }
  }

  int getTotalInventoryItems() => _inventoryItems.length;
  
  double getTotalInventoryValue() {
    double total = 0;
    for (var item in _inventoryItems) {
      final price = item['price'] is String
          ? double.tryParse(item['price']) ?? 0
          : (item['price'] ?? 0).toDouble();
      final quantity = (item['quantity'] ?? 0) as int;
      total += price * quantity;
    }
    return total;
  }

  int getLowStockCount() => _lowStockItems.length;
  int getExpiringCount() => _expiringItems.length;
  List<dynamic> getLowStockItemsList() => _lowStockItems;
  List<dynamic> getExpiringItemsList() => _expiringItems;

  Map<String, int> getInventoryByCategory() {
    final Map<String, int> categoryMap = {};
    for (var item in _inventoryItems) {
      final category = item['category_name'] ?? item['category']?.toString() ?? 'Uncategorized';
      categoryMap[category] = (categoryMap[category] ?? 0) + 1;
    }
    return categoryMap;
  }
}

// Sales Chart Data Model
class SalesChartData {
  final List<String> labels;
  final List<double> sales;
  final List<double> profits;
  final double averageSale;
  final double totalRevenue;
  
  SalesChartData({
    required this.labels,
    required this.sales,
    required this.profits,
    required this.averageSale,
    required this.totalRevenue,
  });
  
  factory SalesChartData.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] ?? {};
    return SalesChartData(
      labels: List<String>.from(rawData['labels'] ?? []),
      sales: List<double>.from(rawData['sales']?.map((e) => e.toDouble()) ?? []),
      profits: List<double>.from(rawData['profits']?.map((e) => e.toDouble()) ?? []),
      averageSale: (json['average_sale'] ?? 0).toDouble(),
      totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
    );
  }
}