// lib/screens/prescription/prescription_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../providers/prescription_provider.dart';
import '../../models/prescription_model.dart';
import '../../utils/constants.dart';

class PrescriptionDetailScreen extends StatefulWidget {
  final int prescriptionId;

  const PrescriptionDetailScreen({super.key, required this.prescriptionId});

  @override
  State<PrescriptionDetailScreen> createState() => _PrescriptionDetailScreenState();
}

class _PrescriptionDetailScreenState extends State<PrescriptionDetailScreen> {
  Prescription? _prescription;
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadPrescription();
  }

  Future<void> _loadPrescription() async {
    setState(() => _isLoading = true);
    try {
      final provider = Provider.of<PrescriptionProvider>(context, listen: false);
      final prescription = await provider.getPrescription(widget.prescriptionId);
      setState(() {
        _prescription = prescription;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) _showSnack('Error: $e', error: true);
    }
  }

  void _showSnack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _confirmDispense() async {
    if (_prescription == null) return;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Dispense Prescription'),
        content: Text(
          'Confirm dispensing ${_prescription!.prescriptionNumber} to ${_prescription!.patientName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
            ),
            child: const Text('Dispense'),
          ),
        ],
      ),
    );
    
    if (confirm != true || !mounted) return;

    setState(() => _isProcessing = true);
    final provider = Provider.of<PrescriptionProvider>(context, listen: false);
    final success = await provider.dispensePrescription(_prescription!.id);
    
    if (mounted) {
      setState(() => _isProcessing = false);
      if (success) {
        await _loadPrescription();
        _showSnack('Prescription dispensed successfully');
      } else {
        _showSnack(provider.error ?? 'Failed to dispense', error: true);
      }
    }
  }

  Future<void> _confirmCancel() async {
    if (_prescription == null) return;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Prescription'),
        content: const Text('Are you sure you want to cancel this prescription?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
    
    if (confirm != true || !mounted) return;

    setState(() => _isProcessing = true);
    final provider = Provider.of<PrescriptionProvider>(context, listen: false);
    final success = await provider.cancelPrescription(_prescription!.id);
    
    if (mounted) {
      setState(() => _isProcessing = false);
      if (success) {
        await _loadPrescription();
        _showSnack('Prescription cancelled');
      } else {
        _showSnack(provider.error ?? 'Failed to cancel', error: true);
      }
    }
  }

  Future<void> _printPdf() async {
    if (_prescription == null) return;
    
    final rx = _prescription!;
    final doc = pw.Document();
    
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'His Grace Drugshop',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.teal800,
                      ),
                    ),
                    pw.Text(
                      'Nyamukana, Ntungamo District, Uganda',
                      style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      '℞ Prescription',
                      style: pw.TextStyle(
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.teal700,
                      ),
                    ),
                    pw.Text(rx.prescriptionNumber, style: const pw.TextStyle(fontSize: 10)),
                    pw.Text(
                      'Date: ${rx.date.day}/${rx.date.month}/${rx.date.year}',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ],
                ),
              ],
            ),
            pw.Divider(color: PdfColors.grey400),
            pw.SizedBox(height: 6),
            _pdfRow('Patient', rx.patientName),
            if (rx.patientPhone.isNotEmpty) _pdfRow('Phone', rx.patientPhone),
            if (rx.patientAddress.isNotEmpty) _pdfRow('Address', rx.patientAddress),
            _pdfRow('Doctor', rx.doctorName.isNotEmpty ? rx.doctorName : '—'),
            if (rx.notes.isNotEmpty) _pdfRow('Diagnosis', rx.notes),
            pw.SizedBox(height: 10),
            pw.Text(
              'Prescribed Drugs',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
            ),
            pw.SizedBox(height: 5),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(1.5),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(1.5),
                4: const pw.FlexColumnWidth(1.2),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  children: ['Drug', 'Dosage', 'Frequency', 'Duration', 'Qty']
                      .map((h) => pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(
                              h,
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
                            ),
                          ))
                      .toList(),
                ),
                ...rx.items.map(
                  (d) => pw.TableRow(children: [
                    _pdfCell(d.productName),
                    _pdfCell(d.dosage),
                    _pdfCell(d.frequency),
                    _pdfCell(d.duration),
                    _pdfCell('${d.quantity}'),
                  ]),
                ),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text(
                  'Total: UGX ${rx.totalAmount.toStringAsFixed(0)}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
                ),
              ],
            ),
            pw.Spacer(),
            pw.Divider(color: PdfColors.grey400),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Dispensed by: ______________________',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Date: _________________________________',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.SizedBox(height: 28),
                    pw.Container(
                      width: 100,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey)),
                      ),
                    ),
                    pw.Text(
                      'Pharmacist signature',
                      style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
    
    await Printing.layoutPdf(onLayout: (_) async => doc.save());
  }

  pw.Widget _pdfRow(String label, String value) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 3),
        child: pw.Row(
          children: [
            pw.SizedBox(
              width: 80,
              child: pw.Text(
                label,
                style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700),
              ),
            ),
            pw.Text(value, style: const pw.TextStyle(fontSize: 8)),
          ],
        ),
      );

  pw.Widget _pdfCell(String text) => pw.Padding(
        padding: const pw.EdgeInsets.all(5),
        child: pw.Text(text, style: const pw.TextStyle(fontSize: 8)),
      );

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_prescription == null) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('Prescription not found'),
            ],
          ),
        ),
      );
    }

    final rx = _prescription!;

    return Scaffold(
      appBar: AppBar(
        title: Text(rx.prescriptionNumber),
        actions: [
          if (rx.status == 'pending')
            IconButton(
              icon: const Icon(Icons.medication),
              tooltip: 'Dispense',
              onPressed: _confirmDispense,
            ),
          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: 'Print',
            onPressed: _printPdf,
          ),
          if (rx.status == 'pending')
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'cancel') _confirmCancel();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'cancel',
                  child: Row(
                    children: [
                      Icon(Icons.cancel_outlined, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Cancel Prescription', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
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
                                rx.prescriptionNumber,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Date: ${rx.date.day}/${rx.date.month}/${rx.date.year}',
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: rx.statusColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            rx.status.toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
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
                          'UGX ${rx.totalAmount.toStringAsFixed(0)}',
                          Icons.attach_money,
                          Colors.blue,
                        ),
                        Container(width: 1, height: 40, color: Colors.grey[300]),
                        _buildStatItem('Items', '${rx.items.length}', Icons.medication, Colors.green),
                        Container(width: 1, height: 40, color: Colors.grey[300]),
                        _buildStatItem('Source', rx.source, Icons.info_outline, Colors.orange),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Patient Info Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.person, color: AppColors.primaryGreen, size: 24),
                        SizedBox(width: 8),
                        Text('Patient Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(),
                    _buildInfoRow('Name:', rx.patientName),
                    if (rx.patientPhone.isNotEmpty) _buildInfoRow('Phone:', rx.patientPhone),
                    if (rx.patientAddress.isNotEmpty) _buildInfoRow('Address:', rx.patientAddress),
                    if (rx.doctorName.isNotEmpty) _buildInfoRow('Doctor:', rx.doctorName),
                    if (rx.notes.isNotEmpty) _buildInfoRow('Diagnosis:', rx.notes),
                    if (rx.dispensedByName != null) _buildInfoRow('Dispensed by:', rx.dispensedByName!),
                    if (rx.dispensedAt != null)
                      _buildInfoRow(
                        'Dispensed at:',
                        '${rx.dispensedAt!.day}/${rx.dispensedAt!.month}/${rx.dispensedAt!.year}',
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Drugs Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.medication, color: AppColors.primaryGreen, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Prescribed Drugs (${rx.items.length})',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(),
                    if (rx.items.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No drugs recorded', style: TextStyle(color: Colors.grey)),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: rx.items.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (_, i) {
                          final d = rx.items[i];
                          return ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFFE1F5EE),
                              child: Icon(Icons.medication, color: AppColors.primaryGreen, size: 20),
                            ),
                            title: Text(d.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text([
                              if (d.dosage.isNotEmpty) d.dosage,
                              if (d.frequency.isNotEmpty) d.frequency,
                              if (d.duration.isNotEmpty) d.duration,
                            ].join('  ·  ')),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('x${d.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text(
                                  'UGX ${d.totalPrice.toStringAsFixed(0)}',
                                  style: const TextStyle(color: AppColors.primaryGreen, fontSize: 12),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    if (rx.items.isNotEmpty) ...[
                      const Divider(thickness: 1.5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(
                            'UGX ${rx.totalAmount.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
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
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}