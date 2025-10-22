import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:prm_project/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../model/dto/request/login_request.dart';
import '../model/dto/request/register_request.dart';
import '../model/dto/response/auth_response.dart';
import '../model/customer.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _repository;
  final CustomerService _customerService = CustomerService();
  final ApiService _api = ApiService();

  bool isLoading = false;
  String? error;
  AuthResponse? auth;
  String? _token; // thêm biến token riêng
  Customer? _customer; // thêm biến customer

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

        // Fetch customer data after successful login
        await _fetchCustomerData(response.data.user.id);

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

        // Fetch customer data after successful registration
        await _fetchCustomerData(response.data.user.id);

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
      _customer = null;
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

      // Try to fetch customer data if user is logged in
      if (auth?.data.user.id.isNotEmpty == true) {
        await _fetchCustomerData(auth!.data.user.id);
      }

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

  // ---- FETCH CUSTOMER DATA ----
  Future<void> _fetchCustomerData(String userId) async {
    try {
      final customer = await _customerService.getCustomerByUserId(userId);
      _customer = customer;
    } catch (e) {
      print('[AuthProvider] Failed to fetch customer data: $e');
      // Don't set error here as it's not critical for login
    }
  }

  // ---- GETTERS ----
  bool get isLoggedIn =>
      (_token != null && _token!.isNotEmpty) && (auth?.data.user != null);

  String? get token => _token;
  User? get currentUser => auth?.data.user;
  Customer? get currentCustomer => _customer;
  String? get customerId => _customer?.id;
}
