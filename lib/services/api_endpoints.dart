class ApiEndpoints {
  // Auth
  static const login = '/auth/login/';
  static const logout = '/auth/logout/';

  // Dashboard
  static const dashboard = '/dashboard/';
  static const dashboardSummary = '/reports/dashboard/';

  // Medicines
  static const medicines = '/medicines/';
  static const lowStockMedicines = '/medicines/low-stock/';
  static const expiringMedicines = '/medicines/expiring/';
  static const expiredMedicines = '/medicines/expired/';

  // Categories
  static const categories = '/categories/';

  // Suppliers
  static const suppliers = '/suppliers/';

  // Sales
  static const sales = '/sales/';
  static const dailySales = '/sales/daily/';
  static const salesReport = '/sales/report/';

  // Expenses
  static const expenses = '/expenses/';

  // Prescriptions
  static const prescriptions = '/prescriptions/';
  static const prescriptionUpload = '/prescriptions/upload/';

  // Stock
  static const stockTakes = '/stock-takes/';

  // Reports
  static const inventoryReport = '/reports/inventory/';
  static const staffReport = '/reports/staff/';
  static const dailySalesReport = '/reports/daily-sales/';
  static const lowStockReport = '/reports/low-stock/';
  static const expiredReport = '/reports/expired/';
}