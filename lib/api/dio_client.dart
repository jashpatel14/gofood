import 'package:dio/dio.dart';
import '../core/constants/app_constants.dart';

class DioClient {
  static DioClient? _instance;
  late final Dio dio;
  String? _token;

  DioClient._() {
    dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Request interceptor — inject auth token
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        // Log errors in debug mode
        if (error.response?.statusCode == 401) {
          // Token expired — could redirect to login
        }
        return handler.next(error);
      },
    ));
  }

  static DioClient get instance {
    _instance ??= DioClient._();
    return _instance!;
  }

  void setToken(String token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  // GET request
  Future<Response> get(String path, {Map<String, dynamic>? queryParams}) async {
    return dio.get(path, queryParameters: queryParams);
  }

  // POST request
  Future<Response> post(String path, {dynamic data}) async {
    return dio.post(path, data: data);
  }

  // PUT request
  Future<Response> put(String path, {dynamic data}) async {
    return dio.put(path, data: data);
  }

  // DELETE request
  Future<Response> delete(String path) async {
    return dio.delete(path);
  }
}
