import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/credit_provider.dart';

class CreateCreditScreen extends StatefulWidget {
  const CreateCreditScreen({super.key});

  @override
  State<CreateCreditScreen> createState() => _CreateCreditScreenState();
}

class _CreateCreditScreenState extends State<CreateCreditScreen> {
  final _formKey = GlobalKey<FormState>();
  String _creditType = 'customer';
  final _customerNameController = TextEditingController();
  final _supplierNameController = TextEditingController();
  final _amountController = TextEditingController();
  final _invoiceNumberController = TextEditingController();
  final _notesController = TextEditingController();
  final DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Credit')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Credit Type',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Customer'),
                            value: 'customer',
                            groupValue: _creditType,
                            onChanged: (value) {
                              setState(() => _creditType = value!);
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Supplier'),
                            value: 'supplier',
                            groupValue: _creditType,
                            onChanged: (value) {
                              setState(() => _creditType = value!);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (_creditType == 'customer')
                      TextFormField(
                        controller: _customerNameController,
                        decoration: const InputDecoration(labelText: 'Customer Name'),
                        validator: (v) => v!.isEmpty ? 'Enter name' : null,
                      )
                    else
                      TextFormField(
                        controller: _supplierNameController,
                        decoration: const InputDecoration(labelText: 'Supplier Name'),
                        validator: (v) => v!.isEmpty ? 'Enter name' : null,
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
              validator: (v) => double.tryParse(v ?? '') == null ? 'Invalid' : null,
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: _saveCredit,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveCredit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final data = {
      'credit_type': _creditType,
      'amount': double.parse(_amountController.text),
    };

    final provider = Provider.of<CreditProvider>(context, listen: false);

    try {
      await provider.createCredit(data);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isSaving = false);
    }
  }
}