import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'storage_service.dart';

class ApiService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Accept': 'application/json'},
  ));

  static void init() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await StorageService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) => handler.next(error),
    ));
  }

  static Future<Response> post(String path, Map<String, dynamic> data) =>
      _dio.post(path, data: data);

static Future<Response> patch(String path, Map<String, dynamic> data) =>
    _dio.patch(path, data: data);
    
  static Future<Response> get(String path) => _dio.get(path);

  static Future<Response> put(String path, Map<String, dynamic> data) =>
      _dio.put(path, data: data);

  static Future<Response> delete(String path) => _dio.delete(path);
}