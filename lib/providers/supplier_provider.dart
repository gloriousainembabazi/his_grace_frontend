// lib/providers/supplier_provider.dart

import 'package:flutter/material.dart';

class Supplier {
  final String id;
  final String name;
  final String contact;
  // Add more fields as needed

  Supplier({
    required this.id,
    required this.name,
    required this.contact,
  });
}

class SupplierProvider extends ChangeNotifier {
  // List of suppliers
  List<Supplier> _suppliers = [];

  // Getter
  List<Supplier> get suppliers => _suppliers;

  // Error handling
  String? error;

  // Fetch suppliers (dummy example, replace with API call)
  Future<void> fetchSuppliers() async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Example dummy data
      _suppliers = [
        Supplier(id: '1', name: 'Supplier A', contact: '0712345678'),
        Supplier(id: '2', name: 'Supplier B', contact: '0787654321'),
      ];

      error = null;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  // Add a supplier
  Future<void> addSupplier(Supplier supplier) async {
    try {
      _suppliers.add(supplier);
      error = null;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  // Find supplier by id
  Supplier? getSupplierById(String id) {
    try {
      return _suppliers.firstWhere((supplier) => supplier.id == id);
    } catch (e) {
      return null;
    }
  }
}