import 'package:prm_project/model/dto/request/login_request.dart';
import 'package:prm_project/model/dto/request/register_request.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import '../model/dto/response/auth_response.dart';
import 'package:dio/dio.dart';

class AuthService {
  final ApiService _api = ApiService();

  /// Login user
  Future<AuthResponse?> login(LoginRequest request) async {
    try {
      print('[AuthService] Sending LOGIN request with: ${request.toJson()}');
      final response = await _api.post('/Auth/login', data: request.toJson());
      return await _handleAuthResponse(response);
    } on DioException catch (e) {
      print('[AuthService] Login error: ${e.message}');
      if (e.response != null) {
        print('[AuthService] Login error response: ${e.response!.data}');
      }
      rethrow;
    }
  }

  /// Register user
  Future<AuthResponse?> register(RegisterRequest request) async {
    try {
      print('[AuthService] Sending REGISTER request with: ${request.toJson()}');
      final response = await _api.post(
        '/Auth/register',
        data: request.toJson(),
      );
      return await _handleAuthResponse(response);
    } on DioException catch (e) {
      print('[AuthService] Register error: ${e.message}');
      if (e.response != null) {
        print('[AuthService] Register error response: ${e.response!.data}');
      }
      rethrow;
    }
  }

  Future<User?> profile(String userId) async {
    try {
      print('[AuthService] Sending PROFILE request');
      final response = await _api.get('/Auth/id?userId=$userId');
      return response.statusCode == 200 ? User.fromJson(response.data) : null;
    } on DioException catch (e) {
      print('[AuthService] Register error: ${e.message}');
      if (e.response != null) {
        print('[AuthService] Register error response: ${e.response!.data}');
      }
      rethrow;
    }
  }

  /// Logout user
  Future<void> logout([String? token]) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    _api.setAuthToken(null);
  }

  /// Xử lý response chung cho login/register
  Future<AuthResponse?> _handleAuthResponse(Response response) async {
    if (response.statusCode == 200 && response.data != null) {
      final authResponse = AuthResponse.fromJson(response.data);

      final token = authResponse.data.token;
      if (token.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        _api.setAuthToken(token); // set header cho các request tiếp theo
      }

      return authResponse;
    }
    return null; // trả null nếu không có token hoặc statusCode != 200
  }
}
