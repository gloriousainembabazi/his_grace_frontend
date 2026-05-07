// lib/screens/stock/create_stock_take_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/stock_provider.dart';
import '../../providers/medicine_provider.dart';
import '../../models/medicine.dart';
import '../../utils/constants.dart';

class CreateStockTakeScreen extends StatefulWidget {
  const CreateStockTakeScreen({super.key});

  @override
  State<CreateStockTakeScreen> createState() => _CreateStockTakeScreenState();
}

class _CreateStockTakeScreenState extends State<CreateStockTakeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  DateTime _stockTakeDate = DateTime.now();
  final List<StockTakeItemInput> _items = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  Future<void> _loadMedicines() async {
    await Provider.of<MedicineProvider>(context, listen: false).loadMedicines();
  }

  @override
  Widget build(BuildContext context) {
    final medicines = Provider.of<MedicineProvider>(context).medicines;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Stock Take'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Stock Take Details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Stock Take Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Stock Take Date'),
                      subtitle: Text(
                          '${_stockTakeDate.day}/${_stockTakeDate.month}/${_stockTakeDate.year}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _selectDate,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note),
                      ),
                      maxLines: 3,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Stock Items',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            _showAddItemDialog(medicines);
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add Item'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_items.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text('No items added yet'),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _items.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          final difference = item.actualQuantity - item.systemQuantity;
                          final discrepancyValue = difference * item.costPrice;

                          return ListTile(
                            title: Text(item.productName),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('System: ${item.systemQuantity} | Actual: ${item.actualQuantity}'),
                                Text(
                                  'Difference: $difference (UGX ${discrepancyValue.toStringAsFixed(0)})',
                                  style: TextStyle(
                                    color: difference != 0 ? Colors.orange : Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _items.removeAt(index);
                                });
                              },
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveStockTake,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator()
                    : const Text(
                        'Create Stock Take',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _stockTakeDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _stockTakeDate = date;
      });
    }
  }

  void _showAddItemDialog(List<Medicine> medicines) {
    showDialog(
      context: context,
      builder: (context) => AddStockItemDialog(
        medicines: medicines,
        onAdd: (item) {
          setState(() {
            // Check if item already exists
            final existingIndex = _items.indexWhere((i) => i.productId == item.productId);
            if (existingIndex != -1) {
              _items[existingIndex] = item;
            } else {
              _items.add(item);
            }
          });
        },
      ),
    );
  }

  Future<void> _saveStockTake() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final stockTakeData = {
      'date': _stockTakeDate.toIso8601String().split('T')[0],
      'notes': _notesController.text,
    };

    final provider = Provider.of<StockProvider>(context, listen: false);

    try {
      final stockTake = await provider.createStockTake(stockTakeData);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stock take created successfully')),
        );
      }
        } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${provider.error ?? e.toString()}')),
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

class StockTakeItemInput {
  final int productId;
  final String productName;
  final double costPrice;
  final int systemQuantity;
  int actualQuantity;
  final String notes;

  StockTakeItemInput({
    required this.productId,
    required this.productName,
    required this.costPrice,
    required this.systemQuantity,
    required this.actualQuantity,
    this.notes = '',
  });
}

class AddStockItemDialog extends StatefulWidget {
  final List<Medicine> medicines;
  final Function(StockTakeItemInput) onAdd;

  const AddStockItemDialog({
    super.key,
    required this.medicines,
    required this.onAdd,
  });

  @override
  State<AddStockItemDialog> createState() => _AddStockItemDialogState();
}

class _AddStockItemDialogState extends State<AddStockItemDialog> {
  int? _selectedProductId;
  String _selectedProductName = '';
  double _costPrice = 0;
  int _systemQuantity = 0;
  int _actualQuantity = 0;
  final _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Stock Item'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Select Medicine *',
                border: OutlineInputBorder(),
              ),
              items: widget.medicines.map((medicine) {
                return DropdownMenuItem(
                  value: medicine.id,
                  child: Text('${medicine.name} (Stock: ${medicine.quantity})'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedProductId = value;
                  final medicine = widget.medicines.firstWhere((m) => m.id == value);
                  _selectedProductName = medicine.name;
                  _costPrice = medicine.price;
                  _systemQuantity = medicine.quantity;
                  _actualQuantity = medicine.quantity;
                });
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _systemQuantity.toString(),
              decoration: const InputDecoration(
                labelText: 'System Quantity *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.computer),
              ),
              readOnly: true,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _actualQuantity.toString(),
              decoration: const InputDecoration(
                labelText: 'Actual Quantity *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.inventory),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _actualQuantity = int.tryParse(value) ?? 0;
                });
              },
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
            if (_selectedProductId != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Difference:'),
                      Text(
                        '${_actualQuantity - _systemQuantity}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: (_actualQuantity - _systemQuantity) != 0
                              ? Colors.orange
                              : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedProductId == null
              ? null
              : () {
                  widget.onAdd(
                    StockTakeItemInput(
                      productId: _selectedProductId!,
                      productName: _selectedProductName,
                      costPrice: _costPrice,
                      systemQuantity: _systemQuantity,
                      actualQuantity: _actualQuantity,
                      notes: _notesController.text,
                    ),
                  );
                  Navigator.pop(context);
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
          ),
          child: const Text('Add'),
        ),
      ],
    );
  }
}