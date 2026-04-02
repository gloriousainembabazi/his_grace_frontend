// lib/models/expense.dart

class Expense {
  final int id;
  final String expenseNumber;
  final String category;
  final String description;
  final double amount;
  final DateTime expenseDate;
  final String paymentMethod;
  final String receiptNumber;
  final String vendorName;

  Expense({
    required this.id,
    required this.expenseNumber,
    required this.category,
    required this.description,
    required this.amount,
    required this.expenseDate,
    required this.paymentMethod,
    this.receiptNumber = '',
    this.vendorName = '',
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      expenseNumber: json['expense_number'],
      category: json['category'],
      description: json['description'],
      amount: double.parse(json['amount']?.toString() ?? '0'),
      expenseDate: DateTime.parse(json['expense_date']),
      paymentMethod: json['payment_method'],
      receiptNumber: json['receipt_number'] ?? '',
      vendorName: json['vendor_name'] ?? '',
    );
  }
}