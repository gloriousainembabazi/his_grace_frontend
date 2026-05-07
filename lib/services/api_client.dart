import 'package:dio/dio.dart';
import 'api_exception.dart';

class ApiClient {
  final Dio dio;

  ApiClient(this.dio);

  Future<dynamic> get(String url, {Map<String, dynamic>? query}) async {
    try {
      final response = await dio.get(url, queryParameters: query);
      return response.data;
    } catch (e) {
      throw ApiException(_handleError(e));
    }
  }

  Future<dynamic> post(String url, dynamic data) async {
    try {
      final response = await dio.post(url, data: data);
      return response.data;
    } catch (e) {
      throw ApiException(_handleError(e));
    }
  }

  Future<dynamic> put(String url, dynamic data) async {
    try {
      final response = await dio.put(url, data: data);
      return response.data;
    } catch (e) {
      throw ApiException(_handleError(e));
    }
  }

  Future<dynamic> delete(String url) async {
    try {
      final response = await dio.delete(url);
      return response.data;
    } catch (e) {
      throw ApiException(_handleError(e));
    }
  }

  Future<dynamic> uploadMultipart(
    String url, {
    required String filePath,
    required String fileField,
    required Map<String, dynamic> fields,
  }) async {
    try {
      final formData = FormData.fromMap({
        ...fields,
        fileField: await MultipartFile.fromFile(filePath),
      });

      final response = await dio.post(url, data: formData);
      return response.data;
    } catch (e) {
      throw ApiException(_handleError(e));
    }
  }

  String _handleError(dynamic e) {
    if (e is DioException) {
      return e.response?.data['detail'] ?? e.message;
    }
    return e.toString();
  }
}