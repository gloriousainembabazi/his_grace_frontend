// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/medicine_provider.dart';
import 'providers/sale_provider.dart';
import 'providers/report_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/prescription_provider.dart';
import 'providers/credit_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/stock_provider.dart';
import 'providers/supplier_provider.dart'; // NEW

// Services
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/storage_service.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/otp_verification_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/medicines/medicine_list_screen.dart';
import 'screens/medicines/add_medicine_screen.dart';
import 'screens/medicines/medicine_detail_screen.dart';
import 'screens/sales/sale_list_screen.dart';
import 'screens/sales/new_sale_screen.dart';
import 'screens/sales/sale_detail_screen.dart';
import 'screens/prescription/prescription_list_screen.dart';
import 'screens/prescription/create_prescription_screen.dart';
import 'screens/prescription/prescription_detail_screen.dart';
import 'screens/credit/credit_list_screen.dart';
import 'screens/credit/create_credit_screen.dart';
import 'screens/credit/credit_detail_screen.dart';
import 'screens/expense/expense_list_screen.dart';
import 'screens/expense/create_expense_screen.dart';
import 'screens/expense/expense_detail_screen.dart';
import 'screens/stock/stock_take_list_screen.dart';
import 'screens/stock/create_stock_take_screen.dart';
import 'screens/stock/stock_take_detail_screen.dart';
import 'screens/reports/report_dashboard.dart';
import 'screens/reports/sales_report_screen.dart';
import 'screens/reports/inventory_report_screen.dart';
import 'screens/reports/staff_report_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/settings/change_password_screen.dart';
import 'screens/settings/about_screen.dart';

// Utils
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  const storage = FlutterSecureStorage();
  final storageService = StorageService(storage);
  final apiService = ApiService(storageService);
  final authService = AuthService(apiService, storageService);

  // Check if onboarding is completed
  final prefs = await SharedPreferences.getInstance();
  final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

  runApp(MyApp(
    apiService: apiService,
    authService: authService,
    storageService: storageService,
    onboardingCompleted: onboardingCompleted,
  ));
}

class MyApp extends StatelessWidget {
  final ApiService apiService;
  final AuthService authService;
  final StorageService storageService;
  final bool onboardingCompleted;

  const MyApp({
    super.key,
    required this.apiService,
    required this.authService,
    required this.storageService,
    required this.onboardingCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService, storageService),
        ),
        ChangeNotifierProvider(create: (_) => MedicineProvider(apiService)),
        ChangeNotifierProvider(create: (_) => SaleProvider(apiService)),
        ChangeNotifierProvider(create: (_) => ReportProvider(apiService)),
        ChangeNotifierProvider(create: (_) => SettingsProvider(storageService)),
        ChangeNotifierProvider(create: (_) => PrescriptionProvider(apiService)),
        ChangeNotifierProvider(create: (_) => CreditProvider(apiService)),
        ChangeNotifierProvider(create: (_) => ExpenseProvider(apiService)),
        ChangeNotifierProvider(create: (_) => StockProvider(apiService)),
        ChangeNotifierProvider(create: (_) => SupplierProvider()), // NEW
      ],
      child: Consumer2<AuthProvider, SettingsProvider>(
        builder: (context, authProvider, settingsProvider, child) {
          return MaterialApp(
            title: 'His_Grace_Drugshop',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsProvider.getThemeMode(),
            initialRoute: _getInitialRoute(authProvider, onboardingCompleted),
            routes: {
              '/splash': (context) => const SplashScreen(),
              '/onboarding': (context) => const OnboardingScreen(),
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/forgot-password': (context) => const ForgotPasswordScreen(),
              '/dashboard': (context) => const DashboardScreen(),
              '/medicines': (context) => const MedicineListScreen(),
              '/add-medicine': (context) => const AddMedicineScreen(),
              '/sales': (context) => const SaleListScreen(),
              '/new-sale': (context) => const NewSaleScreen(),
              '/reports': (context) => const ReportDashboard(),
              '/sales-report': (context) => const SalesReportScreen(),
              '/inventory-report': (context) => const InventoryReportScreen(),
              '/staff-report': (context) => const StaffReportScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/change-password': (context) => const ChangePasswordScreen(),
              '/about': (context) => const AboutScreen(),
              '/prescriptions': (context) => const PrescriptionListScreen(),
              '/create-prescription': (context) => const CreatePrescriptionScreen(),
              '/credits': (context) => const CreditListScreen(),
              '/create-credit': (context) => const CreateCreditScreen(),
              '/expenses': (context) => const ExpenseListScreen(),
              '/create-expense': (context) => const CreateExpenseScreen(),
              '/stock-takes': (context) => const StockTakeListScreen(),
              '/create-stock-take': (context) => const CreateStockTakeScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/medicine-detail') {
                final args = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder: (context) => MedicineDetailScreen(medicineId: args['id']),
                );
              }
              if (settings.name == '/sale-detail') {
                final args = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder: (context) => SaleDetailScreen(saleId: args['id']),
                );
              }
              if (settings.name == '/prescription-detail') {
                final args = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder: (context) => PrescriptionDetailScreen(prescriptionId: args['id']),
                );
              }
              if (settings.name == '/credit-detail') {
                final args = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder: (context) => CreditDetailScreen(creditId: args['id']),
                );
              }
              if (settings.name == '/expense-detail') {
                final args = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder: (context) => ExpenseDetailScreen(expenseId: args['id']),
                );
              }
              if (settings.name == '/stock-take-detail') {
                final args = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder: (context) => StockTakeDetailScreen(stockTakeId: args['id']),
                );
              }
              if (settings.name == '/otp-verification') {
                final email = settings.arguments as String;
                return MaterialPageRoute(
                  builder: (context) => OtpVerificationScreen(email: email),
                );
              }
              if (settings.name == '/reset-password') {
                final args = settings.arguments as Map<String, String>;
                return MaterialPageRoute(
                  builder: (context) => ResetPasswordScreen(
                    email: args['email'] ?? '',
                    otp: args['otp'],
                    uid: args['uid'],
                    token: args['token'],
                  ),
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }

  String _getInitialRoute(AuthProvider authProvider, bool onboardingCompleted) {
    if (authProvider.isLoading) {
      return '/splash';
    }
    if (authProvider.isAuthenticated) {
      return '/dashboard';
    }
    if (!onboardingCompleted) {
      return '/onboarding';
    }
    return '/login';
  }
}