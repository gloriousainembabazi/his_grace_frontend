// lib/models/credit.dart

class Credit {
  final int id;
  final String creditNumber;
  final String creditType;
  final String customerName;
  final String supplierName;
  final double amount;
  final double paidAmount;
  final DateTime dueDate;
  final String invoiceNumber;
  final String notes;
  final String status;
  final List<CreditPayment> payments;
  final double balance;

  Credit({
    required this.id,
    required this.creditNumber,
    required this.creditType,
    this.customerName = '',
    this.supplierName = '',
    required this.amount,
    required this.paidAmount,
    required this.dueDate,
    this.invoiceNumber = '',
    this.notes = '',
    required this.status,
    this.payments = const [],
    this.balance = 0,
  });

  factory Credit.fromJson(Map<String, dynamic> json) {
    return Credit(
      id: json['id'],
      creditNumber: json['credit_number'],
      creditType: json['credit_type'],
      customerName: json['customer_name'] ?? '',
      supplierName: json['supplier_name'] ?? '',
      amount: double.parse(json['amount']?.toString() ?? '0'),
      paidAmount: double.parse(json['paid_amount']?.toString() ?? '0'),
      dueDate: DateTime.parse(json['due_date']),
      invoiceNumber: json['invoice_number'] ?? '',
      notes: json['notes'] ?? '',
      status: json['status'],
      payments: (json['payments'] as List?)
          ?.map((payment) => CreditPayment.fromJson(payment))
          .toList() ?? [],
      balance: double.parse(json['balance']?.toString() ?? '0'),
    );
  }
}

class CreditPayment {
  final int id;
  final double amount;
  final DateTime paymentDate;
  final String paymentMethod;
  final String referenceNumber;
  final String notes;

  CreditPayment({
    required this.id,
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
    this.referenceNumber = '',
    this.notes = '',
  });

  factory CreditPayment.fromJson(Map<String, dynamic> json) {
    return CreditPayment(
      id: json['id'],
      amount: double.parse(json['amount']?.toString() ?? '0'),
      paymentDate: DateTime.parse(json['payment_date']),
      paymentMethod: json['payment_method'],
      referenceNumber: json['reference_number'] ?? '',
      notes: json['notes'] ?? '',
    );
  }
}