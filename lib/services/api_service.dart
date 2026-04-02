// lib/services/api_service.dart

import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'storage_service.dart';
import '../utils/constants.dart';

class ApiService {
  final StorageService _storageService;
  late final Dio _dio;

  ApiService(this._storageService) {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Token $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            await _storageService.clearAll();
          }
          return handler.next(error);
        },
      ),
    );

    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
    ));
  }

  // ==================== AUTH METHODS ====================
  
  Future<Response> login(String username, String password) async {
    return _dio.post('/auth/login/', data: {
      'username': username,
      'password': password,
    });
  }

  Future<Response> logout() async {
    return _dio.post('/auth/logout/');
  }

  Future<Response> register(Map<String, dynamic> userData) async {
    return _dio.post('/auth/register/', data: userData);
  }

  Future<Response> verifyOtp(String email, String otp) async {
    return _dio.post('/auth/verify-otp/', data: {
      'email': email,
      'otp': otp,
    });
  }

  Future<Response> forgotPassword(String email) async {
    return _dio.post('/auth/forgot-password/', data: {
      'email': email,
    });
  }

  Future<Response> resetPassword(String uid, String token, String newPassword) async {
    return _dio.post('/auth/reset-password/', data: {
      'uid': uid,
      'token': token,
      'new_password': newPassword,
    });
  }

  Future<Response> resetPasswordWithOtp(String email, String otp, String newPassword) async {
    return _dio.post('/auth/reset-password-otp/', data: {
      'email': email,
      'otp': otp,
      'new_password': newPassword,
    });
  }

  Future<Response> resendOtp(String email) async {
    return _dio.post('/auth/resend-otp/', data: {
      'email': email,
    });
  }

  // ==================== USER METHODS ====================

  Future<Response> getUsers() async {
    return _dio.get('/auth/users/');
  }

  Future<Response> getUser(int id) async {
    return _dio.get('/auth/users/$id/');
  }

  Future<Response> updateUser(int id, Map<String, dynamic> userData) async {
    return _dio.patch('/auth/users/$id/', data: userData);
  }

  // ==================== MEDICINE METHODS ====================

  Future<Response> getMedicines({Map<String, dynamic>? params}) async {
    return _dio.get('/medicines/', queryParameters: params);
  }

  Future<Response> getMedicine(int id) async {
    return _dio.get('/medicines/$id/');
  }

  Future<Response> createMedicine(Map<String, dynamic> medicineData) async {
    return _dio.post('/medicines/', data: medicineData);
  }

  Future<Response> updateMedicine(int id, Map<String, dynamic> medicineData) async {
    return _dio.put('/medicines/$id/', data: medicineData);
  }

  Future<Response> deleteMedicine(int id) async {
    return _dio.delete('/medicines/$id/');
  }

  Future<Response> getLowStockMedicines() async {
    return _dio.get('/medicines/low-stock/');
  }

  Future<Response> getExpiringMedicines() async {
    return _dio.get('/medicines/expiring/');
  }

  Future<Response> getExpiredMedicines() async {
    return _dio.get('/medicines/expired/');
  }

  // ==================== CATEGORY METHODS ====================

  Future<Response> getCategories() async {
    return _dio.get('/medicines/categories/');
  }

  Future<Response> createCategory(Map<String, dynamic> categoryData) async {
    return _dio.post('/medicines/categories/', data: categoryData);
  }

  // ==================== SUPPLIER METHODS ====================

  Future<Response> getSuppliers() async {
    return _dio.get('/medicines/suppliers/');
  }

  Future<Response> createSupplier(Map<String, dynamic> supplierData) async {
    return _dio.post('/medicines/suppliers/', data: supplierData);
  }

  // ==================== SALE METHODS ====================

  Future<Response> getSales({Map<String, dynamic>? params}) async {
    return _dio.get('/sales/', queryParameters: params);
  }

  Future<Response> getSale(int id) async {
    return _dio.get('/sales/$id/');
  }

  Future<Response> createSale(Map<String, dynamic> saleData) async {
    return _dio.post('/sales/', data: saleData);
  }

  Future<Response> getDailySales() async {
    return _dio.get('/sales/daily/');
  }

  Future<Response> getSalesByDateRange(String startDate, String endDate) async {
    return _dio.get('/sales/by-date/', queryParameters: {
      'start_date': startDate,
      'end_date': endDate,
    });
  }

  // ==================== PRESCRIPTION METHODS ====================

  Future<Response> getPrescriptions({Map<String, dynamic>? params}) async {
    return _dio.get('/prescriptions/', queryParameters: params);
  }

  Future<Response> getPrescription(int id) async {
    return _dio.get('/prescriptions/$id/');
  }

  Future<Response> createPrescription(Map<String, dynamic> prescriptionData) async {
    return _dio.post('/prescriptions/', data: prescriptionData);
  }

  Future<Response> updatePrescription(int id, Map<String, dynamic> prescriptionData) async {
    return _dio.put('/prescriptions/$id/', data: prescriptionData);
  }

  Future<Response> deletePrescription(int id) async {
    return _dio.delete('/prescriptions/$id/');
  }

  Future<Response> dispensePrescription(int id) async {
    return _dio.post('/prescriptions/$id/dispense/');
  }

  Future<Response> getPrescriptionsByDate(String date) async {
    return _dio.get('/prescriptions/by-date/', queryParameters: {'date': date});
  }

  // ==================== CREDIT METHODS ====================

  Future<Response> getCredits({Map<String, dynamic>? params}) async {
    return _dio.get('/credits/', queryParameters: params);
  }

  Future<Response> getCredit(int id) async {
    return _dio.get('/credits/$id/');
  }

  Future<Response> createCredit(Map<String, dynamic> creditData) async {
    return _dio.post('/credits/', data: creditData);
  }

  Future<Response> updateCredit(int id, Map<String, dynamic> creditData) async {
    return _dio.put('/credits/$id/', data: creditData);
  }

  Future<Response> deleteCredit(int id) async {
    return _dio.delete('/credits/$id/');
  }

  Future<Response> addCreditPayment(int creditId, Map<String, dynamic> paymentData) async {
    return _dio.post('/credits/$creditId/add_payment/', data: paymentData);
  }

  Future<Response> getOverdueCredits() async {
    return _dio.get('/credits/overdue/');
  }

  // ==================== EXPENSE METHODS ====================

  Future<Response> getExpenses({Map<String, dynamic>? params}) async {
    return _dio.get('/expenses/', queryParameters: params);
  }

  Future<Response> getExpense(int id) async {
    return _dio.get('/expenses/$id/');
  }

  Future<Response> createExpense(Map<String, dynamic> expenseData) async {
    return _dio.post('/expenses/', data: expenseData);
  }

  Future<Response> updateExpense(int id, Map<String, dynamic> expenseData) async {
    return _dio.put('/expenses/$id/', data: expenseData);
  }

  Future<Response> deleteExpense(int id) async {
    return _dio.delete('/expenses/$id/');
  }

  Future<Response> getExpensesByCategory(String category) async {
    return _dio.get('/expenses/by-category/', queryParameters: {'category': category});
  }

  Future<Response> getExpensesByDateRange(String startDate, String endDate) async {
    return _dio.get('/expenses/by-date/', queryParameters: {
      'start_date': startDate,
      'end_date': endDate,
    });
  }

  // ==================== STOCK TAKE METHODS ====================

  Future<Response> getStockTakes({Map<String, dynamic>? params}) async {
    return _dio.get('/stock-takes/', queryParameters: params);
  }

  Future<Response> getStockTake(int id) async {
    return _dio.get('/stock-takes/$id/');
  }

  Future<Response> createStockTake(Map<String, dynamic> stockTakeData) async {
    return _dio.post('/stock-takes/', data: stockTakeData);
  }

  Future<Response> updateStockTake(int id, Map<String, dynamic> stockTakeData) async {
    return _dio.put('/stock-takes/$id/', data: stockTakeData);
  }

  Future<Response> deleteStockTake(int id) async {
    return _dio.delete('/stock-takes/$id/');
  }

  Future<Response> completeStockTake(int id) async {
    return _dio.post('/stock-takes/$id/complete/');
  }

  Future<Response> addStockTakeItems(int stockTakeId, List<Map<String, dynamic>> items) async {
    return _dio.post('/stock-takes/$stockTakeId/add_items/', data: items);
  }

  // ==================== REPORT METHODS ====================

  Future<Response> getDashboardSummary() async {
    return _dio.get('/dashboard/');
  }

  Future<Response> getSalesReport({String? startDate, String? endDate}) async {
    return _dio.get('/reports/sales/', queryParameters: {
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
    });
  }

  Future<Response> getInventoryReport() async {
    return _dio.get('/reports/inventory/');
  }

  Future<Response> getStaffReport() async {
    return _dio.get('/reports/staff/');
  }

  Future<Response> getDailySalesReport() async {
    return _dio.get('/reports/daily-sales/');
  }

  Future<Response> getLowStockReport() async {
    return _dio.get('/reports/low-stock/');
  }

  Future<Response> getExpiredReport() async {
    return _dio.get('/reports/expired/');
  }

  // ==================== FINANCIAL SUMMARY METHODS ====================

  Future<Response> getFinancialSummary() async {
    return _dio.get('/reports/financial-summary/');
  }

  Future<Response> getProfitAndLoss({String? startDate, String? endDate}) async {
    return _dio.get('/reports/profit-loss/', queryParameters: {
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
    });
  }
}