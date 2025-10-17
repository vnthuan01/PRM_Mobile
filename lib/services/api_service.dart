import 'dart:io' show HttpClient, X509Certificate, Platform;
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  late final Dio _dio;

  factory ApiService() => _instance;

  ApiService._internal() {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? '';
    print(
      '[ApiService] API_BASE_URL: $baseUrl (kIsWeb: $kIsWeb, Platform info: ${!kIsWeb ? Platform.operatingSystem : 'web'})',
    );

    if (baseUrl.isEmpty) {
      throw Exception(
        '[ApiService] Missing API_BASE_URL. Please check your .env file.',
      );
    }

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    //Bỏ qua SSL (chỉ dev, không web)
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };
      print(
        '[ApiService] SSL bypass ENABLED (development mode; do NOT use in production)',
      );
    }

    //Gắn interceptor log cho debug
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print('[DIO] $obj'),
      ),
    );
  }

  Dio get dio => _dio;

  //Lưu token cho tất cả request sau khi login
  void setAuthToken(String? token) {
    if (token != null && token.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
      print('[ApiService] Authorization header set');
    } else {
      _dio.options.headers.remove('Authorization');
      print('[ApiService] Authorization header cleared');
    }
  }

  //Các hàm request chung
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _dio.get(path, queryParameters: queryParameters, options: options);

  Future<Response> post(String path, dynamic data, {Options? options}) =>
      _dio.post(path, data: data, options: options);

  Future<Response> put(String path, dynamic data, {Options? options}) =>
      _dio.put(path, data: data, options: options);

  Future<Response> patch(String path, [dynamic data]) async {
    return _dio.patch(path, data: data);
  }

  Future<Response> delete(String path, {dynamic data, Options? options}) =>
      _dio.delete(path, data: data, options: options);
}
