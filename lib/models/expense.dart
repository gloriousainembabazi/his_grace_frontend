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
      id: json['id'] ?? 0,
      expenseNumber: json['expense_number'] ?? json['expenseNumber'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      expenseDate: json['expense_date'] != null 
          ? DateTime.parse(json['expense_date']) 
          : (json['expenseDate'] != null 
              ? DateTime.parse(json['expenseDate']) 
              : DateTime.now()),
      paymentMethod: json['payment_method'] ?? json['paymentMethod'] ?? 'cash',
      receiptNumber: json['receipt_number'] ?? json['receiptNumber'] ?? '',
      vendorName: json['vendor_name'] ?? json['vendorName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expense_number': expenseNumber,
      'category': category,
      'description': description,
      'amount': amount,
      'expense_date': expenseDate.toIso8601String().split('T')[0],
      'payment_method': paymentMethod,
      'receipt_number': receiptNumber,
      'vendor_name': vendorName,
    };
  }
  
  String get formattedDate {
    return '${expenseDate.day}/${expenseDate.month}/${expenseDate.year}';
  }
  
  String get formattedAmount {
    return 'UGX ${amount.toStringAsFixed(0)}';
  }
}