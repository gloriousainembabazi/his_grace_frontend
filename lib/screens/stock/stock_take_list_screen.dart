// lib/screens/stock/stock_take_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/stock_provider.dart';
import '../../utils/constants.dart';

class StockTakeListScreen extends StatefulWidget {
  const StockTakeListScreen({super.key});

  @override
  State<StockTakeListScreen> createState() => _StockTakeListScreenState();
}

class _StockTakeListScreenState extends State<StockTakeListScreen> {
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadStockTakes();
  }

  Future<void> _loadStockTakes() async {
    await Provider.of<StockProvider>(context, listen: false).loadStockTakes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Takes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/create-stock-take');
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStockTakes,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Draft', 'draft'),
                  const SizedBox(width: 8),
                  _buildFilterChip('In Progress', 'in_progress'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Completed', 'completed'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Cancelled', 'cancelled'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Consumer<StockProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(provider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadStockTakes,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          var stockTakes = provider.stockTakes;

          // Apply status filter
          if (_statusFilter != 'all') {
            stockTakes = stockTakes
                .where((stock) => stock.status == _statusFilter)
                .toList();
          }

          if (stockTakes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inventory_outlined,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No stock takes found'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/create-stock-take');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('New Stock Take'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: stockTakes.length,
            itemBuilder: (context, index) {
              final stockTake = stockTakes[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(stockTake.status),
                    child: const Icon(Icons.inventory, color: Colors.white),
                  ),
                  title: Text(stockTake.stockTakeNumber),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date: ${stockTake.date.day}/${stockTake.date.month}/${stockTake.date.year}'),
                      if (stockTake.totalDiscrepancy != 0)
                        Text(
                          'Discrepancy: UGX ${stockTake.totalDiscrepancy.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: stockTake.totalDiscrepancy > 0
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(stockTake.status),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          stockTake.status.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      Text(
                        '${stockTake.items.length} items',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/stock-take-detail',
                      arguments: {'id': stockTake.id},
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return FilterChip(
      label: Text(label),
      selected: _statusFilter == value,
      onSelected: (selected) {
        setState(() {
          _statusFilter = value;
        });
      },
      backgroundColor: Colors.grey[200],
      selectedColor: AppColors.primaryGreen,
      labelStyle: TextStyle(
        color: _statusFilter == value ? Colors.white : Colors.black,
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
}