// lib/screens/stock/stock_take_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/stock_provider.dart';
import '../../models/stock_take.dart';
import '../../utils/constants.dart';

class StockTakeDetailScreen extends StatefulWidget {
  final int stockTakeId;

  const StockTakeDetailScreen({super.key, required this.stockTakeId});

  @override
  State<StockTakeDetailScreen> createState() => _StockTakeDetailScreenState();
}

class _StockTakeDetailScreenState extends State<StockTakeDetailScreen> {
  StockTake? _stockTake;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStockTake();
  }

  Future<void> _loadStockTake() async {
    final provider = Provider.of<StockProvider>(context, listen: false);
    await provider.loadStockTakes();
    setState(() {
      _stockTake = provider.stockTakes.firstWhere((s) => s.id == widget.stockTakeId);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Take Details'),
        actions: [
          if (_stockTake?.status == 'in_progress' || _stockTake?.status == 'draft')
            IconButton(
              icon: const Icon(Icons.check_circle),
              onPressed: _completeStockTake,
              tooltip: 'Complete',
            ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _printStockTake,
            tooltip: 'Print',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stockTake == null
              ? const Center(child: Text('Stock take not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _stockTake!.stockTakeNumber,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Date: ${_stockTake!.date.day}/${_stockTake!.date.month}/${_stockTake!.date.year}',
                                        style:
                                            const TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(_stockTake!.status),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _stockTake!.status.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Summary Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Summary',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Divider(),
                              _buildInfoRow(
                                'Total Items:',
                                '${_stockTake!.items.length}',
                              ),
                              _buildInfoRow(
                                'Total Discrepancy:',
                                'UGX ${_stockTake!.totalDiscrepancy.toStringAsFixed(0)}',
                                isBold: true,
                                color: _stockTake!.totalDiscrepancy > 0
                                    ? Colors.red
                                    : (_stockTake!.totalDiscrepancy < 0
                                        ? Colors.green
                                        : Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Stock Items
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Stock Items',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Divider(),
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _stockTake!.items.length,
                                separatorBuilder: (context, index) =>
                                    const Divider(),
                                itemBuilder: (context, index) {
                                  final item = _stockTake!.items[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.productName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                  'System: ${item.systemQuantity}'),
                                            ),
                                            Expanded(
                                              child: Text(
                                                  'Actual: ${item.actualQuantity}'),
                                            ),
                                            Expanded(
                                              child: Text(
                                                'Diff: ${item.difference}',
                                                style: TextStyle(
                                                  color: item.difference != 0
                                                      ? Colors.orange
                                                      : Colors.green,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          'Value: UGX ${item.discrepancyValue.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            color: item.discrepancyValue != 0
                                                ? Colors.orange
                                                : Colors.green,
                                          ),
                                        ),
                                        if (item.notes.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 4),
                                            child: Text(
                                              'Notes: ${item.notes}',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey),
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_stockTake!.notes.isNotEmpty)
                        const SizedBox(height: 16),
                      if (_stockTake!.notes.isNotEmpty)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Notes',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Divider(),
                                Text(_stockTake!.notes),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'draft':
        return Colors.grey;
      case 'in_progress':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _completeStockTake() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Stock Take'),
        content: const Text(
            'Are you sure you want to complete this stock take? This will update the actual stock quantities in the system.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
            ),
            child: const Text('Complete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final provider = Provider.of<StockProvider>(context, listen: false);
      final success = await provider.completeStockTake(widget.stockTakeId);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stock take completed successfully')),
        );
        _loadStockTake();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error ?? 'Failed to complete stock take')),
        );
      }
    }
  }

  void _printStockTake() {
    // TODO: Implement print functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Print feature coming soon')),
    );
  }
}