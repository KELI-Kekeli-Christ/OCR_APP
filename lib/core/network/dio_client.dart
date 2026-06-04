import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import 'retry_interceptor.dart';

class DioClient {
  DioClient({String? baseUrl, String? apiToken}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? AppConstants.defaultBackendUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.apiTimeout,
        headers: {
          'Content-Type': 'application/json',
          if (apiToken != null && apiToken.isNotEmpty)
            'Authorization': 'Bearer $apiToken',
        },
      ),
    );
    _dio.interceptors.addAll([
      RetryInterceptor(),
      LogInterceptor(requestBody: false, responseBody: false),
    ]);
  }

  late final Dio _dio;
  Dio get dio => _dio;

  void updateBaseUrl(String url) {
    _dio.options.baseUrl = url;
  }

  void updateToken(String? token) {
    if (token == null || token.isEmpty) {
      _dio.options.headers.remove('Authorization');
    } else {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }
}
