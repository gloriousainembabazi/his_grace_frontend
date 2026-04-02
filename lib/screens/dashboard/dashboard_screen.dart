import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/medicine_provider.dart';
import '../../providers/sale_provider.dart';
import '../../providers/prescription_provider.dart';
import '../../providers/credit_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/stock_provider.dart';
import '../../models/sale.dart';
import '../../widgets/sales_chart.dart';
import '../../utils/constants.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardHome(),
    const Center(child: Text('Medicines Screen - Use navigation')),
    const Center(child: Text('Sales Screen - Use navigation')),
    const Center(child: Text('Prescriptions Screen - Use navigation')),
    const Center(child: Text('Credits Screen - Use navigation')),
    const Center(child: Text('Expenses Screen - Use navigation')),
    const Center(child: Text('Stock Take Screen - Use navigation')),
    const Center(child: Text('Reports Screen - Use navigation')),
  ];

  final List<String> _titles = [
    'Dashboard',
    'Medicines',
    'Sales',
    'Prescriptions',
    'Credits',
    'Expenses',
    'Stock Take',
    'Reports',
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final medicineProvider = Provider.of<MedicineProvider>(context, listen: false);
    final saleProvider = Provider.of<SaleProvider>(context, listen: false);
    final prescriptionProvider = Provider.of<PrescriptionProvider>(context, listen: false);
    final creditProvider = Provider.of<CreditProvider>(context, listen: false);
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    final stockProvider = Provider.of<StockProvider>(context, listen: false);
    
    await Future.wait([
      medicineProvider.loadLowStockMedicines(),
      medicineProvider.loadExpiringMedicines(),
      saleProvider.loadDailySales(),
      saleProvider.loadSales(),
      prescriptionProvider.loadPrescriptions(),
      creditProvider.loadCredits(),
      expenseProvider.loadExpenses(),
      stockProvider.loadStockTakes(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.currentUser?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          if (_selectedIndex == 0)
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    _showNotifications(context);
                  },
                ),
                Consumer4<MedicineProvider, PrescriptionProvider, CreditProvider, StockProvider>(
                  builder: (context, medicineProvider, prescriptionProvider, creditProvider, stockProvider, child) {
                    final totalAlerts = medicineProvider.lowStockMedicines.length + 
                                       medicineProvider.expiringMedicines.length +
                                       prescriptionProvider.prescriptions.where((p) => p.status == 'pending').length +
                                       creditProvider.credits.where((c) => c.status == 'overdue').length;
                    
                    if (totalAlerts > 0) {
                      return Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$totalAlerts',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          
          if (_selectedIndex == 2)
            IconButton(
              icon: const Icon(Icons.add_shopping_cart),
              onPressed: () {
                Navigator.pushNamed(context, '/new-sale');
              },
            ),
          
          if (_selectedIndex == 3)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.pushNamed(context, '/create-prescription');
              },
            ),
          
          if (_selectedIndex == 4)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.pushNamed(context, '/create-credit');
              },
            ),
          
          if (_selectedIndex == 5)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.pushNamed(context, '/create-expense');
              },
            ),
          
          if (_selectedIndex == 6)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.pushNamed(context, '/create-stock-take');
              },
            ),
          
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'profile') {
                Navigator.pushNamed(context, '/profile');
              } else if (value == 'settings') {
                Navigator.pushNamed(context, '/settings');
              } else if (value == 'logout') {
                _showLogoutDialog();
              } else if (value == 'staff' && isAdmin) {
                Navigator.pushNamed(context, '/staff');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline, size: 20),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined, size: 20),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
              if (isAdmin)
                const PopupMenuItem(
                  value: 'staff',
                  child: Row(
                    children: [
                      Icon(Icons.people_outline, size: 20),
                      SizedBox(width: 8),
                      Text('Staff Management'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppConstants.primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          switch(index) {
            case 0:
              setState(() {
                _selectedIndex = index;
              });
              break;
            case 1:
              Navigator.pushNamed(context, '/medicines').then((_) {
                setState(() {
                  _selectedIndex = 1;
                });
              });
              break;
            case 2:
              Navigator.pushNamed(context, '/sales').then((_) {
                setState(() {
                  _selectedIndex = 2;
                });
              });
              break;
            case 3:
              Navigator.pushNamed(context, '/prescriptions').then((_) {
                setState(() {
                  _selectedIndex = 3;
                });
              });
              break;
            case 4:
              Navigator.pushNamed(context, '/credits').then((_) {
                setState(() {
                  _selectedIndex = 4;
                });
              });
              break;
            case 5:
              Navigator.pushNamed(context, '/expenses').then((_) {
                setState(() {
                  _selectedIndex = 5;
                });
              });
              break;
            case 6:
              Navigator.pushNamed(context, '/stock-takes').then((_) {
                setState(() {
                  _selectedIndex = 6;
                });
              });
              break;
            case 7:
              Navigator.pushNamed(context, '/reports').then((_) {
                setState(() {
                  _selectedIndex = 7;
                });
              });
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services_outlined),
            activeIcon: Icon(Icons.medical_services),
            label: 'Medicines',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Sales',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_information_outlined),
            activeIcon: Icon(Icons.medical_information),
            label: 'Prescriptions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card_outlined),
            activeIcon: Icon(Icons.credit_card),
            label: 'Credits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.money_off_outlined),
            activeIcon: Icon(Icons.money_off),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_outlined),
            activeIcon: Icon(Icons.inventory),
            label: 'Stock Take',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment_outlined),
            activeIcon: Icon(Icons.assessment),
            label: 'Reports',
          ),
        ],
      ),
      
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/add-medicine');
              },
              backgroundColor: AppConstants.primaryColor,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Future<void> _showLogoutDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: Provider.of<MedicineProvider>(context, listen: false)),
            ChangeNotifierProvider.value(value: Provider.of<PrescriptionProvider>(context, listen: false)),
            ChangeNotifierProvider.value(value: Provider.of<CreditProvider>(context, listen: false)),
          ],
          child: Consumer3<MedicineProvider, PrescriptionProvider, CreditProvider>(
            builder: (context, medicineProvider, prescriptionProvider, creditProvider, child) {
              final pendingPrescriptions = prescriptionProvider.prescriptions.where((p) => p.status == 'pending').length;
              final overdueCredits = creditProvider.credits.where((c) => c.status == 'overdue').length;
              
              return Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Notifications',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (medicineProvider.lowStockMedicines.isEmpty &&
                        medicineProvider.expiringMedicines.isEmpty &&
                        pendingPrescriptions == 0 &&
                        overdueCredits == 0)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text('No notifications'),
                        ),
                      ),
                    if (medicineProvider.lowStockMedicines.isNotEmpty) ...[
                      Text(
                        'Low Stock Alert',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          color: Colors.orange,
                        ),
                      ),
                      ...medicineProvider.lowStockMedicines.take(3).map(
                        (medicine) => ListTile(
                          leading: const Icon(Icons.warning, color: Colors.orange),
                          title: Text(medicine.name),
                          subtitle: Text('Stock: ${medicine.quantity}'),
                          dense: true,
                        ),
                      ),
                      if (medicineProvider.lowStockMedicines.length > 3)
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(
                            '+${medicineProvider.lowStockMedicines.length - 3} more',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                    ],
                    if (medicineProvider.expiringMedicines.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Expiring Soon',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          color: Colors.red,
                        ),
                      ),
                      ...medicineProvider.expiringMedicines.take(3).map(
                        (medicine) => ListTile(
                          leading: const Icon(Icons.event, color: Colors.red),
                          title: Text(medicine.name),
                          subtitle: Text(
                            'Expires: ${medicine.expiryDate.day}/${medicine.expiryDate.month}/${medicine.expiryDate.year}',
                          ),
                          dense: true,
                        ),
                      ),
                      if (medicineProvider.expiringMedicines.length > 3)
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(
                            '+${medicineProvider.expiringMedicines.length - 3} more',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                    ],
                    if (pendingPrescriptions > 0) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Pending Prescriptions',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          color: Colors.blue,
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.medical_services, color: Colors.blue),
                        title: const Text('Prescriptions waiting to be dispensed'),
                        subtitle: Text('$pendingPrescriptions pending'),
                        dense: true,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/prescriptions');
                        },
                      ),
                    ],
                    if (overdueCredits > 0) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Overdue Credits',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          color: Colors.red,
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.warning, color: Colors.red),
                        title: const Text('Credits past due date'),
                        subtitle: Text('$overdueCredits overdue'),
                        dense: true,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/credits');
                        },
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// Dashboard Home Widget
class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  List<Map<String, dynamic>> _prepareHourlyChartData(List<Sale> sales) {
    if (sales.isEmpty) {
      return [
        {'label': '8am', 'value': 0},
        {'label': '10am', 'value': 0},
        {'label': '12pm', 'value': 0},
        {'label': '2pm', 'value': 0},
        {'label': '4pm', 'value': 0},
        {'label': '6pm', 'value': 0},
      ];
    }
    
    Map<int, double> hourlyTotals = {};
    for (var sale in sales) {
      final hour = sale.saleDate.hour;
      hourlyTotals[hour] = (hourlyTotals[hour] ?? 0) + sale.totalPrice;
    }
    
    final sortedHours = hourlyTotals.keys.toList()..sort();
    
    return sortedHours.map((hour) {
      final period = hour < 12 ? '${hour}am' : hour == 12 ? '12pm' : '${hour - 12}pm';
      return {
        'label': period,
        'value': hourlyTotals[hour]?.round() ?? 0,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return RefreshIndicator(
      onRefresh: () async {
        final medicineProvider = Provider.of<MedicineProvider>(context, listen: false);
        final saleProvider = Provider.of<SaleProvider>(context, listen: false);
        final prescriptionProvider = Provider.of<PrescriptionProvider>(context, listen: false);
        final creditProvider = Provider.of<CreditProvider>(context, listen: false);
        final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
        final stockProvider = Provider.of<StockProvider>(context, listen: false);
        
        await Future.wait([
          medicineProvider.loadLowStockMedicines(),
          medicineProvider.loadExpiringMedicines(),
          saleProvider.loadDailySales(),
          saleProvider.loadSales(refresh: true),
          prescriptionProvider.loadPrescriptions(),
          creditProvider.loadCredits(),
          expenseProvider.loadExpenses(),
          stockProvider.loadStockTakes(),
        ]);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Message
            Text(
              'Welcome back,',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            Text(
              user?.fullName ?? 'User',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 24),

            // Stats Cards
            Consumer5<MedicineProvider, SaleProvider, PrescriptionProvider, CreditProvider, ExpenseProvider>(
              builder: (context, medicineProvider, saleProvider, prescriptionProvider, creditProvider, expenseProvider, child) {
                final pendingPrescriptions = prescriptionProvider.prescriptions.where((p) => p.status == 'pending').length;
                final overdueCredits = creditProvider.credits.where((c) => c.status == 'overdue').length;
                final totalExpenses = expenseProvider.getTotalExpenses();
                
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    _buildStatCard(
                      'Total Medicines',
                      '${medicineProvider.medicines.length}',
                      Icons.medical_services,
                      Colors.blue,
                    ),
                    _buildStatCard(
                      'Low Stock',
                      '${medicineProvider.lowStockMedicines.length}',
                      Icons.warning,
                      Colors.orange,
                    ),
                    _buildStatCard(
                      'Today\'s Sales',
                      'UGX ${saleProvider.dailyTotal.toStringAsFixed(0)}',
                      Icons.today,
                      Colors.green,
                    ),
                    _buildStatCard(
                      'Pending Rx',
                      '$pendingPrescriptions',
                      Icons.medical_information,
                      Colors.purple,
                    ),
                    _buildStatCard(
                      'Overdue Credits',
                      '$overdueCredits',
                      Icons.warning_amber,
                      Colors.red,
                    ),
                    _buildStatCard(
                      'Total Expenses',
                      'UGX ${totalExpenses.toStringAsFixed(0)}',
                      Icons.money_off,
                      Colors.deepOrange,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Sales Chart Section
            Consumer<SaleProvider>(
              builder: (context, saleProvider, child) {
                final hourlyChartData = _prepareHourlyChartData(saleProvider.dailySales);

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sales Overview',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: SalesChart(
                            salesData: hourlyChartData,
                            chartType: 'daily',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Quick Actions
            Text(
              'Quick Actions',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildQuickActionButton(
                  'New Sale',
                  Icons.add_shopping_cart,
                  Colors.green,
                  () {
                    Navigator.pushNamed(context, '/new-sale');
                  },
                ),
                _buildQuickActionButton(
                  'New Prescription',
                  Icons.medical_information,
                  Colors.blue,
                  () {
                    Navigator.pushNamed(context, '/create-prescription');
                  },
                ),
                _buildQuickActionButton(
                  'New Credit',
                  Icons.credit_card,
                  Colors.orange,
                  () {
                    Navigator.pushNamed(context, '/create-credit');
                  },
                ),
                _buildQuickActionButton(
                  'Add Expense',
                  Icons.money_off,
                  Colors.red,
                  () {
                    Navigator.pushNamed(context, '/create-expense');
                  },
                ),
                _buildQuickActionButton(
                  'Stock Take',
                  Icons.inventory,
                  Colors.purple,
                  () {
                    Navigator.pushNamed(context, '/create-stock-take');
                  },
                ),
                _buildQuickActionButton(
                  'View Reports',
                  Icons.assessment,
                  Colors.teal,
                  () {
                    Navigator.pushNamed(context, '/reports');
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Alerts Section
            Consumer5<MedicineProvider, PrescriptionProvider, CreditProvider, StockProvider, ExpenseProvider>(
              builder: (context, medicineProvider, prescriptionProvider, creditProvider, stockProvider, expenseProvider, child) {
                final pendingPrescriptions = prescriptionProvider.prescriptions.where((p) => p.status == 'pending').length;
                final overdueCredits = creditProvider.credits.where((c) => c.status == 'overdue').length;
                final pendingStockTakes = stockProvider.stockTakes.where((s) => s.status == 'in_progress' || s.status == 'draft').length;
                
                if (medicineProvider.lowStockMedicines.isEmpty &&
                    medicineProvider.expiringMedicines.isEmpty &&
                    pendingPrescriptions == 0 &&
                    overdueCredits == 0 &&
                    pendingStockTakes == 0) {
                  return const SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alerts',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (medicineProvider.lowStockMedicines.isNotEmpty)
                      _buildAlertCard(
                        'Low Stock Alert',
                        '${medicineProvider.lowStockMedicines.length} medicines need reordering',
                        Icons.warning,
                        Colors.orange,
                        () {
                          Navigator.pushNamed(context, '/medicines');
                        },
                      ),
                    if (medicineProvider.expiringMedicines.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildAlertCard(
                        'Expiring Soon',
                        '${medicineProvider.expiringMedicines.length} medicines will expire within 30 days',
                        Icons.event,
                        Colors.red,
                        () {
                          Navigator.pushNamed(context, '/medicines');
                        },
                      ),
                    ],
                    if (pendingPrescriptions > 0) ...[
                      const SizedBox(height: 8),
                      _buildAlertCard(
                        'Pending Prescriptions',
                        '$pendingPrescriptions prescriptions waiting to be dispensed',
                        Icons.medical_information,
                        Colors.blue,
                        () {
                          Navigator.pushNamed(context, '/prescriptions');
                        },
                      ),
                    ],
                    if (overdueCredits > 0) ...[
                      const SizedBox(height: 8),
                      _buildAlertCard(
                        'Overdue Credits',
                        '$overdueCredits credits past due date',
                        Icons.warning_amber,
                        Colors.red,
                        () {
                          Navigator.pushNamed(context, '/credits');
                        },
                      ),
                    ],
                    if (pendingStockTakes > 0) ...[
                      const SizedBox(height: 8),
                      _buildAlertCard(
                        'Pending Stock Takes',
                        '$pendingStockTakes stock takes in progress',
                        Icons.inventory,
                        Colors.orange,
                        () {
                          Navigator.pushNamed(context, '/stock-takes');
                        },
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 32),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      color: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: color),
        onTap: onTap,
      ),
    );
  }
}