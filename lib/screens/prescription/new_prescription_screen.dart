// lib/screens/prescription/new_prescription_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../services/api_service.dart';
import '../../models/patient_model.dart';
import '../../utils/constants.dart';

class NewPrescriptionScreen extends StatefulWidget {
  const NewPrescriptionScreen({super.key});

  @override
  State<NewPrescriptionScreen> createState() => _NewPrescriptionScreenState();
}

class _NewPrescriptionScreenState extends State<NewPrescriptionScreen> {
  final _formKey = GlobalKey<FormState>();

  // Patient fields
  final _patientNameCtrl = TextEditingController();
  final _patientPhoneCtrl = TextEditingController();
  final _patientAgeCtrl = TextEditingController();
  String _gender = '';

  // Prescription fields
  final _doctorCtrl = TextEditingController();
  final _doctorContactCtrl = TextEditingController();
  final _clinicCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _dateIssued = DateTime.now();

  // Drugs
  final List<_DrugEntry> _drugs = [_DrugEntry()];

  // Image/Scan
  File? _prescriptionImage;
  bool _isScanning = false;
  String? _scannedBarcode;

  bool _saving = false;
  bool _isSearching = false;
  List<Patient> _searchResults = [];
  Patient? _selectedPatient;

  @override
  void dispose() {
    _patientNameCtrl.dispose();
    _patientPhoneCtrl.dispose();
    _patientAgeCtrl.dispose();
    _doctorCtrl.dispose();
    _doctorContactCtrl.dispose();
    _clinicCtrl.dispose();
    _notesCtrl.dispose();
    for (var drug in _drugs) {
      drug.dispose();
    }
    super.dispose();
  }

  Future<void> _searchPatients(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }
    setState(() => _isSearching = true);
    try {
      final results = await ApiService.getPatientsStatic(search: query);
      setState(() {
        _searchResults = results.map((json) => Patient.fromJson(json)).toList();
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
      print('Search error: $e');
    }
  }

  void _selectPatient(Patient patient) {
    setState(() {
      _selectedPatient = patient;
      _patientNameCtrl.text = patient.fullName;
      _patientPhoneCtrl.text = patient.phone;
      _patientAgeCtrl.text = patient.age?.toString() ?? '';
      _gender = patient.gender;
      _searchResults = [];
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateIssued,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dateIssued = picked);
  }

  Future<void> _uploadImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _prescriptionImage = File(image.path);
      });
      await _processImage(image.path);
    }
  }

  Future<void> _takePhoto() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _prescriptionImage = File(image.path);
      });
      await _processImage(image.path);
    }
  }

  Future<void> _scanBarcode() async {
    setState(() {
      _isScanning = true;
    });
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BarcodeScannerScreen(),
      ),
    );
    
    setState(() {
      _isScanning = false;
    });
    
    if (result != null && result is String) {
      setState(() {
        _scannedBarcode = result;
      });
      await _fetchMedicineByBarcode(result);
    }
  }

  Future<void> _processImage(String imagePath) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image uploaded successfully! You can now fill prescription details.')),
    );
  }

  Future<void> _fetchMedicineByBarcode(String barcode) async {
    try {
      // FIXED: Use the static method from ApiService
      final response = await ApiService.getMedicineByBarcode(barcode);
      if (response.isSuccess && response.data != null) {
        final medicine = response.data;
        setState(() {
          final newDrug = _DrugEntry();
          newDrug.nameCtrl.text = medicine['name'] ?? '';
          newDrug.dosageCtrl.text = medicine['dosage'] ?? '';
          _drugs.add(newDrug);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Medicine found: ${medicine['name']}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medicine not found for this barcode'), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _printPrescription() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields'), backgroundColor: Colors.orange),
      );
      return;
    }

    final pdf = pw.Document();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'PRESCRIPTION',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.green,
              ),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Prescription Details',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Text('Prescription No: ${DateTime.now().millisecondsSinceEpoch}'),
                    ),
                    pw.Expanded(
                      child: pw.Text('Date: ${DateFormat('dd/MM/yyyy').format(_dateIssued)}'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Patient Information',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Text('Name: ${_patientNameCtrl.text}'),
                pw.Text('Phone: ${_patientPhoneCtrl.text}'),
                pw.Text('Age: ${_patientAgeCtrl.text}'),
                pw.Text('Gender: $_gender'),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Medications',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Medicine', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Dosage', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Frequency', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Duration', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                    for (var drug in _drugs.where((d) => d.nameCtrl.text.isNotEmpty))
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(drug.nameCtrl.text),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(drug.dosageCtrl.text),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(drug.freqCtrl.text),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(drug.durCtrl.text),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Doctor Information',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Text('Doctor: ${_doctorCtrl.text}'),
                pw.Text('Contact: ${_doctorContactCtrl.text}'),
                pw.Text('Clinic: ${_clinicCtrl.text}'),
                if (_notesCtrl.text.isNotEmpty)
                  pw.Text('Notes: ${_notesCtrl.text}'),
              ],
            ),
          ),
          pw.SizedBox(height: 30),
          pw.Center(
            child: pw.Text(
              'Thank you for choosing His Grace Drugshop',
              style: pw.TextStyle(fontSize: 12, fontStyle: pw.FontStyle.italic),
            ),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  void _addDrug() {
    setState(() {
      _drugs.add(_DrugEntry());
    });
  }

  void _removeDrug(int index) {
    setState(() {
      _drugs.removeAt(index);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final validDrugs = _drugs.where((d) => d.nameCtrl.text.trim().isNotEmpty).toList();
    if (validDrugs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one medication'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      int patientId;

      if (_selectedPatient == null) {
        final patientData = {
          'full_name': _patientNameCtrl.text.trim(),
          'phone': _patientPhoneCtrl.text.trim(),
          'age': _patientAgeCtrl.text.trim().isNotEmpty ? int.tryParse(_patientAgeCtrl.text) : null,
          'gender': _gender.isNotEmpty ? _gender : null,
        };
        final patient = await ApiService.createPatientStatic(patientData);
        patientId = patient['id'];
      } else {
        patientId = _selectedPatient!.id;
      }

      final drugs = validDrugs.map((d) => ({
        'drug_name': d.nameCtrl.text.trim(),
        'dosage': d.dosageCtrl.text.trim(),
        'frequency': d.freqCtrl.text.trim(),
        'duration': d.durCtrl.text.trim(),
        'quantity': 1,
        'notes': '',
      })).toList();

      final prescriptionData = {
        'patient_id': patientId,
        'prescribing_doctor': _doctorCtrl.text.trim(),
        'doctor_contact': _doctorContactCtrl.text.trim(),
        'clinic': _clinicCtrl.text.trim(),
        'diagnosis_notes': _notesCtrl.text.trim(),
        'date_issued': DateFormat('yyyy-MM-dd').format(_dateIssued),
        'status': 'pending',
        'source': 'manual',
        'drugs': drugs,
      };

      await ApiService.createPrescriptionStatic(prescriptionData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prescription saved successfully'), backgroundColor: Colors.green),
        );
        _clearForm();
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _clearForm() {
    _patientNameCtrl.clear();
    _patientPhoneCtrl.clear();
    _patientAgeCtrl.clear();
    _doctorCtrl.clear();
    _doctorContactCtrl.clear();
    _clinicCtrl.clear();
    _notesCtrl.clear();
    setState(() {
      _gender = '';
      _dateIssued = DateTime.now();
      _selectedPatient = null;
      _searchResults = [];
      _prescriptionImage = null;
      _scannedBarcode = null;
      _drugs.clear();
      _drugs.add(_DrugEntry());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Prescription'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _printPrescription,
            tooltip: 'Print Prescription',
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: _saving
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  : TextButton(
                      onPressed: _save,
                      child: const Text('Save', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Upload / Scan Prescription'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _uploadImage,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _takePhoto,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Take Photo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _scanBarcode,
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Scan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              if (_prescriptionImage != null) ...[
                const SizedBox(height: 12),
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: FileImage(_prescriptionImage!),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 4,
                        right: 4,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white, size: 18),
                          onPressed: () => setState(() => _prescriptionImage = null),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black54,
                            padding: const EdgeInsets.all(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (_scannedBarcode != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.qr_code, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Scanned: $_scannedBarcode',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () => setState(() => _scannedBarcode = null),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),

              _buildSectionTitle('Patient Information'),
              const SizedBox(height: 12),
              
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search existing patient...',
                        prefixIcon: Icon(Icons.search, size: 20),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(14),
                      ),
                      onChanged: _searchPatients,
                    ),
                    if (_isSearching)
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: Center(
                          child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                      ),
                    if (_searchResults.isNotEmpty)
                      ..._searchResults.map((p) => ListTile(
                        title: Text(p.fullName, style: const TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text('${p.patientId} · ${p.phone}'),
                        dense: true,
                        onTap: () => _selectPatient(p),
                      )),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              if (_selectedPatient != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('Selected: ${_selectedPatient!.fullName}', style: const TextStyle(fontWeight: FontWeight.w500)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => setState(() => _selectedPatient = null),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 12),
              TextFormField(
                controller: _patientNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Patient Full Name *',
                  hintText: 'e.g. John Doe',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.isEmpty == true ? 'Please enter patient name' : null,
                enabled: _selectedPatient == null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _patientPhoneCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        hintText: '+235 700 000000',
                        prefixIcon: Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      enabled: _selectedPatient == null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _patientAgeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        prefixIcon: Icon(Icons.cake_outlined),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      enabled: _selectedPatient == null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _gender.isEmpty ? null : _gender,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  prefixIcon: Icon(Icons.wc_outlined),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: _selectedPatient == null
                    ? (v) => setState(() => _gender = v ?? '')
                    : null,
              ),
              const SizedBox(height: 24),
              
              _buildSectionTitle('Prescription Details'),
              const SizedBox(height: 12),
              
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.grey),
                      const SizedBox(width: 12),
                      Text(
                        'Date Issued: ${DateFormat('dd MMM yyyy').format(_dateIssued)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _doctorCtrl,
                decoration: const InputDecoration(
                  labelText: "Doctor's Name",
                  hintText: 'Dr. Michael Smith',
                  prefixIcon: Icon(Icons.local_hospital),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _doctorContactCtrl,
                decoration: const InputDecoration(
                  labelText: "Doctor's Contact",
                  hintText: 'Email or Phone',
                  prefixIcon: Icon(Icons.alternate_email),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _clinicCtrl,
                decoration: const InputDecoration(
                  labelText: 'City / Hospital',
                  hintText: 'City Medical Center',
                  prefixIcon: Icon(Icons.location_city),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Additional Notes',
                  hintText: 'e.g. Urgent, liquid form preferred...',
                  prefixIcon: Icon(Icons.note_add),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionTitle('Medications'),
                  TextButton.icon(
                    onPressed: _addDrug,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Medication'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              ..._drugs.asMap().entries.map((entry) => _DrugEntryWidget(
                entry: entry.value,
                index: entry.key,
                canRemove: _drugs.length > 1,
                onRemove: () => _removeDrug(entry.key),
              )),
              
              const SizedBox(height: 32),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving ? null : _clearForm,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Clear Form'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _saving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Save Prescription'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.darkText,
      ),
    );
  }
}

class _DrugEntry {
  final nameCtrl = TextEditingController();
  final dosageCtrl = TextEditingController();
  final freqCtrl = TextEditingController();
  final durCtrl = TextEditingController();

  void dispose() {
    nameCtrl.dispose();
    dosageCtrl.dispose();
    freqCtrl.dispose();
    durCtrl.dispose();
  }
}

class _DrugEntryWidget extends StatelessWidget {
  final _DrugEntry entry;
  final int index;
  final bool canRemove;
  final VoidCallback onRemove;

  const _DrugEntryWidget({
    required this.entry,
    required this.index,
    required this.canRemove,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.veryLightGreen,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Medication', style: TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                if (canRemove)
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: entry.nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Drug Name *',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              validator: (v) => v?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: entry.dosageCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Dosage',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: entry.freqCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Frequency',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: entry.durCtrl,
              decoration: const InputDecoration(
                labelText: 'Duration',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Barcode Scanner Screen
class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  String? _scannedCode;
  bool _isScanning = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        actions: [
          IconButton(
            icon: Icon(_isScanning ? Icons.flash_on : Icons.flash_off),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: Icon(Icons.cameraswitch),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              if (!_isScanning) return;
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  setState(() {
                    _scannedCode = barcode.rawValue;
                    _isScanning = false;
                  });
                  Navigator.pop(context, _scannedCode);
                  return;
                }
              }
            },
          ),
          if (_scannedCode != null)
            Container(
              color: Colors.black54,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 48),
                        const SizedBox(height: 16),
                        Text('Scanned: $_scannedCode'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, _scannedCode),
                          child: const Text('Use This Code'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Align barcode within the frame',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}