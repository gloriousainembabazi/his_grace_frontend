// lib/models/prescription_model.dart
// Single canonical file. Delete lib/models/prescription.dart if it exists.
// Every import in providers and screens must point here:
//   import '../models/prescription_model.dart';  (from screens/prescription/)
//   import '../../models/prescription_model.dart'; (from screens/prescription/)

import 'package:flutter/material.dart';

class PrescriptionItem {
  final int id;
  final int? product;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String dosage;
  final String frequency;
  final String duration;
  final int dispensedQuantity;

  PrescriptionItem({
    required this.id,
    this.product,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.dosage,
    required this.frequency,
    required this.duration,
    this.dispensedQuantity = 0,
  });

  factory PrescriptionItem.fromJson(Map<String, dynamic> json) {
    return PrescriptionItem(
      id: json['id'] ?? 0,
      product: json['product'],
      productName: json['product_name'] ?? '',
      quantity: json['quantity'] ?? 1,
      unitPrice: _toDouble(json['unit_price']),
      totalPrice: _toDouble(json['total_price']),
      dosage: json['dosage'] ?? '',
      frequency: json['frequency'] ?? '',
      duration: json['duration'] ?? '',
      dispensedQuantity: json['dispensed_quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        if (product != null) 'product': product,
        'product_name': productName,
        'quantity': quantity,
        'unit_price': unitPrice,
        'dosage': dosage,
        'frequency': frequency,
        'duration': duration,
      };

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
}

class Prescription {
  final int id;
  final String prescriptionNumber;
  final String patientName;
  final String patientPhone;
  final String patientAddress;
  final String doctorName;
  final DateTime date;
  final String notes;
  final String status;
  final String source;
  final String? prescriptionImage;
  final double totalAmount;
  final List<PrescriptionItem> items;
  final String? createdByName;
  final String? dispensedByName;
  final DateTime? dispensedAt;
  final DateTime createdAt;

  Prescription({
    required this.id,
    required this.prescriptionNumber,
    required this.patientName,
    required this.patientPhone,
    required this.patientAddress,
    required this.doctorName,
    required this.date,
    required this.notes,
    required this.status,
    required this.source,
    this.prescriptionImage,
    required this.totalAmount,
    required this.items,
    this.createdByName,
    this.dispensedByName,
    this.dispensedAt,
    required this.createdAt,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'] ?? 0,
      prescriptionNumber: json['prescription_number'] ?? '',
      patientName: json['patient_name'] ?? '',
      patientPhone: json['patient_phone'] ?? '',
      patientAddress: json['patient_address'] ?? '',
      doctorName: json['doctor_name'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      notes: json['notes'] ?? '',
      status: json['status'] ?? 'pending',
      source: json['source'] ?? 'manual',
      prescriptionImage: json['prescription_image'],
      totalAmount: _toDouble(json['total_amount']),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((i) => PrescriptionItem.fromJson(
              i as Map<String, dynamic>))
          .toList(),
      createdByName: json['created_by_name'],
      dispensedByName: json['dispensed_by_name'],
      dispensedAt: json['dispensed_at'] != null
          ? DateTime.tryParse(json['dispensed_at'])
          : null,
      createdAt:
          DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Color get statusColor {
    switch (status) {
      case 'dispensed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'partial':
        return Colors.purple;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
}