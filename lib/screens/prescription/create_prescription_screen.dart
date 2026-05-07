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
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMedicines());
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _patientPhoneController.dispose();
    _patientAddressController.dispose();
    _doctorNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadMedicines() async {
    await Provider.of<MedicineProvider>(context, listen: false).loadMedicines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Prescription')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Patient Information ─────────────────────────────────────────
            _buildSectionCard(
              title: 'Patient Information',
              icon: Icons.person,
              children: [
                TextFormField(
                  controller: _patientNameController,
                  decoration: const InputDecoration(
                    labelText: 'Patient Name *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Please enter patient name' : null,
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
            const SizedBox(height: 16),

            // ── Prescription Details ────────────────────────────────────────
            _buildSectionCard(
              title: 'Prescription Details',
              icon: Icons.medical_services,
              children: [
                TextFormField(
                  controller: _doctorNameController,
                  decoration: const InputDecoration(
                    labelText: 'Doctor Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.local_hospital),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Prescription Date'),
                  subtitle: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  ),
                  trailing: const Icon(Icons.edit, size: 18),
                  onTap: _selectDate,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Diagnosis / Notes',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.note),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Prescription Items ──────────────────────────────────────────
            _buildSectionCard(
              title: 'Prescription Items',
              icon: Icons.medication,
              trailing: ElevatedButton.icon(
                onPressed: _showAddItemDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Item'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              children: [
                if (_items.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No items added yet', style: TextStyle(color: Colors.grey)),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (_, i) => _ItemRow(
                      item: _items[i],
                      onDelete: () => setState(() => _items.removeAt(i)),
                    ),
                  ),
                if (_items.isNotEmpty) ...[
                  const Divider(thickness: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                ],
              ],
            ),
            const SizedBox(height: 24),

            // ── Submit ──────────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _savePrescription,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Save Prescription', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    Widget? trailing,
  }) {
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
                Icon(icon, color: AppColors.primaryGreen, size: 22),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                if (trailing != null) ...[const Spacer(), trailing],
              ],
            ),
            const Divider(),
            ...children,
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
    if (date != null) setState(() => _selectedDate = date);
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: AddPrescriptionItemDialog(
          onAdd: (item) => setState(() => _items.add(item)),
        ),
      ),
    );
  }

  double _calculateTotal() =>
      _items.fold(0, (sum, item) => sum + (item.quantity * item.unitPrice));

  Future<void> _savePrescription() async {
    if (!_formKey.currentState!.validate()) return;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final prescriptionData = {
      'patient_name': _patientNameController.text.trim(),
      'patient_phone': _patientPhoneController.text.trim(),
      'patient_address': _patientAddressController.text.trim(),
      'doctor_name': _doctorNameController.text.trim(),
      'date': _selectedDate.toIso8601String().split('T')[0],
      'notes': _notesController.text.trim(),
      'status': 'pending',
      'source': 'manual',
      'items': _items
          .map((item) => {
                'product': item.productId,
                'product_name': item.productName,
                'quantity': item.quantity,
                'unit_price': item.unitPrice,
                'dosage': item.dosage,
                'frequency': item.frequency,
                'duration': item.duration,
              })
          .toList(),
    };

    try {
      final provider = Provider.of<PrescriptionProvider>(context, listen: false);
      final prescription = await provider.createPrescription(prescriptionData);

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prescription created successfully'),
          backgroundColor: Colors.green,
        ),
      );
        } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

// ── Item row widget ─────────────────────────────────────────────────────────

class _ItemRow extends StatelessWidget {
  final PrescriptionItemInput item;
  final VoidCallback onDelete;

  const _ItemRow({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.medication, color: AppColors.primaryGreen, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  'Qty: ${item.quantity}  ·  ${item.dosage}  ·  ${item.frequency}  ·  ${item.duration}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  'UGX ${(item.quantity * item.unitPrice).toStringAsFixed(0)}',
                  style: const TextStyle(
                      color: AppColors.primaryGreen, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

// ── Data class ──────────────────────────────────────────────────────────────

class PrescriptionItemInput {
  final int? productId;
  final String productName;
  final int quantity;
  final String dosage;
  final String frequency;
  final String duration;
  final double unitPrice;

  PrescriptionItemInput({
    this.productId,
    required this.productName,
    required this.quantity,
    required this.dosage,
    required this.frequency,
    required this.duration,
    required this.unitPrice,
  });
}

// ── Add item dialog ─────────────────────────────────────────────────────────

class AddPrescriptionItemDialog extends StatefulWidget {
  final Function(PrescriptionItemInput) onAdd;

  const AddPrescriptionItemDialog({super.key, required this.onAdd});

  @override
  State<AddPrescriptionItemDialog> createState() =>
      _AddPrescriptionItemDialogState();
}

class _AddPrescriptionItemDialogState extends State<AddPrescriptionItemDialog> {
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _durationController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _priceController = TextEditingController(text: '0');

  int? _selectedProductId;
  String _selectedProductName = '';
  double _unitPrice = 0;

  @override
  void dispose() {
    _dosageController.dispose();
    _frequencyController.dispose();
    _durationController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final medicines = Provider.of<MedicineProvider>(context).medicines;

    return Container(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.add_circle, color: AppColors.primaryGreen),
                const SizedBox(width: 8),
                const Text('Add Prescription Item',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close)),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Select Medicine *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medication),
              ),
              items: medicines
                  .map((m) => DropdownMenuItem(
                        value: m.id,
                        child: Text('${m.name} — UGX ${m.price.toStringAsFixed(0)}'),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                final medicine = medicines.firstWhere((m) => m.id == value);
                setState(() {
                  _selectedProductId = value;
                  _selectedProductName = medicine.name;
                  _unitPrice = medicine.price.toDouble();
                  _priceController.text = _unitPrice.toStringAsFixed(0);
                });
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                        labelText: 'Quantity *', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                        labelText: 'Unit Price (UGX)', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    onChanged: (v) =>
                        setState(() => _unitPrice = double.tryParse(v) ?? 0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _dosageController,
              decoration: const InputDecoration(
                  labelText: 'Dosage (e.g. 500mg)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _frequencyController,
              decoration: const InputDecoration(
                  labelText: 'Frequency (e.g. Twice daily)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _durationController,
              decoration: const InputDecoration(
                  labelText: 'Duration (e.g. 7 days)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _selectedProductId == null ? null : _add,
                icon: const Icon(Icons.add),
                label: const Text('Add to Prescription'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _add() {
    widget.onAdd(PrescriptionItemInput(
      productId: _selectedProductId,
      productName: _selectedProductName,
      quantity: int.tryParse(_quantityController.text) ?? 1,
      unitPrice: double.tryParse(_priceController.text) ?? _unitPrice,
      dosage: _dosageController.text.trim(),
      frequency: _frequencyController.text.trim(),
      duration: _durationController.text.trim(),
    ));
    Navigator.pop(context);
  }
}