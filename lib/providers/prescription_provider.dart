// lib/providers/prescription_provider.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/prescription.dart';

class PrescriptionProvider extends ChangeNotifier {
  final ApiService _apiService;
  List<Prescription> _prescriptions = [];
  bool _isLoading = false;
  String? _error;

  PrescriptionProvider(this._apiService);

  List<Prescription> get prescriptions => _prescriptions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPrescriptions({Map<String, dynamic>? params}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getPrescriptions(params: params);
      _prescriptions = (response.data as List)
          .map((json) => Prescription.fromJson(json))
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Prescription?> createPrescription(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.createPrescription(data);
      final prescription = Prescription.fromJson(response.data);
      _prescriptions.insert(0, prescription);
      return prescription;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> dispensePrescription(int id) async {
    try {
      await _apiService.dispensePrescription(id);
      await loadPrescriptions();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<void> deletePrescription(int id) async {
    try {
      await _apiService.deletePrescription(id);
      _prescriptions.removeWhere((prescription) => prescription.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }
}