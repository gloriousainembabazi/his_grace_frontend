// lib/screens/credit/credit_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/credit_provider.dart';
import '../../utils/constants.dart';

class CreditListScreen extends StatefulWidget {
  const CreditListScreen({super.key});

  @override
  State<CreditListScreen> createState() => _CreditListScreenState();
}

class _CreditListScreenState extends State<CreditListScreen> {
  String _searchQuery = '';
  String _typeFilter = 'all';
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadCredits();
  }

  Future<void> _loadCredits() async {
    await Provider.of<CreditProvider>(context, listen: false).loadCredits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/create-credit');
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCredits,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by number or name',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All Types', 'all'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Customer', 'customer'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Supplier', 'supplier'),
                      const SizedBox(width: 16),
                      _buildFilterChip('All Status', 'all_status'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Pending', 'pending'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Partial', 'partial'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Paid', 'paid'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Overdue', 'overdue'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Consumer<CreditProvider>(
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
                    onPressed: _loadCredits,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          var credits = provider.credits;

          // Apply search filter
          if (_searchQuery.isNotEmpty) {
            credits = credits.where((credit) =>
                credit.creditNumber
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ||
                (credit.customerName.isNotEmpty &&
                    credit.customerName
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase())) ||
                (credit.supplierName.isNotEmpty &&
                    credit.supplierName
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()))).toList();
          }

          // Apply type filter
          if (_typeFilter != 'all') {
            credits = credits
                .where((credit) => credit.creditType == _typeFilter)
                .toList();
          }

          // Apply status filter
          if (_statusFilter != 'all_status') {
            credits = credits
                .where((credit) => credit.status == _statusFilter)
                .toList();
          }

          if (credits.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.credit_card_outlined,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No credits found'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/create-credit');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('New Credit'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: credits.length,
            itemBuilder: (context, index) {
              final credit = credits[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getTypeColor(credit.creditType),
                    child: Icon(
                      credit.creditType == 'customer'
                          ? Icons.person
                          : Icons.business,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(credit.creditNumber),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(credit.creditType == 'customer'
                          ? credit.customerName
                          : credit.supplierName),
                      Text(
                        'Amount: UGX ${credit.amount.toStringAsFixed(0)} | Balance: UGX ${credit.balance.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 12),
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
                          color: _getStatusColor(credit.status),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          credit.status.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      Text(
                        'Due: ${credit.dueDate.day}/${credit.dueDate.month}/${credit.dueDate.year}',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/credit-detail',
                      arguments: {'id': credit.id},
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
    bool isSelected = false;
    if (value == 'all' || value == 'all_status') {
      isSelected = _typeFilter == value || _statusFilter == value;
    } else if (value == 'customer' || value == 'supplier') {
      isSelected = _typeFilter == value;
    } else {
      isSelected = _statusFilter == value;
    }

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (value == 'all' || value == 'customer' || value == 'supplier') {
            _typeFilter = value;
          } else {
            _statusFilter = value;
          }
        });
      },
      backgroundColor: Colors.grey[200],
      selectedColor: AppColors.primaryGreen,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
      ),
    );
  }

  Color _getTypeColor(String type) {
    return type == 'customer' ? Colors.blue : Colors.orange;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'partial':
        return Colors.purple;
      case 'paid':
        return Colors.green;
      case 'overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}