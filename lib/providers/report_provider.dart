// lib/providers/report_provider.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ReportProvider extends ChangeNotifier {
  final ApiService _apiService;

  Map<String, dynamic> _dashboardSummary = {};
  Map<String, dynamic> _inventoryReport = {};
  Map<String, dynamic> _staffReport = {};
  Map<String, dynamic> _dailySalesReport = {};
  Map<String, dynamic> _salesReport = {};      // ← new
  Map<String, dynamic> _lowStockReport = {};
  Map<String, dynamic> _expiredReport = {};
  bool _isLoading = false;
  String? _error;

  ReportProvider(this._apiService);

  Map<String, dynamic> get dashboardSummary => _dashboardSummary;
  Map<String, dynamic> get inventoryReport => _inventoryReport;
  Map<String, dynamic> get staffReport => _staffReport;
  Map<String, dynamic> get dailySalesReport => _dailySalesReport;
  Map<String, dynamic> get salesReport => _salesReport;          // ← new
  Map<String, dynamic> get lowStockReport => _lowStockReport;
  Map<String, dynamic> get expiredReport => _expiredReport;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ── Dashboard summary ─────────────────────────────────────────────────────

  Future<void> loadDashboardSummary() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getDashboard();

      if (response.isSuccess && response.data != null) {
        _dashboardSummary = response.data;
      } else {
        _error = response.error ?? 'Failed to load dashboard summary';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Sales report ──────────────────────────────────────────────────────────

  /// Loads a sales report filtered by [startDate] / [endDate] (yyyy-MM-dd).
  /// Results are stored in [salesReport].
  Future<void> loadSalesReport({
    String? startDate,
    String? endDate,
    String? groupBy, // 'day' | 'week' | 'month'
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Build query string from optional params.
      final params = <String>[];
      if (startDate != null) params.add('start_date=$startDate');
      if (endDate != null) params.add('end_date=$endDate');
      if (groupBy != null) params.add('group_by=$groupBy');
      final query = params.isNotEmpty ? '?${params.join('&')}' : '';

      final response = await _apiService.get("/sales/report/$query");

      if (response.isSuccess && response.data != null) {
        _salesReport = response.data is Map<String, dynamic>
            ? response.data
            : {'results': response.data};
      } else {
        // Fallback: try the daily-sales endpoint so the screen still renders.
        final fallback = await _apiService.get("/sales/daily/$query");
        if (fallback.isSuccess && fallback.data != null) {
          _salesReport = fallback.data is Map<String, dynamic>
              ? fallback.data
              : {'results': fallback.data};
        } else {
          _error = response.error ?? 'Failed to load sales report';
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Daily sales (kept for backward-compat) ────────────────────────────────

  Future<void> loadDailySalesReport() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get("/sales/daily/");

      if (response.isSuccess && response.data != null) {
        _dailySalesReport = response.data;
      } else {
        _error = response.error ?? 'Failed to load daily sales report';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Inventory ─────────────────────────────────────────────────────────────

  Future<void> loadInventoryReport() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getMedicines();

      if (response.isSuccess && response.data != null) {
        _inventoryReport = {
          'medicines': response.data['results'] ?? response.data,
          'total':
              response.data['count'] ?? (response.data as List).length,
        };
      } else {
        _error = response.error ?? 'Failed to load inventory report';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Staff ─────────────────────────────────────────────────────────────────

  Future<void> loadStaffReport() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get("/auth/users/");

      if (response.isSuccess && response.data != null) {
        _staffReport = {
          'users': response.data['results'] ?? response.data,
          'total':
              response.data['count'] ?? (response.data as List).length,
        };
      } else {
        _error = response.error ?? 'Failed to load staff report';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Low stock ─────────────────────────────────────────────────────────────

  Future<void> loadLowStockReport() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get("/medicines/?low_stock=true");

      if (response.isSuccess && response.data != null) {
        _lowStockReport = {
          'medicines': response.data['results'] ?? response.data,
          'count':
              response.data['count'] ?? (response.data as List).length,
        };
      } else {
        _error = response.error ?? 'Failed to load low stock report';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Expired ───────────────────────────────────────────────────────────────

  Future<void> loadExpiredReport() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get("/medicines/?expired=true");

      if (response.isSuccess && response.data != null) {
        _expiredReport = {
          'medicines': response.data['results'] ?? response.data,
          'count':
              response.data['count'] ?? (response.data as List).length,
        };
      } else {
        _error = response.error ?? 'Failed to load expired report';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}