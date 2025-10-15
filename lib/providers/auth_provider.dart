import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:prm_project/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../model/login_request.dart';
import '../model/register_request.dart';
import '../model/auth_response.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _repository;
  final ApiService _api = ApiService();

  bool isLoading = false;
  String? error;
  AuthResponse? auth;
  String? _token; // thêm biến token riêng

  AuthProvider(this._repository);

  // ---- LOGIN ----
  Future<bool> login(LoginRequest request) async {
    setIsLoading(true);
    bool success = false;
    try {
      final response = await _repository.login(request);

      if (response != null && response.data.token.isNotEmpty) {
        auth = response;
        _token = response.data.token;
        error = null;
        success = true;
      } else {
        error = "Đăng nhập thất bại. Vui lòng thử lại.";
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        if (e.response!.data is Map<String, dynamic> &&
            e.response!.data['message'] != null) {
          error = e.response!.data['message'].toString();
        } else {
          error = e.response!.data.toString();
        }
      } else {
        error = e.message ?? "Lỗi kết nối server.";
      }
    } catch (e) {
      error = e.toString();
    } finally {
      setIsLoading(false);
    }
    return success;
  }

  // ---- REGISTER ----
  Future<bool> register(RegisterRequest request) async {
    setIsLoading(true);
    bool success = false;
    try {
      final response = await _repository.register(request);

      if (response != null && response.data.token.isNotEmpty) {
        auth = response;
        _token = response.data.token;
        error = null;
        success = true;
      } else {
        error = "Đăng ký thất bại. Vui lòng thử lại.";
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        if (e.response!.data is Map<String, dynamic> &&
            e.response!.data['message'] != null) {
          error = e.response!.data['message'].toString();
        } else {
          error = e.response!.data.toString();
        }
      } else {
        error = e.message ?? "Lỗi kết nối server.";
      }
    } catch (e) {
      error = e.toString();
    } finally {
      setIsLoading(false);
    }
    return success;
  }

  // ---- LOGOUT ----
  Future<void> logout() async {
    try {
      if (_token != null && _token!.isNotEmpty) {
        await _repository.logout();
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
    } catch (_) {
      // Không hiển thị lỗi khi logout
    } finally {
      auth = null;
      _token = null;
      notifyListeners();
    }
  }

  // ---- RESTORE SESSION ----
  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('token');

    if (savedToken != null && savedToken.isNotEmpty) {
      _api.setAuthToken(savedToken);

      auth = AuthResponse(
        isSuccess: true,
        message: 'Session restored successfully',

        data: AuthData(
          message: 'Session restored successfully',

          token: savedToken,
          expiresAt: DateTime.now()
              .add(const Duration(days: 7))
              .toIso8601String(),
          user: User.empty(),
        ),
      );
      notifyListeners();
    }
  }

  // ---- STATE HELPERS ----
  void setIsLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void clearError() {
    if (error != null) {
      error = null;
      notifyListeners();
    }
  }

  bool get isLoggedIn =>
      (_token != null && _token!.isNotEmpty) && (auth?.data.user != null);

  String? get token => _token;
  User? get currentUser => auth?.data.user;
}
