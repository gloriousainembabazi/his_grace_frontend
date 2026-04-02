// lib/screens/credit/credit_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/credit_provider.dart';
import '../../models/credit.dart';
import '../../utils/constants.dart';

class CreditDetailScreen extends StatefulWidget {
  final int creditId;

  const CreditDetailScreen({super.key, required this.creditId});

  @override
  State<CreditDetailScreen> createState() => _CreditDetailScreenState();
}

class _CreditDetailScreenState extends State<CreditDetailScreen> {
  Credit? _credit;
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadCredit();
  }

  Future<void> _loadCredit() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<CreditProvider>(context, listen: false);
      await provider.loadCredits();
      
      setState(() {
        _credit = provider.credits.firstWhere((c) => c.id == widget.creditId);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading credit: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Details'),
        actions: [
          if (_credit?.status != 'paid')
            IconButton(
              icon: const Icon(Icons.payment),
              onPressed: _showAddPaymentDialog,
              tooltip: 'Add Payment',
            ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _printCredit,
            tooltip: 'Print',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareCredit,
            tooltip: 'Share',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_credit == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text('Credit not found'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCredit,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            _buildHeaderCard(),
            const SizedBox(height: 16),

            // Party Information
            _buildPartyInfoCard(),
            const SizedBox(height: 16),

            // Financial Details
            _buildFinancialDetailsCard(),
            const SizedBox(height: 16),

            // Payment History
            if (_credit!.payments.isNotEmpty) _buildPaymentHistoryCard(),
            if (_credit!.payments.isNotEmpty) const SizedBox(height: 16),

            // Notes
            if (_credit!.notes.isNotEmpty) _buildNotesCard(),
            if (_credit!.notes.isNotEmpty) const SizedBox(height: 16),

            // Action Buttons (for pending credits)
            if (_credit!.status != 'paid' && _credit!.status != 'overdue')
              _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _credit!.creditNumber,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Created: ${_formatDate(_credit!.dueDate)}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(_credit!.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _credit!.status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(
                  'Total Amount',
                  'UGX ${_credit!.amount.toStringAsFixed(0)}',
                  Icons.attach_money,
                  Colors.blue,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey[300],
                ),
                _buildStatItem(
                  'Paid',
                  'UGX ${_credit!.paidAmount.toStringAsFixed(0)}',
                  Icons.check_circle,
                  Colors.green,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey[300],
                ),
                _buildStatItem(
                  'Balance',
                  'UGX ${_credit!.balance.toStringAsFixed(0)}',
                  Icons.account_balance_wallet,
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPartyInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _credit!.creditType == 'customer'
                      ? Icons.person
                      : Icons.business,
                  color: _getTypeColor(_credit!.creditType),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  _credit!.creditType == 'customer'
                      ? 'Customer Information'
                      : 'Supplier Information',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            _buildInfoRow(
              'Name:',
              _credit!.creditType == 'customer'
                  ? _credit!.customerName
                  : _credit!.supplierName,
            ),
            if (_credit!.invoiceNumber.isNotEmpty)
              _buildInfoRow('Invoice Number:', _credit!.invoiceNumber),
            _buildInfoRow(
              'Due Date:',
              '${_credit!.dueDate.day}/${_credit!.dueDate.month}/${_credit!.dueDate.year}',
              isBold: _credit!.status == 'overdue',
              color: _credit!.status == 'overdue' ? Colors.red : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialDetailsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.trending_up, color: AppColors.primaryGreen, size: 24),
                SizedBox(width: 8),
                Text(
                  'Financial Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildSummaryRow(
                    'Total Amount',
                    'UGX ${_credit!.amount.toStringAsFixed(0)}',
                    Colors.blue,
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    'Paid Amount',
                    'UGX ${_credit!.paidAmount.toStringAsFixed(0)}',
                    Colors.green,
                  ),
                  const SizedBox(height: 8),
                  Divider(color: Colors.grey[300]),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    'Outstanding Balance',
                    'UGX ${_credit!.balance.toStringAsFixed(0)}',
                    _credit!.balance > 0 ? Colors.orange : Colors.green,
                    isBold: true,
                  ),
                ],
              ),
            ),
            if (_credit!.status == 'overdue')
              const SizedBox(height: 12),
            if (_credit!.status == 'overdue')
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This credit is overdue. Please collect payment immediately.',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color color,
      {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 18 : 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentHistoryCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.history, color: AppColors.primaryGreen, size: 24),
                SizedBox(width: 8),
                Text(
                  'Payment History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _credit!.payments.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final payment = _credit!.payments[index];
                return _buildPaymentItem(payment);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentItem(CreditPayment payment) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: _getPaymentMethodColor(payment.paymentMethod),
            radius: 20,
            child: Icon(
              _getPaymentMethodIcon(payment.paymentMethod),
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'UGX ${payment.amount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  payment.paymentMethod.toUpperCase(),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (payment.referenceNumber.isNotEmpty)
                  Text(
                    'Ref: ${payment.referenceNumber}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${payment.paymentDate.day}/${payment.paymentDate.month}/${payment.paymentDate.year}',
                style: const TextStyle(fontSize: 12),
              ),
              if (payment.notes.isNotEmpty)
                Text(
                  payment.notes,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.note, color: AppColors.primaryGreen, size: 24),
                SizedBox(width: 8),
                Text(
                  'Notes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            Text(
              _credit!.notes,
              style: const TextStyle(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _isProcessing ? null : _showAddPaymentDialog,
            icon: const Icon(Icons.payment),
            label: const Text(
              'Add Payment',
              style: TextStyle(fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: _remindCustomer,
            icon: const Icon(Icons.notifications),
            label: const Text(
              'Send Reminder',
              style: TextStyle(fontSize: 16),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryGreen,
              side: BorderSide(color: AppColors.primaryGreen),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddPaymentDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddPaymentDialog(
        creditId: widget.creditId,
        creditAmount: _credit!.amount,
        paidAmount: _credit!.paidAmount,
        onPaymentAdded: () {
          _loadCredit();
        },
      ),
    );
  }

  Future<void> _remindCustomer() async {
    setState(() {
      _isProcessing = true;
    });

    // Simulate sending reminder
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reminder sent successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }

    setState(() {
      _isProcessing = false;
    });
  }

  void _printCredit() {
    // TODO: Implement print functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Print feature coming soon')),
    );
  }

  void _shareCredit() {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share feature coming soon')),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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

  Color _getTypeColor(String type) {
    return type == 'customer' ? Colors.blue : Colors.orange;
  }

  Color _getPaymentMethodColor(String method) {
    switch (method) {
      case 'cash':
        return Colors.green;
      case 'bank':
        return Colors.blue;
      case 'cheque':
        return Colors.purple;
      case 'mobile':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method) {
      case 'cash':
        return Icons.money;
      case 'bank':
        return Icons.account_balance;
      case 'cheque':
        return Icons.receipt;
      case 'mobile':
        return Icons.phone_android;
      default:
        return Icons.payment;
    }
  }
}

class AddPaymentDialog extends StatefulWidget {
  final int creditId;
  final double creditAmount;
  final double paidAmount;
  final VoidCallback onPaymentAdded;

  const AddPaymentDialog({
    super.key,
    required this.creditId,
    required this.creditAmount,
    required this.paidAmount,
    required this.onPaymentAdded,
  });

  @override
  State<AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends State<AddPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _referenceNumberController = TextEditingController();
  final _notesController = TextEditingController();
  String _paymentMethod = 'cash';
  DateTime _paymentDate = DateTime.now();
  bool _isSaving = false;

  double get _remainingBalance => widget.creditAmount - widget.paidAmount;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Payment'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('Total Amount',
                        'UGX ${widget.creditAmount.toStringAsFixed(0)}'),
                    const SizedBox(height: 4),
                    _buildInfoRow('Paid Amount',
                        'UGX ${widget.paidAmount.toStringAsFixed(0)}'),
                    const Divider(),
                    _buildInfoRow('Remaining Balance',
                        'UGX ${_remainingBalance.toStringAsFixed(0)}',
                        isBold: true, color: Colors.orange),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Payment Amount *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.money),
                  prefixText: 'UGX ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null) {
                    return 'Please enter a valid amount';
                  }
                  if (amount <= 0) {
                    return 'Amount must be greater than 0';
                  }
                  if (amount > _remainingBalance) {
                    return 'Amount cannot exceed remaining balance (UGX ${_remainingBalance.toStringAsFixed(0)})';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _paymentMethod,
                decoration: const InputDecoration(
                  labelText: 'Payment Method',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.payment),
                ),
                items: const [
                  DropdownMenuItem(value: 'cash', child: Text('Cash')),
                  DropdownMenuItem(value: 'bank', child: Text('Bank Transfer')),
                  DropdownMenuItem(value: 'cheque', child: Text('Cheque')),
                  DropdownMenuItem(value: 'mobile', child: Text('Mobile Money')),
                ],
                onChanged: (value) {
                  setState(() {
                    _paymentMethod = value!;
                  });
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Payment Date'),
                subtitle: Text(
                    '${_paymentDate.day}/${_paymentDate.month}/${_paymentDate.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _paymentDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      _paymentDate = date;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _referenceNumberController,
                decoration: const InputDecoration(
                  labelText: 'Reference Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.receipt),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _savePayment,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
          ),
          child: _isSaving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save Payment'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value,
      {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }

  Future<void> _savePayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final paymentData = {
      'amount': double.parse(_amountController.text),
      'payment_date': _paymentDate.toIso8601String().split('T')[0],
      'payment_method': _paymentMethod,
      'reference_number': _referenceNumberController.text,
      'notes': _notesController.text,
    };

    try {
      final provider = Provider.of<CreditProvider>(context, listen: false);
      final success = await provider.addPayment(widget.creditId, paymentData);

      if (success && mounted) {
        widget.onPaymentAdded();
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment added successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to add payment'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}