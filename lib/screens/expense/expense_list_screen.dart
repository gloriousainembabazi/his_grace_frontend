// lib/screens/expense/expense_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';
import '../../utils/constants.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  String _searchQuery = '';
  String _categoryFilter = 'all';
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    await Provider.of<ExpenseProvider>(context, listen: false).loadExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/create-expense');
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadExpenses,
          ),
        ],
      ),
      body: Consumer<ExpenseProvider>(
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
                    onPressed: _loadExpenses,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          var expenses = provider.expenses;

          // Apply search filter
          if (_searchQuery.isNotEmpty) {
            expenses = expenses.where((expense) =>
                expense.expenseNumber
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ||
                expense.description
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ||
                expense.vendorName
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase())).toList();
          }

          // Apply category filter
          if (_categoryFilter != 'all') {
            expenses = expenses
                .where((expense) => expense.category == _categoryFilter)
                .toList();
          }

          // Apply date range filter
          if (_dateRange != null) {
            expenses = expenses.where((expense) =>
                expense.expenseDate.isAfter(_dateRange!.start) &&
                expense.expenseDate.isBefore(_dateRange!.end
                    .add(const Duration(days: 1)))).toList();
          }

          if (expenses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.money_off_outlined,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No expenses found'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/create-expense');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('New Expense'),
                  ),
                ],
              ),
            );
          }

          // Calculate total
          final total = expenses.fold<double>(
              0, (sum, expense) => sum + expense.amount);

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search expenses...',
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
              ),
              // Total Card
              Card(
                margin: const EdgeInsets.all(8),
                color: AppColors.primaryGreen,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Expenses:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'UGX ${total.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Expense List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    return Card(
                      margin:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getCategoryColor(expense.category),
                          child: Icon(
                            _getCategoryIcon(expense.category),
                            color: Colors.white,
                          ),
                        ),
                        title: Text(expense.expenseNumber),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(expense.description),
                            Text(
                              'UGX ${expense.amount.toStringAsFixed(0)} | ${expense.category}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${expense.expenseDate.day}/${expense.expenseDate.month}/${expense.expenseDate.year}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            if (expense.vendorName.isNotEmpty)
                              Text(
                                expense.vendorName,
                                style: const TextStyle(fontSize: 10),
                              ),
                          ],
                        ),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/expense-detail',
                            arguments: {'id': expense.id},
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Expenses'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _categoryFilter,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(value: 'all', child: Text('All')),
                ...AppConstants.expenseCategories
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    ,
              ],
              onChanged: (value) {
                setState(() {
                  _categoryFilter = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Date Range'),
              subtitle: _dateRange == null
                  ? const Text('Select range')
                  : Text(
                      '${_dateRange!.start.day}/${_dateRange!.start.month}/${_dateRange!.start.year} - ${_dateRange!.end.day}/${_dateRange!.end.month}/${_dateRange!.end.year}'),
              trailing: const Icon(Icons.date_range),
              onTap: () async {
                final range = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  initialDateRange: _dateRange,
                );
                if (range != null) {
                  setState(() {
                    _dateRange = range;
                  });
                }
              },
            ),
            if (_dateRange != null)
              TextButton(
                onPressed: () {
                  setState(() {
                    _dateRange = null;
                  });
                  Navigator.pop(context);
                },
                child: const Text('Clear Filter'),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'rent':
        return Colors.blue;
      case 'utilities':
        return Colors.green;
      case 'salary':
        return Colors.orange;
      case 'maintenance':
        return Colors.purple;
      case 'supplies':
        return Colors.teal;
      case 'transport':
        return Colors.brown;
      case 'marketing':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'rent':
        return Icons.home;
      case 'utilities':
        return Icons.lightbulb;
      case 'salary':
        return Icons.people;
      case 'maintenance':
        return Icons.build;
      case 'supplies':
        return Icons.inventory;
      case 'transport':
        return Icons.directions_car;
      case 'marketing':
        return Icons.campaign;
      default:
        return Icons.money;
    }
  }
}