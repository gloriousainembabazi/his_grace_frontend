// lib/services/api_service.dart

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class ApiResponse {
  final bool isSuccess;
  final dynamic data;
  final String? error;
  final int statusCode;

  ApiResponse({
    required this.isSuccess,
    this.data,
    this.error,
    required this.statusCode,
  });
}

class ApiService {
  final StorageService _storageService;

  // Backend URL - Change this to your backend IP/domain
  static const String baseUrl = "http://127.0.0.1:8000/api";

  // Singleton instance for static methods
  static ApiService? _instance;

  ApiService(this._storageService);

  // Get singleton instance
  static ApiService _getInstance() {
    if (_instance == null) {
      const storage = FlutterSecureStorage();
      final storageService = StorageService(storage);
      _instance = ApiService(storageService);
    }
    return _instance!;
  }

  // ================= HEADERS =================
  Future<Map<String, String>> _headers() async {
    final token = await _storageService.getToken();
    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  // ================= RESPONSE HANDLER =================
  ApiResponse _handleResponse(http.Response res) {
    final data = res.body.isNotEmpty ? jsonDecode(res.body) : null;

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return ApiResponse(
        isSuccess: true,
        data: data,
        statusCode: res.statusCode,
      );
    } else {
      String errorMessage = 'Unknown error';
      if (data != null) {
        if (data is Map) {
          errorMessage = data['detail'] ?? 
                         data['message'] ?? 
                         data['error'] ?? 
                         data.toString();
        } else {
          errorMessage = data.toString();
        }
      }
      return ApiResponse(
        isSuccess: false,
        error: errorMessage,
        statusCode: res.statusCode,
      );
    }
  }

  // ================= GENERIC METHODS =================
  Future<ApiResponse> get(String endpoint) async {
    try {
      final uri = endpoint.startsWith('http') 
          ? Uri.parse(endpoint) 
          : Uri.parse("$baseUrl$endpoint");
      final res = await http.get(
        uri,
        headers: await _headers(),
      );
      return _handleResponse(res);
    } catch (e) {
      return ApiResponse(
        isSuccess: false,
        error: e.toString(),
        statusCode: 500,
      );
    }
  }

  Future<ApiResponse> post(String endpoint, dynamic body) async {
    try {
      final uri = endpoint.startsWith('http') 
          ? Uri.parse(endpoint) 
          : Uri.parse("$baseUrl$endpoint");
      final res = await http.post(
        uri,
        headers: await _headers(),
        body: jsonEncode(body),
      );
      return _handleResponse(res);
    } catch (e) {
      return ApiResponse(
        isSuccess: false,
        error: e.toString(),
        statusCode: 500,
      );
    }
  }

  Future<ApiResponse> put(String endpoint, dynamic body) async {
    try {
      final uri = endpoint.startsWith('http') 
          ? Uri.parse(endpoint) 
          : Uri.parse("$baseUrl$endpoint");
      final res = await http.put(
        uri,
        headers: await _headers(),
        body: jsonEncode(body),
      );
      return _handleResponse(res);
    } catch (e) {
      return ApiResponse(
        isSuccess: false,
        error: e.toString(),
        statusCode: 500,
      );
    }
  }

  Future<ApiResponse> patch(String endpoint, dynamic body) async {
    try {
      final uri = endpoint.startsWith('http') 
          ? Uri.parse(endpoint) 
          : Uri.parse("$baseUrl$endpoint");
      final res = await http.patch(
        uri,
        headers: await _headers(),
        body: jsonEncode(body),
      );
      return _handleResponse(res);
    } catch (e) {
      return ApiResponse(
        isSuccess: false,
        error: e.toString(),
        statusCode: 500,
      );
    }
  }

  Future<ApiResponse> delete(String endpoint) async {
    try {
      final uri = endpoint.startsWith('http') 
          ? Uri.parse(endpoint) 
          : Uri.parse("$baseUrl$endpoint");
      final res = await http.delete(
        uri,
        headers: await _headers(),
      );
      return _handleResponse(res);
    } catch (e) {
      return ApiResponse(
        isSuccess: false,
        error: e.toString(),
        statusCode: 500,
      );
    }
  }

  // ================= FILE UPLOAD =================
  Future<ApiResponse> uploadFile(
    String endpoint, {
    required String filePath,
    required Map<String, String> fields,
    String fileField = 'file',
  }) async {
    try {
      final token = await _storageService.getToken();
      final request = http.MultipartRequest('POST', Uri.parse("$baseUrl$endpoint"));
      
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      request.fields.addAll(fields);
      request.files.add(await http.MultipartFile.fromPath(fileField, filePath));
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        isSuccess: false,
        error: e.toString(),
        statusCode: 500,
      );
    }
  }

  // ================= AUTH ENDPOINTS =================
  Future<ApiResponse> login(String username, String password) {
    return post("/auth/login/", {
      "username": username,
      "password": password,
    });
  }

  Future<ApiResponse> register(Map<String, dynamic> data) {
    return post("/auth/register/", data);
  }

  Future<ApiResponse> logout() async {
    try {
      return await post("/auth/logout/", {});
    } catch (_) {
      return ApiResponse(
        isSuccess: true,
        statusCode: 200,
      );
    }
  }

  Future<ApiResponse> verifyOtp(String email, String otp) {
    return post("/auth/verify-otp/", {
      "email": email,
      "otp": otp,
    });
  }

  Future<ApiResponse> resendOtp(String email) {
    return post("/auth/resend-otp/", {
      "email": email,
    });
  }

  Future<ApiResponse> forgotPassword(String email) {
    return post("/auth/forgot-password/", {
      "email": email,
    });
  }

  Future<ApiResponse> resetPassword(String uid, String token, String password) {
    return post("/auth/reset-password/", {
      "uid": uid,
      "token": token,
      "password": password,
    });
  }

  Future<ApiResponse> resetPasswordWithOtp(String email, String otp, String password) {
    return post("/auth/reset-password-otp/", {
      "email": email,
      "otp": otp,
      "password": password,
    });
  }

  // ================= USERS (STAFF) ENDPOINTS =================
  Future<ApiResponse> getUsers() => get("/auth/users/");
  Future<ApiResponse> getUser(dynamic id) => get("/auth/users/$id/");
  Future<ApiResponse> createUser(Map<String, dynamic> data) => post("/auth/users/", data);
  Future<ApiResponse> updateUser(dynamic id, Map<String, dynamic> data) => patch("/auth/users/$id/", data);
  Future<ApiResponse> deleteUser(dynamic id) => delete("/auth/users/$id/");

  // ================= PATIENTS =================
  Future<ApiResponse> getPatients({String? search}) {
    String endpoint = "/patients/";
    if (search != null && search.isNotEmpty) {
      endpoint += "?search=$search";
    }
    return get(endpoint);
  }
  
  Future<ApiResponse> getPatient(dynamic id) => get("/patients/$id/");
  Future<ApiResponse> createPatient(Map<String, dynamic> data) => post("/patients/", data);
  Future<ApiResponse> updatePatient(dynamic id, Map<String, dynamic> data) => put("/patients/$id/", data);
  Future<ApiResponse> deletePatient(dynamic id) => delete("/patients/$id/");

  // ================= MEDICINES =================
  Future<ApiResponse> getMedicines({Map<String, dynamic>? params}) {
    String endpoint = "/medicines/";
    if (params != null && params.isNotEmpty) {
      final queryString = params.entries
          .where((e) => e.value != null && e.value.toString().isNotEmpty)
          .map((e) => "${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}")
          .join("&");
      if (queryString.isNotEmpty) {
        endpoint += "?$queryString";
      }
    }
    return get(endpoint);
  }

  Future<ApiResponse> getMedicine(dynamic id) => get("/medicines/$id/");
  Future<ApiResponse> createMedicine(Map<String, dynamic> data) => post("/medicines/", data);
  Future<ApiResponse> updateMedicine(dynamic id, Map<String, dynamic> data) => put("/medicines/$id/", data);
  Future<ApiResponse> deleteMedicine(dynamic id) => delete("/medicines/$id/");
  Future<ApiResponse> getLowStockMedicines() => get("/medicines/?low_stock=true");
  Future<ApiResponse> getExpiringMedicines() => get("/medicines/?expiring=true");
  Future<ApiResponse> getExpiredMedicines() => get("/medicines/?expired=true");

  // ================= CATEGORIES =================
  Future<ApiResponse> getCategories() => get("/medicines/categories/");
  Future<ApiResponse> getCategory(dynamic id) => get("/medicines/categories/$id/");
  Future<ApiResponse> createCategory(Map<String, dynamic> data) => post("/medicines/categories/", data);
  Future<ApiResponse> updateCategory(dynamic id, Map<String, dynamic> data) => put("/medicines/categories/$id/", data);
  Future<ApiResponse> deleteCategory(dynamic id) => delete("/medicines/categories/$id/");

  // ================= SUPPLIERS =================
  Future<ApiResponse> getSuppliers() => get("/medicines/suppliers/");
  Future<ApiResponse> getSupplier(dynamic id) => get("/medicines/suppliers/$id/");
  Future<ApiResponse> createSupplier(Map<String, dynamic> data) => post("/medicines/suppliers/", data);
  Future<ApiResponse> updateSupplier(dynamic id, Map<String, dynamic> data) => put("/medicines/suppliers/$id/", data);
  Future<ApiResponse> deleteSupplier(dynamic id) => delete("/medicines/suppliers/$id/");

  // ================= SALES =================
  Future<ApiResponse> getSales({Map<String, dynamic>? params}) {
    String endpoint = "/sales/";
    if (params != null && params.isNotEmpty) {
      final queryString = params.entries
          .where((e) => e.value != null && e.value.toString().isNotEmpty)
          .map((e) => "${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}")
          .join("&");
      if (queryString.isNotEmpty) {
        endpoint += "?$queryString";
      }
    }
    return get(endpoint);
  }

  Future<ApiResponse> getSale(dynamic id) => get("/sales/$id/");
  Future<ApiResponse> createSale(Map<String, dynamic> data) => post("/sales/", data);
  Future<ApiResponse> updateSale(dynamic id, Map<String, dynamic> data) => put("/sales/$id/", data);
  Future<ApiResponse> deleteSale(dynamic id) => delete("/sales/$id/");
  Future<ApiResponse> getDailySales() => get("/sales/daily/");
  Future<ApiResponse> getSalesReport({String? startDate, String? endDate}) {
    String endpoint = "/sales/report/";
    final params = <String>[];
    if (startDate != null && startDate.isNotEmpty) params.add("start_date=$startDate");
    if (endDate != null && endDate.isNotEmpty) params.add("end_date=$endDate");
    if (params.isNotEmpty) endpoint += "?${params.join("&")}";
    return get(endpoint);
  }

  // ================= PRESCRIPTIONS =================
  Future<ApiResponse> getPrescriptions({Map<String, dynamic>? params}) {
    String endpoint = "/prescriptions/";
    if (params != null && params.isNotEmpty) {
      final queryString = params.entries
          .where((e) => e.value != null && e.value.toString().isNotEmpty)
          .map((e) => "${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}")
          .join("&");
      if (queryString.isNotEmpty) {
        endpoint += "?$queryString";
      }
    }
    return get(endpoint);
  }

  Future<ApiResponse> getPrescription(dynamic id) => get("/prescriptions/$id/");
  Future<ApiResponse> createPrescription(Map<String, dynamic> data) => post("/prescriptions/", data);
  Future<ApiResponse> updatePrescription(dynamic id, Map<String, dynamic> data) => put("/prescriptions/$id/", data);
  Future<ApiResponse> deletePrescription(dynamic id) => delete("/prescriptions/$id/");
  Future<ApiResponse> dispensePrescription(dynamic id) => post("/prescriptions/$id/dispense/", {});
  Future<ApiResponse> cancelPrescription(dynamic id) => post("/prescriptions/$id/cancel/", {});
  Future<ApiResponse> getPrescriptionStats() => get("/prescriptions/stats/");

  // ================= CREDITS =================
  Future<ApiResponse> getCredits({Map<String, dynamic>? params}) {
    String endpoint = "/credits/";
    if (params != null && params.isNotEmpty) {
      final queryString = params.entries
          .where((e) => e.value != null && e.value.toString().isNotEmpty)
          .map((e) => "${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}")
          .join("&");
      if (queryString.isNotEmpty) {
        endpoint += "?$queryString";
      }
    }
    return get(endpoint);
  }

  Future<ApiResponse> getCredit(dynamic id) => get("/credits/$id/");
  Future<ApiResponse> createCredit(Map<String, dynamic> data) => post("/credits/", data);
  Future<ApiResponse> updateCredit(dynamic id, Map<String, dynamic> data) => put("/credits/$id/", data);
  Future<ApiResponse> deleteCredit(dynamic id) => delete("/credits/$id/");
  Future<ApiResponse> addCreditPayment(dynamic id, Map<String, dynamic> data) => post("/credits/$id/add_payment/", data);
  Future<ApiResponse> getOverdueCredits() => get("/credits/overdue/");

  // ================= EXPENSES =================
  Future<ApiResponse> getExpenses({Map<String, dynamic>? params}) {
    String endpoint = "/expenses/";
    if (params != null && params.isNotEmpty) {
      final queryString = params.entries
          .where((e) => e.value != null && e.value.toString().isNotEmpty)
          .map((e) => "${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}")
          .join("&");
      if (queryString.isNotEmpty) {
        endpoint += "?$queryString";
      }
    }
    return get(endpoint);
  }

  Future<ApiResponse> getExpense(dynamic id) => get("/expenses/$id/");
  Future<ApiResponse> createExpense(Map<String, dynamic> data) => post("/expenses/", data);
  Future<ApiResponse> updateExpense(dynamic id, Map<String, dynamic> data) => put("/expenses/$id/", data);
  Future<ApiResponse> deleteExpense(dynamic id) => delete("/expenses/$id/");

  // ================= STOCK TAKES =================
  Future<ApiResponse> getStockTakes({Map<String, dynamic>? params}) {
    String endpoint = "/stock-takes/";
    if (params != null && params.isNotEmpty) {
      final queryString = params.entries
          .where((e) => e.value != null && e.value.toString().isNotEmpty)
          .map((e) => "${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}")
          .join("&");
      if (queryString.isNotEmpty) {
        endpoint += "?$queryString";
      }
    }
    return get(endpoint);
  }

  Future<ApiResponse> getStockTake(dynamic id) => get("/stock-takes/$id/");
  Future<ApiResponse> createStockTake(Map<String, dynamic> data) => post("/stock-takes/", data);
  Future<ApiResponse> updateStockTake(dynamic id, Map<String, dynamic> data) => put("/stock-takes/$id/", data);
  Future<ApiResponse> deleteStockTake(dynamic id) => delete("/stock-takes/$id/");
  Future<ApiResponse> completeStockTake(dynamic id) => post("/stock-takes/$id/complete/", {});

  // ================= REPORTS =================
  Future<ApiResponse> getDashboard() => get("/dashboard/");
  Future<ApiResponse> getInventoryReport() => get("/reports/inventory/");
  Future<ApiResponse> getStaffReport() => get("/reports/staff/");
  Future<ApiResponse> getDailySalesReport() => get("/reports/daily_sales/");
  Future<ApiResponse> getLowStockReport() => get("/reports/low_stock/");
  Future<ApiResponse> getExpiredReport() => get("/reports/expired/");
  Future<ApiResponse> getFinancialSummary() => get("/reports/financial-summary/");
  Future<ApiResponse> getProfitAndLoss({String? startDate, String? endDate}) {
    String endpoint = "/reports/profit-loss/";
    final params = <String>[];
    if (startDate != null && startDate.isNotEmpty) params.add("start_date=$startDate");
    if (endDate != null && endDate.isNotEmpty) params.add("end_date=$endDate");
    if (params.isNotEmpty) endpoint += "?${params.join("&")}";
    return get(endpoint);
  }

  // ================= BARCODE SCANNING =================
  static Future<ApiResponse> getMedicineByBarcode(String barcode) async {
    final apiService = _getInstance();
    return await apiService.get('/medicines/barcode/$barcode/');
  }

  // ================= STATIC METHODS FOR EASY ACCESS =================
  
  static Future<List<dynamic>> getPatientsStatic({String? search}) async {
    final apiService = _getInstance();
    final response = await apiService.getPatients(search: search);
    if (response.isSuccess && response.data != null) {
      return response.data['results'] ?? response.data;
    }
    return [];
  }

  static Future<Map<String, dynamic>> createPatientStatic(Map<String, dynamic> data) async {
    final apiService = _getInstance();
    final response = await apiService.createPatient(data);
    if (response.isSuccess && response.data != null) {
      return response.data;
    }
    throw Exception('Failed to create patient: ${response.error}');
  }

  static Future<Map<String, dynamic>> createPrescriptionStatic(Map<String, dynamic> data) async {
    final apiService = _getInstance();
    final response = await apiService.createPrescription(data);
    if (response.isSuccess && response.data != null) {
      return response.data;
    }
    throw Exception('Failed to create prescription: ${response.error}');
  }

  static Future<List<dynamic>> getMedicinesStatic({Map<String, dynamic>? params}) async {
    final apiService = _getInstance();
    final response = await apiService.getMedicines(params: params);
    if (response.isSuccess && response.data != null) {
      return response.data['results'] ?? response.data;
    }
    return [];
  }

  static Future<Map<String, dynamic>> getDashboardStatic() async {
    final apiService = _getInstance();
    final response = await apiService.getDashboard();
    if (response.isSuccess && response.data != null) {
      return response.data;
    }
    return {};
  }
}