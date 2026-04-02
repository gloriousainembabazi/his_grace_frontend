// lib/models/prescription.dart

class Prescription {
  final int id;
  final String prescriptionNumber;
  final String patientName;
  final String patientPhone;
  final String patientAddress;
  final String doctorName;
  final DateTime date;
  final String status;
  final String notes;
  final List<PrescriptionItem> items;
  final double totalAmount;

  Prescription({
    required this.id,
    required this.prescriptionNumber,
    required this.patientName,
    this.patientPhone = '',
    this.patientAddress = '',
    this.doctorName = '',
    required this.date,
    required this.status,
    this.notes = '',
    this.items = const [],
    this.totalAmount = 0,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'],
      prescriptionNumber: json['prescription_number'],
      patientName: json['patient_name'],
      patientPhone: json['patient_phone'] ?? '',
      patientAddress: json['patient_address'] ?? '',
      doctorName: json['doctor_name'] ?? '',
      date: DateTime.parse(json['date']),
      status: json['status'],
      notes: json['notes'] ?? '',
      items: (json['items'] as List?)
          ?.map((item) => PrescriptionItem.fromJson(item))
          .toList() ?? [],
      totalAmount: double.parse(json['total_amount']?.toString() ?? '0'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patient_name': patientName,
      'patient_phone': patientPhone,
      'patient_address': patientAddress,
      'doctor_name': doctorName,
      'date': date.toIso8601String().split('T')[0],
      'status': status,
      'notes': notes,
    };
  }
}

class PrescriptionItem {
  final int id;
  final int productId;
  final String productName;
  final int quantity;
  final String dosage;
  final String frequency;
  final String duration;
  final double unitPrice;
  final double totalPrice;

  PrescriptionItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.dosage,
    required this.frequency,
    required this.duration,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory PrescriptionItem.fromJson(Map<String, dynamic> json) {
    return PrescriptionItem(
      id: json['id'],
      productId: json['product'],
      productName: json['product_name'],
      quantity: json['quantity'],
      dosage: json['dosage'] ?? '',
      frequency: json['frequency'] ?? '',
      duration: json['duration'] ?? '',
      unitPrice: double.parse(json['unit_price']?.toString() ?? '0'),
      totalPrice: double.parse(json['total_price']?.toString() ?? '0'),
    );
  }
}