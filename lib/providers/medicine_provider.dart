// lib/providers/medicine_provider.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/medicine.dart';

class MedicineProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<Medicine> _medicines = [];
  List<Medicine> _lowStockMedicines = [];
  List<Medicine> _expiringMedicines = [];
  List<Medicine> _expiredMedicines = [];
  List<dynamic> _suppliers = [];
  List<dynamic> _categories = [];
  bool _isLoading = false;
  String? _error;

  MedicineProvider(this._apiService);

  List<Medicine> get medicines => _medicines;
  List<Medicine> get lowStockMedicines => _lowStockMedicines;
  List<Medicine> get expiringMedicines => _expiringMedicines;
  List<Medicine> get expiredMedicines => _expiredMedicines;
  List<dynamic> get suppliers => _suppliers;
  List<dynamic> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMedicines({bool refresh = false}) async {
    if (refresh) {
      _medicines = [];
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getMedicines();

      if (response.isSuccess && response.data != null) {
        final data = response.data['results'] ?? response.data;
        final List<Medicine> newMedicines = [];

        for (var item in data) {
          newMedicines.add(Medicine.fromJson(item));
        }

        _medicines = newMedicines;
      } else {
        _error = response.error ?? 'Failed to load medicines';
      }
    } catch (e) {
      _error = e.toString();
      print('Error loading medicines: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadLowStockMedicines() async {
    try {
      final response = await _apiService.get("/medicines/?low_stock=true");

      if (response.isSuccess && response.data != null) {
        final data = response.data['results'] ?? response.data;
        _lowStockMedicines =
            (data as List).map((item) => Medicine.fromJson(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error loading low stock medicines: $e');
    }
  }

  Future<void> loadExpiringMedicines() async {
    try {
      final response = await _apiService.get("/medicines/?expiring=true");

      if (response.isSuccess && response.data != null) {
        final data = response.data['results'] ?? response.data;
        _expiringMedicines =
            (data as List).map((item) => Medicine.fromJson(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error loading expiring medicines: $e');
    }
  }

  Future<void> loadExpiredMedicines() async {
    try {
      final response = await _apiService.get("/medicines/?expired=true");

      if (response.isSuccess && response.data != null) {
        final data = response.data['results'] ?? response.data;
        _expiredMedicines =
            (data as List).map((item) => Medicine.fromJson(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error loading expired medicines: $e');
    }
  }

  Future<void> loadSuppliers() async {
    try {
      final response = await _apiService.get("/suppliers/");

      if (response.isSuccess && response.data != null) {
        _suppliers = response.data['results'] ?? response.data;
        notifyListeners();
      }
    } catch (e) {
      print('Error loading suppliers: $e');
    }
  }

  Future<void> loadCategories() async {
    try {
      final response = await _apiService.getCategories();

      if (response.isSuccess && response.data != null) {
        _categories = response.data['results'] ?? response.data;
        notifyListeners();
      }
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  Future<Medicine?> getMedicineById(int id) async {
    try {
      final response = await _apiService.get("/medicines/$id/");

      if (response.isSuccess && response.data != null) {
        return Medicine.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error getting medicine: $e');
      return null;
    }
  }

  Future<bool> createMedicine(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.createMedicine(data);

      if (response.isSuccess) {
        await loadMedicines(refresh: true);
        await loadLowStockMedicines();
        await loadExpiringMedicines();
        await loadExpiredMedicines();
        return true;
      } else {
        _error = response.error ?? 'Failed to create medicine';
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

  /// Alias for [createMedicine] — used by AddMedicineScreen.
  Future<bool> addMedicine(Map<String, dynamic> data) => createMedicine(data);

  Future<bool> updateMedicine(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.updateMedicine(id, data);

      if (response.isSuccess) {
        await loadMedicines(refresh: true);
        await loadLowStockMedicines();
        await loadExpiringMedicines();
        await loadExpiredMedicines();
        return true;
      } else {
        _error = response.error ?? 'Failed to update medicine';
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

  Future<bool> deleteMedicine(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.deleteMedicine(id);

      if (response.isSuccess) {
        await loadMedicines(refresh: true);
        await loadLowStockMedicines();
        await loadExpiringMedicines();
        await loadExpiredMedicines();
        return true;
      } else {
        _error = response.error ?? 'Failed to delete medicine';
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

  void clearError() {
    _error = null;
    notifyListeners();
  }
}