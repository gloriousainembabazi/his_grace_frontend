// lib/models/stock_take.dart

class StockTake {
  final int id;
  final String stockTakeNumber;
  final DateTime date;
  final String status;
  final String notes;
  final List<StockTakeItem> items;
  final double totalDiscrepancy;

  StockTake({
    required this.id,
    required this.stockTakeNumber,
    required this.date,
    required this.status,
    this.notes = '',
    this.items = const [],
    this.totalDiscrepancy = 0,
  });

  factory StockTake.fromJson(Map<String, dynamic> json) {
    return StockTake(
      id: json['id'],
      stockTakeNumber: json['stock_take_number'],
      date: DateTime.parse(json['date']),
      status: json['status'],
      notes: json['notes'] ?? '',
      items: (json['items'] as List?)
          ?.map((item) => StockTakeItem.fromJson(item))
          .toList() ?? [],
      totalDiscrepancy: double.parse(json['total_discrepancy']?.toString() ?? '0'),
    );
  }
}

class StockTakeItem {
  final int id;
  final int productId;
  final String productName;
  final int systemQuantity;
  final int actualQuantity;
  final int difference;
  final double discrepancyValue;
  final String notes;

  StockTakeItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.systemQuantity,
    required this.actualQuantity,
    required this.difference,
    required this.discrepancyValue,
    this.notes = '',
  });

  factory StockTakeItem.fromJson(Map<String, dynamic> json) {
    return StockTakeItem(
      id: json['id'],
      productId: json['product'],
      productName: json['product_name'],
      systemQuantity: json['system_quantity'],
      actualQuantity: json['actual_quantity'],
      difference: json['difference'],
      discrepancyValue: double.parse(json['discrepancy_value']?.toString() ?? '0'),
      notes: json['notes'] ?? '',
    );
  }
}