// lib/screens/dashboard/worker_dashboard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/medicine_provider.dart';
import '../../providers/sale_provider.dart';
import '../../providers/prescription_provider.dart';
import '../../utils/constants.dart';

class WorkerDashboard extends StatefulWidget {
  const WorkerDashboard({super.key});

  @override
  State<WorkerDashboard> createState() => _WorkerDashboardState();
}

class _WorkerDashboardState extends State<WorkerDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const WorkerHomeScreen(),
    const Center(child: Text('Sales Screen - Coming Soon')),
    const Center(child: Text('Prescriptions Screen - Coming Soon')),
    const Center(child: Text('Medicines Screen - Coming Soon')),
  ];

  final List<String> _titles = [
    'Dashboard',
    'Sales',
    'Prescriptions',
    'Medicines',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          if (_selectedIndex == 1)
            IconButton(
              icon: const Icon(Icons.add_shopping_cart),
              onPressed: () {
                Navigator.pushNamed(context, '/new-sale');
              },
            ),
          if (_selectedIndex == 2)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.pushNamed(context, '/create-prescription');
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
                _logout(context);
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: 'Sales',
          ),
          NavigationDestination(
            icon: Icon(Icons.medical_information_outlined),
            selectedIcon: Icon(Icons.medical_information),
            label: 'Prescriptions',
          ),
          NavigationDestination(
            icon: Icon(Icons.medical_services_outlined),
            selectedIcon: Icon(Icons.medical_services),
            label: 'Medicines',
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
}

// Worker Home Screen
class WorkerHomeScreen extends StatelessWidget {
  const WorkerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    
    return RefreshIndicator(
      onRefresh: () async {
        final medicineProvider = Provider.of<MedicineProvider>(context, listen: false);
        final saleProvider = Provider.of<SaleProvider>(context, listen: false);
        final prescriptionProvider = Provider.of<PrescriptionProvider>(context, listen: false);
        
        await Future.wait([
          medicineProvider.loadMedicines(),
          saleProvider.loadSales(),
          prescriptionProvider.loadPrescriptions(),
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
              user?.fullName ?? user?.username ?? 'Staff',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 24),

            // Stats Cards
            Consumer3<MedicineProvider, SaleProvider, PrescriptionProvider>(
              builder: (context, medicineProvider, saleProvider, prescriptionProvider, child) {
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    _buildStatCard(
                      'Today\'s Sales',
                      _formatCurrency(saleProvider.todayRevenue),
                      Icons.today,
                      Colors.green,
                      () => Navigator.pushNamed(context, '/sales'),
                    ),
                    _buildStatCard(
                      'Total Medicines',
                      '${medicineProvider.medicines.length}',
                      Icons.medical_services,
                      Colors.blue,
                      () => Navigator.pushNamed(context, '/medicines'),
                    ),
                    _buildStatCard(
                      'Pending Rx',
                      '${prescriptionProvider.prescriptions.where((p) => p.status == 'pending').length}',
                      Icons.medical_information,
                      Colors.orange,
                      () => Navigator.pushNamed(context, '/prescriptions'),
                    ),
                    _buildStatCard(
                      'Low Stock Alert',
                      '${medicineProvider.lowStockMedicines.length}',
                      Icons.warning,
                      Colors.red,
                      () => Navigator.pushNamed(context, '/medicines'),
                    ),
                  ],
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
                _buildActionButton(
                  'New Sale',
                  Icons.add_shopping_cart,
                  Colors.green,
                  () => Navigator.pushNamed(context, '/new-sale'),
                ),
                _buildActionButton(
                  'New Prescription',
                  Icons.medical_information,
                  Colors.blue,
                  () => Navigator.pushNamed(context, '/create-prescription'),
                ),
                _buildActionButton(
                  'Check Stock',
                  Icons.inventory,
                  Colors.orange,
                  () => Navigator.pushNamed(context, '/medicines'),
                ),
                _buildActionButton(
                  'View Medicines',
                  Icons.medical_services,
                  Colors.purple,
                  () => Navigator.pushNamed(context, '/medicines'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
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

  String _formatCurrency(double amount) {
    return 'UGX ${amount.toStringAsFixed(0)}';
  }
}