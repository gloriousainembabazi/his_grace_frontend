// lib/screens/dashboard/admin_dashboard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/sale_provider.dart';
import '../../providers/expense_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/notification_bell.dart';
import '../expense/expense_list_screen.dart';
import '../staff/staff_list_screen.dart';
import '../reports/report_dashboard.dart';
import '../../models/user.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const AdminHomeScreen(),
    const ExpenseListScreen(),
    const StaffListScreen(),
    const ReportDashboard(),
  ];

  final List<String> _titles = [
    'Admin Dashboard',
    'Expenses',
    'Staff Management',
    'Reports',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          const NotificationBell(),
          if (_selectedIndex == 1)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => Navigator.pushNamed(context, '/create-expense'),
            ),
          if (_selectedIndex == 2)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => Navigator.pushNamed(context, '/create-staff'),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshDashboard(),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  Navigator.pushNamed(context, '/profile');
                  break;
                case 'settings':
                  Navigator.pushNamed(context, '/settings');
                  break;
                case 'backup':
                  Navigator.pushNamed(context, '/backup');
                  break;
                case 'logout':
                  _logout(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'profile', child: Row(children: [Icon(Icons.person_outline, size: 20), SizedBox(width: 8), Text('Profile')])),
              const PopupMenuItem(value: 'settings', child: Row(children: [Icon(Icons.settings_outlined, size: 20), SizedBox(width: 8), Text('Settings')])),
              const PopupMenuItem(value: 'backup', child: Row(children: [Icon(Icons.backup_outlined, size: 20), SizedBox(width: 8), Text('Backup')])),
              const PopupMenuItem(value: 'logout', child: Row(children: [Icon(Icons.logout, size: 20, color: Colors.red), SizedBox(width: 8), Text('Logout', style: TextStyle(color: Colors.red))])),
            ],
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.money_off_outlined), label: 'Expenses'),
          NavigationDestination(icon: Icon(Icons.people_outlined), label: 'Staff'),
          NavigationDestination(icon: Icon(Icons.assessment_outlined), label: 'Reports'),
        ],
      ),
    );
  }

  Future<void> _refreshDashboard() async {
    final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
    final saleProvider = Provider.of<SaleProvider>(context, listen: false);
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    
    await Future.wait([
      dashboardProvider.loadDashboard(),
      saleProvider.loadSales(),
      expenseProvider.loadExpenses(),
    ]);
  }

  void _logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
}

// Admin Home Screen - Must be StatefulWidget to access context properly
class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final saleProvider = Provider.of<SaleProvider>(context);
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    
    final totalRevenue = saleProvider.totalRevenue;
    final totalExpenses = expenseProvider.totalExpenses;
    final netProfit = totalRevenue - totalExpenses;
    final profitMargin = totalRevenue > 0 ? (netProfit / totalRevenue) * 100 : 0.0;
    
    return RefreshIndicator(
      onRefresh: () async {
        await dashboardProvider.loadDashboard();
        await saleProvider.loadSales();
        await expenseProvider.loadExpenses();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(user),
            const SizedBox(height: 20),
            _buildFinancialCards(totalRevenue, totalExpenses, netProfit, profitMargin),
            const SizedBox(height: 20),
            _buildInventoryStats(dashboardProvider),
            const SizedBox(height: 20),
            if (dashboardProvider.getInventoryByCategory().isNotEmpty)
              _buildCategoryChart(dashboardProvider),
            const SizedBox(height: 20),
            _buildRecentInventory(dashboardProvider),
            const SizedBox(height: 20),
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(User? user) {
    final hour = DateTime.now().hour;
    String greeting = 'Morning';
    if (hour >= 12 && hour < 17) greeting = 'Afternoon';
    if (hour >= 17) greeting = 'Evening';
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryGreen, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Good $greeting,', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70)),
          const SizedBox(height: 4),
          Text(user?.fullName ?? 'Administrator', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoChip(Icons.calendar_today, DateFormat('EEEE, MMM d').format(DateTime.now())),
              const SizedBox(width: 8),
              _buildInfoChip(Icons.access_time, DateFormat('hh:mm a').format(DateTime.now())),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildFinancialCards(double revenue, double expenses, double profit, double margin) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _buildFinancialCard('Revenue', _formatCurrency(revenue), Icons.trending_up, Colors.green),
        _buildFinancialCard('Expenses', _formatCurrency(expenses), Icons.trending_down, Colors.red),
        _buildFinancialCard('Net Profit', _formatCurrency(profit), Icons.account_balance, profit >= 0 ? Colors.blue : Colors.red),
        _buildFinancialCard('Profit Margin', '${margin.toStringAsFixed(1)}%', Icons.pie_chart, Colors.orange),
      ],
    );
  }

  Widget _buildFinancialCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 24),
            ),
            Text(value, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText)),
            Text(title, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryStats(DashboardProvider provider) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _buildInventoryCard('Total Items', '${provider.getTotalInventoryItems()}', Icons.inventory, Colors.blue),
        _buildInventoryCard('Inventory Value', _formatCurrency(provider.getTotalInventoryValue()), Icons.attach_money, Colors.green),
        _buildInventoryCard('Low Stock', '${provider.getLowStockCount()}', Icons.warning, Colors.orange, isWarning: provider.getLowStockCount() > 5),
        _buildInventoryCard('Expiring Soon', '${provider.getExpiringCount()}', Icons.event, Colors.red, isWarning: provider.getExpiringCount() > 3),
      ],
    );
  }

  Widget _buildInventoryCard(String title, String value, IconData icon, Color color, {bool isWarning = false}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: isWarning ? Border.all(color: Colors.red, width: 1) : null),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 20)),
                if (isWarning) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Text('Alert!', style: GoogleFonts.poppins(fontSize: 10, color: Colors.red))),
              ],
            ),
            Text(value, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: isWarning ? Colors.red : AppColors.darkText)),
            Text(title, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChart(DashboardProvider provider) {
    final categoryData = provider.getInventoryByCategory();
    final List<MapEntry<String, int>> sortedEntries = categoryData.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Inventory by Category', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
            const SizedBox(height: 8),
            Text('Distribution across ${categoryData.keys.length} categories', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 20),
            ...sortedEntries.map((entry) {
              final percentage = (entry.value / provider.getTotalInventoryItems()) * 100;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                        Text('${entry.value} items (${percentage.toStringAsFixed(1)}%)', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(value: percentage / 100, backgroundColor: Colors.grey[200], color: AppColors.primaryGreen, minHeight: 6),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentInventory(DashboardProvider provider) {
    if (provider.inventoryItems.isEmpty) return const SizedBox();
    
    return Card(
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
                Text('Recent Items', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                TextButton(onPressed: () => Navigator.pushNamed(context, '/medicines'), child: const Text('View All')),
              ],
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.inventoryItems.length > 5 ? 5 : provider.inventoryItems.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final item = provider.inventoryItems[index];
                final price = item['price'] is String ? double.tryParse(item['price']) ?? 0 : (item['price'] ?? 0).toDouble();
                final quantity = item['quantity'] ?? 0;
                final isLowStock = quantity <= (item['min_stock_level'] ?? 10);
                
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: AppColors.veryLightGreen,
                    child: Text(item['name'][0].toUpperCase(), style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(item['name'], style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                  subtitle: Text(item['category_name'] ?? 'No category', style: GoogleFonts.poppins(fontSize: 11)),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_formatCurrency(price), style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('Stock: $quantity', style: GoogleFonts.poppins(fontSize: 11, color: isLowStock ? Colors.red : Colors.grey[600])),
                      if (isLowStock) Container(margin: const EdgeInsets.only(top: 2), padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(4)), child: Text('Low Stock', style: GoogleFonts.poppins(fontSize: 9, color: Colors.red))),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildActionButton('Add Medicine', Icons.add_box, Colors.blue, () => Navigator.pushNamed(context, '/add-medicine')),
            _buildActionButton('Add Expense', Icons.money_off, Colors.red, () => Navigator.pushNamed(context, '/create-expense')),
            _buildActionButton('Add Staff', Icons.person_add, Colors.green, () => Navigator.pushNamed(context, '/create-staff')),
            _buildActionButton('View Inventory', Icons.inventory, Colors.purple, () => Navigator.pushNamed(context, '/medicines')),
            _buildActionButton('Generate Report', Icons.assessment, Colors.orange, () => Navigator.pushNamed(context, '/reports')),
            _buildActionButton('Backup Data', Icons.backup, Colors.teal, () => Navigator.pushNamed(context, '/backup')),
          ],
        ),
      ],
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
              Text(label, style: GoogleFonts.poppins(color: color, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(symbol: 'UGX ', decimalDigits: 0).format(amount);
  }
}