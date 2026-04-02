
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';
import '../../models/expense.dart';

class ExpenseDetailScreen extends StatefulWidget {
  final int expenseId;

  const ExpenseDetailScreen({super.key, required this.expenseId});

  @override
  State<ExpenseDetailScreen> createState() => _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends State<ExpenseDetailScreen> {
  Expense? _expense;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExpense();
  }

  Future<void> _loadExpense() async {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    await provider.loadExpenses();

    setState(() {
      _expense =
          provider.expenses.firstWhere((e) => e.id == widget.expenseId);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _printExpense,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteExpense,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _expense == null
              ? const Center(child: Text('Expense not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(
                                _expense!.expenseNumber,
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                  'UGX ${_expense!.amount.toStringAsFixed(0)}'),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildRow('Description',
                                  _expense!.description),
                              _buildRow('Category',
                                  _expense!.category),
                              _buildRow('Payment',
                                  _expense!.paymentMethod),
                              _buildRow('Vendor',
                                  _expense!.vendorName),
                              _buildRow('Receipt',
                                  _expense!.receiptNumber),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildRow(String title, String value) {
    if (value.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text('$title: ',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _printExpense() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Print coming soon')),
    );
  }

  Future<void> _deleteExpense() async {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    await provider.deleteExpense(widget.expenseId);

    if (mounted) {
      Navigator.pop(context);
    }
  }
}