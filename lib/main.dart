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
import 'providers/category_provider.dart';
import 'providers/supplier_provider.dart';
import 'providers/dashboard_provider.dart';

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
import 'screens/dashboard/admin_dashboard.dart';
import 'screens/dashboard/worker_dashboard.dart';
import 'screens/dashboard/realtime_dashboard.dart';
import 'screens/medicines/medicine_list_screen.dart';
import 'screens/medicines/add_medicine_screen.dart';
import 'screens/medicines/medicine_detail_screen.dart';
import 'screens/sales/sale_list_screen.dart';
import 'screens/sales/new_sale_screen.dart';
import 'screens/sales/sale_detail_screen.dart';
import 'screens/prescription/prescription_list_screen.dart';
import 'screens/prescription/create_prescription_screen.dart' as old;
import 'screens/prescription/new_prescription_screen.dart' as newRx;
import 'screens/prescription/prescription_detail_screen.dart';
import 'screens/prescription/upload_prescription_screen.dart';
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
import 'screens/staff/staff_list_screen.dart';
import 'screens/staff/create_staff_screen.dart';
import 'screens/staff/staff_form_screen.dart';

// Utils
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    const storage = FlutterSecureStorage();
    final storageService = StorageService(storage);
    final apiService = ApiService(storageService);
    final authService = AuthService(apiService, storageService);

    final prefs = await SharedPreferences.getInstance();
    final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

    runApp(MyApp(
      apiService: apiService,
      authService: authService,
      storageService: storageService,
      onboardingCompleted: onboardingCompleted,
    ));
  } catch (e) {
    print('Error initializing app: $e');
    runApp(const ErrorApp());
  }
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
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => PrescriptionProvider(apiService),
        ),
        ChangeNotifierProvider(create: (_) => CreditProvider(apiService)),
        ChangeNotifierProvider(create: (_) => ExpenseProvider(apiService)),
        ChangeNotifierProvider(create: (_) => StockProvider(apiService)),
        ChangeNotifierProvider(create: (_) => CategoryProvider(apiService)),
        ChangeNotifierProvider(create: (_) => SupplierProvider(apiService)),
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(apiService),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'His Grace Drugshop',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            home: const SplashScreen(),
            onGenerateRoute: (settings) {
              final args = settings.arguments;

              if (settings.name == '/dashboard') {
                final user = authProvider.currentUser;
                final isAdmin = user?.isAdmin ?? false;
                return MaterialPageRoute(
                  builder: (_) =>
                      isAdmin ? const AdminDashboard() : const WorkerDashboard(),
                );
              }

              if (settings.name == '/realtime-dashboard') {
                return MaterialPageRoute(
                  builder: (_) => const RealtimeDashboard(),
                );
              }

              if (settings.name == '/medicine-detail' && args is Map<String, dynamic>) {
                return MaterialPageRoute(
                  builder: (_) => MedicineDetailScreen(medicineId: args['id']),
                );
              }

              if (settings.name == '/sale-detail' && args is Map<String, dynamic>) {
                return MaterialPageRoute(
                  builder: (_) => SaleDetailScreen(saleId: args['id']),
                );
              }

              if (settings.name == '/prescription-detail' && args is Map<String, dynamic>) {
                return MaterialPageRoute(
                  builder: (_) => PrescriptionDetailScreen(prescriptionId: args['id']),
                );
              }

              if (settings.name == '/credit-detail' && args is Map<String, dynamic>) {
                return MaterialPageRoute(
                  builder: (_) => CreditDetailScreen(creditId: args['id'] as int),
                );
              }

              if (settings.name == '/expense-detail' && args is Map<String, dynamic>) {
                return MaterialPageRoute(
                  builder: (_) => ExpenseDetailScreen(expenseId: args['id'] as int),
                );
              }

              if (settings.name == '/stock-take-detail' && args is Map<String, dynamic>) {
                return MaterialPageRoute(
                  builder: (_) => StockTakeDetailScreen(stockTakeId: args['id'] as int),
                );
              }

              if (settings.name == '/otp-verification' && args is String) {
                return MaterialPageRoute(
                  builder: (_) => OtpVerificationScreen(email: args),
                );
              }

              if (settings.name == '/reset-password' && args is Map<String, String>) {
                return MaterialPageRoute(
                  builder: (_) => ResetPasswordScreen(
                    email: args['email'] ?? '',
                    otp: args['otp'],
                    uid: args['uid'],
                    token: args['token'],
                  ),
                );
              }

              final routes = {
                '/onboarding': (_) => const OnboardingScreen(),
                '/login': (_) => const LoginScreen(),
                '/register': (_) => const RegisterScreen(),
                '/forgot-password': (_) => const ForgotPasswordScreen(),
                '/medicines': (_) => const MedicineListScreen(),
                '/add-medicine': (_) => const AddMedicineScreen(),
                '/sales': (_) => const SaleListScreen(),
                '/new-sale': (_) => const NewSaleScreen(),
                '/reports': (_) => const ReportDashboard(),
                '/sales-report': (_) => const SalesReportScreen(),
                '/inventory-report': (_) => const InventoryReportScreen(),
                '/staff-report': (_) => const StaffReportScreen(),
                '/profile': (_) => const ProfileScreen(),
                '/settings': (_) => const SettingsScreen(),
                '/change-password': (_) => const ChangePasswordScreen(),
                '/about': (_) => const AboutScreen(),
                '/prescriptions': (_) => const PrescriptionListScreen(),
                '/create-prescription': (_) => const old.CreatePrescriptionScreen(),
                '/new-prescription': (_) => const newRx.NewPrescriptionScreen(),
                '/upload-prescription': (_) => const UploadPrescriptionScreen(),
                '/credits': (_) => const CreditListScreen(),
                '/create-credit': (_) => const CreateCreditScreen(),
                '/expenses': (_) => const ExpenseListScreen(),
                '/create-expense': (_) => const CreateExpenseScreen(),
                '/stock-takes': (_) => const StockTakeListScreen(),
                '/create-stock-take': (_) => const CreateStockTakeScreen(),
                '/staff': (_) => const StaffListScreen(),
                '/create-staff': (_) => const CreateStaffScreen(),
                '/staff-form': (_) => const StaffFormScreen(),
              };

              if (routes.containsKey(settings.name)) {
                return MaterialPageRoute(builder: routes[settings.name]!);
              }

              return MaterialPageRoute(
                builder: (_) => const Scaffold(
                  body: Center(child: Text('Route not found')),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'His Grace Drugshop',
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Failed to initialize app', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Please restart the application'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  main();
                },
                child: const Text('Restart'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}