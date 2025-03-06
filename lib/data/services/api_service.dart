// lib/data/services/api_service.dart
import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio;
  final String baseUrl = 'https://your-api-url.com';

  ApiService() : _dio = Dio() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 3);
  }

  Future<Response> get(String path, {Map<String, dynamic>? params}) async {
    try {
      final response = await _dio.get(path, queryParameters: params);
      return response;
    } on DioError catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioError error) {
    switch (error.type) {
      case DioErrorType.connectionTimeout:
        return Exception('Connection timeout');
      case DioErrorType.receiveTimeout:
        return Exception('Receive timeout');
      case DioErrorType.badResponse:
        return Exception('Bad response: ${error.response?.statusCode}');
      default:
        return Exception('Something went wrong');
    }
  }
}
