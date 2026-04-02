// lib/screens/prescription/create_prescription_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/prescription_provider.dart';
import '../../providers/medicine_provider.dart';
import '../../utils/constants.dart';

class CreatePrescriptionScreen extends StatefulWidget {
  const CreatePrescriptionScreen({super.key});

  @override
  State<CreatePrescriptionScreen> createState() => _CreatePrescriptionScreenState();
}

class _CreatePrescriptionScreenState extends State<CreatePrescriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientNameController = TextEditingController();
  final _patientPhoneController = TextEditingController();
  final _patientAddressController = TextEditingController();
  final _doctorNameController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  final List<PrescriptionItemInput> _items = [];
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Prescription'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Patient Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Patient Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _patientNameController,
                      decoration: const InputDecoration(
                        labelText: 'Patient Name *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter patient name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _patientPhoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _patientAddressController,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Prescription Details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Prescription Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _doctorNameController,
                      decoration: const InputDecoration(
                        labelText: 'Doctor Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.local_hospital),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      title: const Text('Prescription Date'),
                      subtitle: Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
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

            // Prescription Items
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
                          'Prescription Items',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _showAddItemDialog,
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
                        separatorBuilder: (context, index) =>
                            const Divider(),
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return ListTile(
                            title: Text(item.productName),
                            subtitle: Text(
                              'Qty: ${item.quantity} | Dosage: ${item.dosage} | ${item.frequency}',
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'UGX ${(item.quantity * item.unitPrice).toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _items.removeAt(index);
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    if (_items.isNotEmpty)
                      const Divider(),
                    if (_items.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Amount:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'UGX ${_calculateTotal().toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ],
                        ),
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
                onPressed: _isSaving ? null : _savePrescription,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator()
                    : const Text(
                        'Save Prescription',
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
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: AddPrescriptionItemDialog(
          onAdd: (item) {
            setState(() {
              _items.add(item);
            });
          },
        ),
      ),
    );
  }

  double _calculateTotal() {
    return _items.fold(0, (sum, item) => sum + (item.quantity * item.unitPrice));
  }

  Future<void> _savePrescription() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final prescriptionData = {
      'patient_name': _patientNameController.text,
      'patient_phone': _patientPhoneController.text,
      'patient_address': _patientAddressController.text,
      'doctor_name': _doctorNameController.text,
      'date': _selectedDate.toIso8601String().split('T')[0],
      'notes': _notesController.text,
      'items': _items.map((item) => {
        'product': item.productId,
        'quantity': item.quantity,
        'dosage': item.dosage,
        'frequency': item.frequency,
        'duration': item.duration,
        'unit_price': item.unitPrice,
      }).toList(),
    };

    try {
      final provider = Provider.of<PrescriptionProvider>(context, listen: false);
      final prescription = await provider.createPrescription(prescriptionData);
      
      if (prescription != null) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Prescription created successfully')),
          );
        }
      } else {
        throw Exception('Failed to create prescription');
      }
    } catch (e) {
      if (mounted) {
        final provider = Provider.of<PrescriptionProvider>(context, listen: false);
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

class PrescriptionItemInput {
  final int productId;
  final String productName;
  final int quantity;
  final String dosage;
  final String frequency;
  final String duration;
  final double unitPrice;

  PrescriptionItemInput({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.dosage,
    required this.frequency,
    required this.duration,
    required this.unitPrice,
  });
}

class AddPrescriptionItemDialog extends StatefulWidget {
  final Function(PrescriptionItemInput) onAdd;

  const AddPrescriptionItemDialog({super.key, required this.onAdd});

  @override
  State<AddPrescriptionItemDialog> createState() => _AddPrescriptionItemDialogState();
}

class _AddPrescriptionItemDialogState extends State<AddPrescriptionItemDialog> {
  int? _selectedProductId;
  String _selectedProductName = '';
  double _unitPrice = 0;
  int _quantity = 1;
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _durationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final medicines = Provider.of<MedicineProvider>(context).medicines;

    return Container(
      padding: const EdgeInsets.all(16),
      width: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Add Prescription Item',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(
              labelText: 'Select Medicine *',
              border: OutlineInputBorder(),
            ),
            items: medicines.map((medicine) {
              return DropdownMenuItem(
                value: medicine.id,
                child: Text('${medicine.name} - UGX ${medicine.price}'),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedProductId = value;
                final medicine = medicines.firstWhere((m) => m.id == value);
                _selectedProductName = medicine.name;
                _unitPrice = medicine.price;
              });
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _dosageController,
            decoration: const InputDecoration(
              labelText: 'Dosage (e.g., 500mg)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _frequencyController,
            decoration: const InputDecoration(
              labelText: 'Frequency (e.g., Twice daily)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _durationController,
            decoration: const InputDecoration(
              labelText: 'Duration (e.g., 7 days)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: _quantity.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Quantity *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _quantity = int.tryParse(value) ?? 1;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  initialValue: _unitPrice.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Unit Price *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _unitPrice = double.tryParse(value) ?? 0;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _selectedProductId == null
                    ? null
                    : () {
                        widget.onAdd(
                          PrescriptionItemInput(
                            productId: _selectedProductId!,
                            productName: _selectedProductName,
                            quantity: _quantity,
                            dosage: _dosageController.text,
                            frequency: _frequencyController.text,
                            duration: _durationController.text,
                            unitPrice: _unitPrice,
                          ),
                        );
                        Navigator.pop(context);
                      },
                child: const Text('Add'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}