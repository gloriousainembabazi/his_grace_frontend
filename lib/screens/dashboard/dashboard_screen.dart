// lib/screens/dashboard/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart' as fl;
import '../../providers/auth_provider.dart';
import '../../providers/medicine_provider.dart';
import '../../providers/sale_provider.dart';
import '../../providers/prescription_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/credit_provider.dart';
import '../../providers/stock_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../models/prescription_model.dart';
import '../../utils/constants.dart';
import '../prescription/prescription_list_screen.dart';
import '../reports/report_dashboard.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  String _userName = 'Glorious';

  final List<Widget> _screens = [
    const DashboardHome(),
    const PrescriptionListScreen(),
    const MedicineListScreen(),
    const ReportDashboard(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'Prescriptions',
    'Medicines',
    'Reports',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadDashboardData();
  }

  Future<void> _loadUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    if (user != null && user.fullName.isNotEmpty) {
      setState(() {
        _userName = user.fullName.split(' ')[0];
      });
    }
  }

  Future<void> _loadDashboardData() async {
    final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
    final medicineProvider = Provider.of<MedicineProvider>(context, listen: false);
    final saleProvider = Provider.of<SaleProvider>(context, listen: false);
    final prescriptionProvider = Provider.of<PrescriptionProvider>(context, listen: false);
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    final creditProvider = Provider.of<CreditProvider>(context, listen: false);
    final stockProvider = Provider.of<StockProvider>(context, listen: false);

    await Future.wait([
      dashboardProvider.loadDashboard(),
      medicineProvider.loadMedicines(),
      medicineProvider.loadLowStockMedicines(),
      medicineProvider.loadExpiringMedicines(),
      saleProvider.loadDailySales(),
      saleProvider.loadSales(),
      prescriptionProvider.loadPrescriptions(),
      expenseProvider.loadExpenses(),
      creditProvider.loadCredits(),
      stockProvider.loadStockTakes(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primaryGreen,
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.medical_information_outlined),
              activeIcon: Icon(Icons.medical_information),
              label: 'Prescriptions',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.medication_outlined),
              activeIcon: Icon(Icons.medication),
              label: 'Medicines',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assessment_outlined),
              activeIcon: Icon(Icons.assessment),
              label: 'Reports',
            ),
          ],
        ),
      ),
    );
  }
}

// Enhanced Dashboard Home Widget with Charts
class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  String _selectedChartPeriod = 'weekly';
  final Map<String, String> _periodOptions = {
    'daily': 'Today',
    'weekly': 'This Week',
    'monthly': 'This Month',
    'yearly': 'This Year',
  };

  @override
  void initState() {
    super.initState();
    _loadChartData();
  }

  Future<void> _loadChartData() async {
    final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
    await dashboardProvider.fetchSalesChart(period: _selectedChartPeriod);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        final medicineProvider = Provider.of<MedicineProvider>(context, listen: false);
        final saleProvider = Provider.of<SaleProvider>(context, listen: false);
        final prescriptionProvider = Provider.of<PrescriptionProvider>(context, listen: false);
        final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
        
        await Future.wait([
          medicineProvider.loadMedicines(),
          medicineProvider.loadLowStockMedicines(),
          medicineProvider.loadExpiringMedicines(),
          saleProvider.loadDailySales(),
          saleProvider.loadSales(),
          prescriptionProvider.loadPrescriptions(),
          dashboardProvider.loadDashboard(),
          dashboardProvider.fetchSalesChart(period: _selectedChartPeriod),
        ]);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildStatsCards(),
            const SizedBox(height: 20),
            _buildQuickActionsSection(),
            const SizedBox(height: 24),
            Consumer<DashboardProvider>(
              builder: (context, dashboardProvider, child) {
                return _buildSalesChartSection(dashboardProvider);
              },
            ),
            const SizedBox(height: 24),
            Consumer<PrescriptionProvider>(
              builder: (context, provider, child) {
                return _buildPendingPrescriptionsSection(provider);
              },
            ),
            const SizedBox(height: 24),
            Consumer<MedicineProvider>(
              builder: (context, provider, child) {
                return _buildInventoryAlertsSection(provider);
              },
            ),
            const SizedBox(height: 24),
            Consumer<CreditProvider>(
              builder: (context, creditProvider, child) {
                return _buildPaymentStatusSection(creditProvider);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.currentUser?.fullName.split(' ').first ?? 'Glorious';
    final timeOfDay = _getTimeOfDay();
    
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 48, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good $timeOfDay,',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userName,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primaryGreen,
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildPerformanceIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceIndicator() {
    return Consumer<SaleProvider>(
      builder: (context, saleProvider, child) {
        final todayRevenue = saleProvider.todayRevenue;
        final yesterdayRevenue = saleProvider.yesterdayRevenue;
        final growthRate = yesterdayRevenue > 0 
            ? ((todayRevenue - yesterdayRevenue) / yesterdayRevenue * 100)
            : 0.0;
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                growthRate >= 0 ? Icons.trending_up : Icons.trending_down,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                '${growthRate >= 0 ? '+' : ''}${growthRate.toStringAsFixed(1)}% vs yesterday',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsCards() {
    return Consumer4<SaleProvider, MedicineProvider, CreditProvider, ExpenseProvider>(
      builder: (context, saleProvider, medicineProvider, creditProvider, expenseProvider, child) {
        final todayRevenue = saleProvider.todayRevenue;
        final totalProducts = medicineProvider.medicines.length;
        final expiringCount = medicineProvider.expiringMedicines.length;
        final pendingCredits = creditProvider.credits.where((c) => c.status == 'pending').length;
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _buildStatsCard(
                  'Today\'s Sales',
                  _formatCurrency(todayRevenue),
                  Icons.trending_up,
                  Colors.green,
                  () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatsCard(
                  'Total Products',
                  totalProducts.toString(),
                  Icons.inventory,
                  Colors.blue,
                  () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatsCard(
                  'Expiring Soon',
                  expiringCount.toString(),
                  Icons.event,
                  Colors.orange,
                  () {},
                  valueColor: expiringCount > 10 ? Colors.red : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatsCard(
                  'Pending Credits',
                  pendingCredits.toString(),
                  Icons.credit_card,
                  Colors.purple,
                  () {},
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsCard(String title, String value, IconData icon, Color color, VoidCallback onTap,
      {Color? valueColor}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: valueColor ?? AppColors.darkText,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesChartSection(DashboardProvider dashboardProvider) {
    final chartData = dashboardProvider.salesChartData;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sales Overview',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  DropdownButton<String>(
                    value: _selectedChartPeriod,
                    items: _periodOptions.entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                    onChanged: (value) async {
                      if (value != null) {
                        setState(() {
                          _selectedChartPeriod = value;
                        });
                        await dashboardProvider.fetchSalesChart(period: value);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (chartData != null && chartData.sales.isNotEmpty)
                SizedBox(
                  height: 250,
                  child: fl.LineChart(
                    fl.LineChartData(
                      gridData: fl.FlGridData(show: true),
                      titlesData: fl.FlTitlesData(
                        leftTitles: fl.AxisTitles(
                          sideTitles: fl.SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                'UGX${(value/1000).toStringAsFixed(0)}k',
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        bottomTitles: fl.AxisTitles(
                          sideTitles: fl.SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < chartData.labels.length) {
                                return Text(
                                  chartData.labels[index],
                                  style: const TextStyle(fontSize: 10),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        rightTitles: fl.AxisTitles(sideTitles: fl.SideTitles(showTitles: false)),
                        topTitles: fl.AxisTitles(sideTitles: fl.SideTitles(showTitles: false)),
                      ),
                      borderData: fl.FlBorderData(show: false),
                      lineBarsData: [
                        fl.LineChartBarData(
                          spots: chartData.sales.asMap().entries.map((e) => fl.FlSpot(e.key.toDouble(), e.value)).toList(),
                          isCurved: true,
                          color: AppColors.primaryGreen,
                          barWidth: 3,
                          dotData: fl.FlDotData(show: true),
                          belowBarData: fl.BarAreaData(
                            show: true,
                            color: AppColors.primaryGreen.withOpacity(0.1),
                          ),
                        ),
                      ],
                      lineTouchData: fl.LineTouchData(
                        touchTooltipData: fl.LineTouchTooltipData(
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              return fl.LineTooltipItem(
                                _formatCurrency(spot.y),
                                const TextStyle(color: Colors.white),
                              );
                            }).toList();
                          },
                        ),
                      ),
                    ),
                  ),
                )
              else
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildChartLegend('Sales', AppColors.primaryGreen),
                  if (chartData != null)
                    Text(
                      'Total: ${_formatCurrency(chartData.totalRevenue)}',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  'New Sale',
                  Icons.add_shopping_cart,
                  Colors.green,
                  () {
                    Navigator.pushNamed(context, '/new-sale');
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  'Add Product',
                  Icons.add_box,
                  Colors.blue,
                  () {
                    Navigator.pushNamed(context, '/add-medicine');
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  'Stock Check',
                  Icons.inventory,
                  Colors.orange,
                  () {
                    Navigator.pushNamed(context, '/medicines');
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  'Reports',
                  Icons.assessment,
                  Colors.purple,
                  () {
                    Navigator.pushNamed(context, '/reports');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingPrescriptionsSection(PrescriptionProvider provider) {
    final pendingPrescriptions = provider.prescriptions
        .where((p) => p.status == 'pending')
        .take(3)
        .toList();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pending Prescriptions',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/prescriptions');
                },
                child: Text(
                  '${provider.prescriptions.where((p) => p.status == 'pending').length} Pending',
                  style: GoogleFonts.poppins(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (pendingPrescriptions.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  'No pending prescriptions',
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            )
          else
            ...pendingPrescriptions.map((prescription) => 
              _buildPrescriptionCard(prescription, context),
            ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionCard(Prescription prescription, BuildContext context) {
    final isUrgent = prescription.notes.toLowerCase().contains('urgent');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: isUrgent ? Colors.red : AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${prescription.prescriptionNumber} - ${prescription.items.first.productName}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Patient: ${prescription.patientName} • Dr. ${prescription.doctorName}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isUrgent ? Colors.red.shade50 : AppColors.veryLightGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isUrgent ? 'Critical' : 'Standard',
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isUrgent ? Colors.red : AppColors.primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryAlertsSection(MedicineProvider provider) {
    final expiringMedicines = provider.expiringMedicines.take(4).toList();
    final lowStockMedicines = provider.lowStockMedicines.take(4).toList();
    
    if (expiringMedicines.isEmpty && lowStockMedicines.isEmpty) {
      return const SizedBox();
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Inventory Alerts',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 12),
          if (lowStockMedicines.isNotEmpty)
            Column(
              children: [
                _buildAlertCard(
                  title: 'Low Stock Alert',
                  count: provider.lowStockMedicines.length,
                  items: lowStockMedicines,
                  icon: Icons.warning,
                  color: Colors.orange,
                  route: '/medicines',
                ),
                const SizedBox(height: 12),
              ],
            ),
          if (expiringMedicines.isNotEmpty)
            _buildAlertCard(
              title: 'Expiring Soon',
              count: provider.expiringMedicines.length,
              items: expiringMedicines,
              icon: Icons.hourglass_empty,
              color: Colors.red,
              route: '/medicines',
            ),
        ],
      ),
    );
  }

  Widget _buildAlertCard({
    required String title,
    required int count,
    required List items,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$title: $count items need attention',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, route);
                },
                child: Text(
                  'View All',
                  style: GoogleFonts.poppins(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (items.isNotEmpty)
            const SizedBox(height: 8),
          if (items.isNotEmpty)
            ...items.take(2).map((item) => Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Text(
                    '• ${item.name}',
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                  const Spacer(),
                  Text(
                    'Stock: ${item.quantity}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                ],
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildPaymentStatusSection(CreditProvider creditProvider) {
    final credits = creditProvider.credits;
    final totalPending = credits.where((c) => c.status == 'pending').fold<double>(0, (sum, c) => sum + c.amount);
    final totalOverdue = credits.where((c) => c.status == 'overdue').fold<double>(0, (sum, c) => sum + c.amount);
    
    if (totalPending == 0 && totalOverdue == 0) {
      return const SizedBox();
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payment Status',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildPaymentStatusCard(
                      'Pending Payments',
                      _formatCurrency(totalPending),
                      Icons.pending,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPaymentStatusCard(
                      'Overdue Payments',
                      _formatCurrency(totalOverdue),
                      Icons.warning,
                      Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentStatusCard(String title, String amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            amount,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegend(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 12),
        ),
      ],
    );
  }

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      symbol: 'UGX ',
      decimalDigits: 0,
    ).format(amount);
  }
}

// Placeholder for MedicineListScreen
class MedicineListScreen extends StatelessWidget {
  const MedicineListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Medicines Screen')),
    );
  }
}