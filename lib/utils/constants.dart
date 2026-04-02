// lib/utils/constants.dart

import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Your Green (#76BE53)
  static const Color primaryGreen = Color(0xFF76BE53);
  static const Color primaryLight = Color(0xFFE8F5E0);
  static const Color primaryDark = Color(0xFF4A7A34);
  static const Color veryLightGreen = Color(0xFFF1F8E9);
  
  // Accent Colors
  static const Color accentBlue = Color(0xFF2196F3);
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color accentRed = Color(0xFFF44336);
  static const Color accentPurple = Color(0xFF9C27B0);
  static const Color accentTeal = Color(0xFF009688);
  
  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color darkText = Color(0xFF2C3E50);
  static const Color mediumText = Color(0xFF5D6D7E);
  static const Color lightText = Color(0xFF7F8C8D);
  static const Color darkGrey = Color(0xFF616161);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color dividerColor = Color(0xFFECF0F1);
  
  // Status Colors
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);
  static const Color pending = Color(0xFFFFA500);
  static const Color partial = Color(0xFF9B59B6);
  static const Color overdue = Color(0xFFE74C3C);
  
  // Gradient
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF76BE53),
      Color(0xFF8BC34A),
    ],
  );
  
  static const Gradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFF8FAFC),
    ],
  );
}

class AppStrings {
  static const String appName = 'His Grace Drugshop';
  static const String fullName = 'His Grace Drugshop Management System';
  static const String tagline = 'Your Trusted Pharmacy Partner';
  static const String welcome = 'Welcome to His Grace Drugshop';
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String warning = 'Warning';
  static const String info = 'Info';
  
  // Navigation
  static const String dashboard = 'Dashboard';
  static const String medicines = 'Medicines';
  static const String sales = 'Sales';
  static const String prescriptions = 'Prescriptions';
  static const String credits = 'Credits';
  static const String expenses = 'Expenses';
  static const String stockTake = 'Stock Take';
  static const String reports = 'Reports';
  static const String profile = 'Profile';
  static const String settings = 'Settings';
  
  // Actions
  static const String add = 'Add';
  static const String edit = 'Edit';
  static const String delete = 'Delete';
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String search = 'Search';
  static const String filter = 'Filter';
  static const String refresh = 'Refresh';
  static const String print = 'Print';
  static const String export = 'Export';
  static const String share = 'Share';
  static const String clear = 'Clear';
  static const String submit = 'Submit';
  static const String update = 'Update';
  static const String create = 'Create';
  static const String view = 'View';
  static const String details = 'Details';
  
  // Prescription Strings
  static const String newPrescription = 'New Prescription';
  static const String prescriptionNumber = 'Prescription Number';
  static const String patientName = 'Patient Name';
  static const String patientPhone = 'Patient Phone';
  static const String patientAddress = 'Patient Address';
  static const String doctorName = 'Doctor Name';
  static const String prescriptionDate = 'Prescription Date';
  static const String prescriptionItems = 'Prescription Items';
  static const String dispense = 'Dispense';
  static const String dispensed = 'Dispensed';
  static const String pending = 'Pending';
  static const String cancelled = 'Cancelled';
  static const String dosage = 'Dosage';
  static const String frequency = 'Frequency';
  static const String duration = 'Duration';
  static const String instructions = 'Instructions';
  
  // Credit Strings
  static const String newCredit = 'New Credit';
  static const String creditNumber = 'Credit Number';
  static const String creditType = 'Credit Type';
  static const String customer = 'Customer';
  static const String supplier = 'Supplier';
  static const String customerName = 'Customer Name';
  static const String supplierName = 'Supplier Name';
  static const String creditAmount = 'Credit Amount';
  static const String paidAmount = 'Paid Amount';
  static const String balance = 'Balance';
  static const String dueDate = 'Due Date';
  static const String paymentDate = 'Payment Date';
  static const String paymentMethod = 'Payment Method';
  static const String addPayment = 'Add Payment';
  static const String paymentHistory = 'Payment History';
  static const String overdue = 'Overdue';
  static const String partial = 'Partially Paid';
  static const String paid = 'Paid';
  static const String outstanding = 'Outstanding';
  
  // Expense Strings
  static const String newExpense = 'New Expense';
  static const String expenseNumber = 'Expense Number';
  static const String expenseCategory = 'Expense Category';
  static const String expenseDescription = 'Description';
  static const String expenseAmount = 'Amount';
  static const String expenseDate = 'Expense Date';
  static const String receiptNumber = 'Receipt Number';
  static const String vendorName = 'Vendor Name';
  static const String category = 'Category';
  
  // Expense Categories
  static const String rent = 'Rent';
  static const String utilities = 'Utilities';
  static const String salary = 'Salary';
  static const String maintenance = 'Maintenance';
  static const String supplies = 'Supplies';
  static const String transport = 'Transport';
  static const String marketing = 'Marketing';
  static const String other = 'Other';
  
  // Stock Take Strings
  static const String newStockTake = 'New Stock Take';
  static const String stockTakeNumber = 'Stock Take Number';
  static const String stockTakeDate = 'Stock Take Date';
  static const String systemQuantity = 'System Quantity';
  static const String actualQuantity = 'Actual Quantity';
  static const String difference = 'Difference';
  static const String discrepancy = 'Discrepancy';
  static const String discrepancyValue = 'Discrepancy Value';
  static const String inProgress = 'In Progress';
  static const String completed = 'Completed';
  static const String draft = 'Draft';
  static const String reconcile = 'Reconcile';
  static const String verify = 'Verify';
  
  // Medicine Strings
  static const String medicineName = 'Medicine Name';
  static const String genericName = 'Generic Name';
  static const String brand = 'Brand';
  static const String batchNumber = 'Batch Number';
  static const String expiryDate = 'Expiry Date';
  static const String manufacturingDate = 'Manufacturing Date';
  static const String quantity = 'Quantity';
  static const String unitPrice = 'Unit Price';
  static const String sellingPrice = 'Selling Price';
  static const String costPrice = 'Cost Price';
  static const String reorderLevel = 'Reorder Level';
  static const String location = 'Location';
  static const String lowStock = 'Low Stock';
  static const String expiringSoon = 'Expiring Soon';
  static const String expired = 'Expired';
  
  // Sale Strings
  static const String newSale = 'New Sale';
  static const String invoiceNumber = 'Invoice Number';
  static const String saleDate = 'Sale Date';
  static const String subtotal = 'Subtotal';
  static const String tax = 'Tax';
  static const String discount = 'Discount';
  static const String total = 'Total';
  static const String cash = 'Cash';
  static const String change = 'Change';
  static const String paymentStatus = 'Payment Status';
  
  // Report Strings
  static const String salesReport = 'Sales Report';
  static const String inventoryReport = 'Inventory Report';
  static const String financialReport = 'Financial Report';
  static const String prescriptionReport = 'Prescription Report';
  static const String creditReport = 'Credit Report';
  static const String expenseReport = 'Expense Report';
  static const String profitAndLoss = 'Profit & Loss';
  static const String dateRange = 'Date Range';
  static const String startDate = 'Start Date';
  static const String endDate = 'End Date';
  static const String generate = 'Generate';
  static const String download = 'Download';
  
  // Validation Messages
  static const String fieldRequired = 'This field is required';
  static const String invalidEmail = 'Please enter a valid email';
  static const String invalidPhone = 'Please enter a valid phone number';
  static const String passwordTooShort = 'Password must be at least 6 characters';
  static const String passwordsDoNotMatch = 'Passwords do not match';
  static const String invalidAmount = 'Please enter a valid amount';
  static const String invalidQuantity = 'Please enter a valid quantity';
  static const String selectProduct = 'Please select a product';
  static const String insufficientStock = 'Insufficient stock available';
  static const String dateInvalid = 'Please select a valid date';
  
  // Confirmation Messages
  static const String confirmDelete = 'Are you sure you want to delete this?';
  static const String confirmDispense = 'Are you sure you want to dispense this prescription?';
  static const String confirmComplete = 'Are you sure you want to complete this stock take?';
  static const String confirmPayment = 'Are you sure you want to record this payment?';
  static const String deleteWarning = 'This action cannot be undone.';
  
  // Success Messages
  static const String savedSuccess = 'Saved successfully';
  static const String updatedSuccess = 'Updated successfully';
  static const String deletedSuccess = 'Deleted successfully';
  static const String dispensedSuccess = 'Prescription dispensed successfully';
  static const String paymentSuccess = 'Payment recorded successfully';
  static const String stockTakeSuccess = 'Stock take completed successfully';
  
  // Error Messages
  static const String networkError = 'Network error. Please check your connection';
  static const String serverError = 'Server error. Please try again later';
  static const String authenticationError = 'Authentication failed. Please login again';
  static const String permissionError = 'You do not have permission to perform this action';
  static const String notFound = 'Record not found';
  static const String duplicateError = 'Record already exists';
}

class AppDurations {
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration snackBarDuration = Duration(seconds: 3);
  static const Duration fadeDuration = Duration(milliseconds: 500);
  static const Duration slideDuration = Duration(milliseconds: 400);
  static const Duration scaleDuration = Duration(milliseconds: 200);
}

class StorageKeys {
  static const String firstLaunch = 'first_launch';
  static const String token = 'auth_token';
  static const String user = 'user_data';
  static const String theme = 'theme_mode';
  static const String language = 'language';
  static const String onboardingCompleted = 'onboarding_completed';
  static const String userId = 'user_id';
  static const String userRole = 'user_role';
  static const String userPermissions = 'user_permissions';
}

class AppConstants {
  // API Base URL
  static const String baseUrl = 'http://localhost:8000/api';
  
  // API Endpoints
  static const String loginEndpoint = '/auth/login/';
  static const String logoutEndpoint = '/auth/logout/';
  static const String registerEndpoint = '/auth/register/';
  static const String verifyOtpEndpoint = '/auth/verify-otp/';
  static const String forgotPasswordEndpoint = '/auth/forgot-password/';
  static const String resetPasswordEndpoint = '/auth/reset-password/';
  static const String resetPasswordOtpEndpoint = '/auth/reset-password-otp/';
  static const String resendOtpEndpoint = '/auth/resend-otp/';
  static const String usersEndpoint = '/auth/users/';
  
  // Medicine Endpoints
  static const String medicinesEndpoint = '/medicines/';
  static const String categoriesEndpoint = '/medicines/categories/';
  static const String suppliersEndpoint = '/medicines/suppliers/';
  static const String lowStockEndpoint = '/medicines/low-stock/';
  static const String expiringEndpoint = '/medicines/expiring/';
  static const String expiredEndpoint = '/medicines/expired/';
  
  // Sale Endpoints
  static const String salesEndpoint = '/sales/';
  static const String dailySalesEndpoint = '/sales/daily/';
  static const String salesByDateEndpoint = '/sales/by-date/';
  
  // Prescription Endpoints
  static const String prescriptionsEndpoint = '/prescriptions/';
  static const String dispensePrescriptionEndpoint = '/prescriptions/';
  static const String prescriptionsByDateEndpoint = '/prescriptions/by-date/';
  
  // Credit Endpoints
  static const String creditsEndpoint = '/credits/';
  static const String addPaymentEndpoint = '/credits/';
  static const String overdueCreditsEndpoint = '/credits/overdue/';
  
  // Expense Endpoints
  static const String expensesEndpoint = '/expenses/';
  static const String expensesByCategoryEndpoint = '/expenses/by-category/';
  static const String expensesByDateEndpoint = '/expenses/by-date/';
  
  // Stock Take Endpoints
  static const String stockTakesEndpoint = '/stock-takes/';
  static const String completeStockTakeEndpoint = '/stock-takes/';
  static const String addStockTakeItemsEndpoint = '/stock-takes/';
  
  // Report Endpoints
  static const String reportsEndpoint = '/reports/';
  static const String dashboardEndpoint = '/dashboard/';
  static const String salesReportEndpoint = '/reports/sales/';
  static const String inventoryReportEndpoint = '/reports/inventory/';
  static const String staffReportEndpoint = '/reports/staff/';
  static const String dailySalesReportEndpoint = '/reports/daily-sales/';
  static const String lowStockReportEndpoint = '/reports/low-stock/';
  static const String expiredReportEndpoint = '/reports/expired/';
  static const String financialSummaryEndpoint = '/reports/financial-summary/';
  static const String profitLossEndpoint = '/reports/profit-loss/';
  
  // Storage Keys
  static const String tokenKey = StorageKeys.token;
  static const String userKey = StorageKeys.user;
  static const String themeKey = StorageKeys.theme;
  static const String languageKey = StorageKeys.language;
  
  // Cache Keys
  static const String cacheMedicines = 'cached_medicines';
  static const String cachePrescriptions = 'cached_prescriptions';
  static const String cacheCredits = 'cached_credits';
  static const String cacheExpenses = 'cached_expenses';
  static const String cacheDashboard = 'cached_dashboard';
  static const String cacheLastUpdate = 'cache_last_update';
  
  // Cache Duration
  static const Duration cacheDuration = Duration(minutes: 30);
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Spacing
  static const double paddingSmallest = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingExtraLarge = 32.0;
  static const double paddingHuge = 48.0;
  
  // Margins
  static const double marginSmall = 8.0;
  static const double marginMedium = 16.0;
  static const double marginLarge = 24.0;
  
  // Font Sizes
  static const double fontSizeTiny = 10.0;
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeExtraLarge = 18.0;
  static const double fontSizeHeading = 20.0;
  static const double fontSizeTitle = 24.0;
  static const double fontSizeDisplay = 32.0;
  
  // Border Radius
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusExtraLarge = 16.0;
  static const double radiusCircular = 100.0;
  
  // Elevation
  static const double elevationNone = 0.0;
  static const double elevationSmall = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationLarge = 8.0;
  static const double elevationExtraLarge = 12.0;
  
  // Icon Sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 20.0;
  static const double iconSizeLarge = 24.0;
  static const double iconSizeExtraLarge = 32.0;
  
  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 400);
  static const Duration animationSlow = Duration(milliseconds: 600);
  
  // Colors (for backward compatibility)
  static const Color primaryColor = AppColors.primaryGreen;
  
  // Credit Types
  static const List<String> creditTypes = [
    AppStrings.customer,
    AppStrings.supplier,
  ];
  
  // Payment Methods
  static const List<String> paymentMethods = [
    'Cash',
    'Bank Transfer',
    'Cheque',
    'Mobile Money',
    'Card',
  ];
  
  // Prescription Statuses
  static const List<String> prescriptionStatuses = [
    AppStrings.pending,
    AppStrings.dispensed,
    AppStrings.cancelled,
  ];
  
  // Credit Statuses
  static const List<String> creditStatuses = [
    AppStrings.pending,
    AppStrings.partial,
    AppStrings.paid,
    AppStrings.overdue,
  ];
  
  // Expense Categories
  static const List<String> expenseCategories = [
    AppStrings.rent,
    AppStrings.utilities,
    AppStrings.salary,
    AppStrings.maintenance,
    AppStrings.supplies,
    AppStrings.transport,
    AppStrings.marketing,
    AppStrings.other,
  ];
  
  // Stock Take Statuses
  static const List<String> stockTakeStatuses = [
    AppStrings.draft,
    AppStrings.inProgress,
    AppStrings.completed,
    AppStrings.cancelled,
  ];
  
  // User Roles
  static const List<String> userRoles = [
    'Admin',
    'Pharmacist',
    'Cashier',
    'Manager',
    'Accountant',
  ];
}

// Helper extension methods
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
  
  String toTitleCase() {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize()).join(' ');
  }
}

extension ColorExtension on Color {
  MaterialColor toMaterialColor() {
    final shades = <int, Color>{
      50: withOpacity(0.1),
      100: withOpacity(0.2),
      200: withOpacity(0.3),
      300: withOpacity(0.4),
      400: withOpacity(0.5),
      500: this,
      600: withOpacity(0.7),
      700: withOpacity(0.8),
      800: withOpacity(0.9),
      900: withOpacity(1.0),
    };
    return MaterialColor(value, shades);
  }
}