// lib/providers/prescription_provider.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/prescription_model.dart';

class PrescriptionProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<Prescription> _prescriptions = [];
  Prescription? _currentPrescription;
  Map<String, dynamic> _stats = {};
  bool _isLoading = false;
  String? _error;

  PrescriptionProvider(this._apiService);

  List<Prescription> get prescriptions => _prescriptions;
  Prescription? get currentPrescription => _currentPrescription;
  Map<String, dynamic> get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPrescriptions({bool refresh = false}) async {
    if (refresh) {
      _prescriptions = [];
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get("/prescriptions/");

      if (response.isSuccess && response.data != null) {
        final data = response.data['results'] ?? response.data;
        _prescriptions = (data as List)
            .map((item) => Prescription.fromJson(item))
            .toList();
      } else {
        _error = response.error ?? 'Failed to load prescriptions';
      }
    } catch (e) {
      _error = e.toString();
      print('Error loading prescriptions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Prescription?> getPrescription(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get("/prescriptions/$id/");

      if (response.isSuccess && response.data != null) {
        _currentPrescription = Prescription.fromJson(response.data);
        return _currentPrescription;
      }
      _error = response.error ?? 'Prescription not found';
      return null;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPrescription(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.post("/prescriptions/", data);

      if (response.isSuccess) {
        await loadPrescriptions(refresh: true);
        return true;
      }
      _error = response.error ?? 'Failed to create prescription';
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updatePrescription(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.put("/prescriptions/$id/", data);

      if (response.isSuccess) {
        await loadPrescriptions(refresh: true);
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

  Future<bool> dispensePrescription(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.post("/prescriptions/$id/dispense/", {});

      if (response.isSuccess) {
        await loadPrescriptions(refresh: true);
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

  Future<bool> cancelPrescription(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.post("/prescriptions/$id/cancel/", {});

      if (response.isSuccess) {
        await loadPrescriptions(refresh: true);
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

  Future<bool> deletePrescription(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.delete("/prescriptions/$id/");

      if (response.isSuccess) {
        await loadPrescriptions(refresh: true);
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

  Future<dynamic> uploadPrescriptionImage({
    required String filePath,
    required String patientName,
    required String date,
    String? patientPhone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.uploadFile(
        '/prescriptions/upload/',
        filePath: filePath,
        fields: {
          'patient_name': patientName,
          'date': date,
          'source': 'upload',
          'status': 'pending',
          if (patientPhone != null && patientPhone.isNotEmpty)
            'patient_phone': patientPhone,
        },
        fileField: 'prescription_image',
      );

      if (response.isSuccess) {
        await loadPrescriptions(refresh: true);
        return response.data;
      }
      _error = response.error ?? 'Failed to upload prescription';
      return null;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPrescriptionStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get("/prescriptions/stats/");

      if (response.isSuccess && response.data != null) {
        _stats = response.data;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Prescription> filterPrescriptions({String? status, String? query}) {
    return _prescriptions.where((p) {
      if (status != null && status != 'all' && p.status != status) {
        return false;
      }
      if (query != null && query.isNotEmpty) {
        final q = query.toLowerCase();
        return p.prescriptionNumber.toLowerCase().contains(q) ||
               p.patientName.toLowerCase().contains(q) ||
               p.doctorName.toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}