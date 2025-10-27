import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prm_project/services/api_service.dart';
import 'package:prm_project/services/auth_service.dart';
import 'package:prm_project/services/user_service.dart';
import 'package:prm_project/model/dto/request/login_request.dart';
import 'package:prm_project/model/dto/request/register_request.dart';
import 'package:prm_project/model/dto/response/auth_response.dart';
import 'package:prm_project/model/customer.dart';
import 'package:prm_project/model/staff.dart';
import 'maintence_provider.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _repository;
  final CustomerService _customerService = CustomerService();
  final ApiService _api = ApiService();

  bool isLoading = false;
  String? error;
  AuthResponse? auth;
  String? _token;
  Customer? _customer;
  Staff? _staff;

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
        _api.setAuthToken(_token!);

        // Fetch user data based on role
        await _fetchUserData(response.data.user.id);

        error = null;
        success = true;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('userId', response.data.user.id);
      } else {
        error = "Đăng nhập thất bại. Vui lòng thử lại.";
      }
    } on DioException catch (e) {
      error = _parseDioError(e);
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
        _api.setAuthToken(_token!);

        await _fetchUserData(response.data.user.id);

        error = null;
        success = true;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('userId', response.data.user.id);
      } else {
        error = "Đăng ký thất bại. Vui lòng thử lại.";
      }
    } on DioException catch (e) {
      error = _parseDioError(e);
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
      await _repository.logout();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('userId');
    } catch (_) {
      // ignore errors
    } finally {
      auth = null;
      _token = null;
      _customer = null;
      _staff = null;
      notifyListeners();
    }
  }

  // ---- RESTORE SESSION ----
  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('token');
    final savedUserId = prefs.getString('userId');

    if (savedToken != null && savedToken.isNotEmpty) {
      try {
        _token = savedToken;
        _api.setAuthToken(savedToken);

        User? user;
        if (savedUserId != null && savedUserId.isNotEmpty) {
          user = await _repository.profile(savedUserId);
        }

        if (user != null) {
          auth = AuthResponse(
            isSuccess: true,
            message: 'Phiên đăng nhập đã được khôi phục',
            data: AuthData(
              message: 'Session restored',
              token: savedToken,
              expiresAt: DateTime.now()
                  .add(const Duration(days: 7))
                  .toIso8601String(),
              user: user,
            ),
          );

          await _fetchUserData(user.id);
        }

        _customer ??= null;
        notifyListeners();
      } catch (e) {
        print('[AuthProvider] Failed to restore session: $e');
        auth = null;
        _token = null;
        _customer = null;
        _staff = null;
        notifyListeners();
      }
    }
  }

  // ---- FETCH USER DATA ----
  Future<void> _fetchUserData(String userId) async {
    try {
      final userRole = auth?.data.user.role;

      if (userRole == 1) {
        // Customer - fetch customer data
        final customer = await _customerService.getCustomerByUserId(userId);
        if (customer != null && customer.id!.isNotEmpty) {
          _customer = customer;
          _staff = null;
          print('[AuthProvider] Loaded customerId: ${customer.id}');
        } else {
          print('[AuthProvider] Customer not found for userId: $userId');
          _customer = null;
        }
      } else if (userRole == 2) {
        // Technician - fetch staff data
        final staff = await _customerService.getStaffByUserId(userId);
        if (staff != null && staff.staffId.isNotEmpty) {
          _staff = staff;
          _customer = null;
          print('[AuthProvider] Loaded staffId: ${staff.staffId}');
        } else {
          print('[AuthProvider] Staff not found for userId: $userId');
          _staff = null;
        }
      } else {
        print('[AuthProvider] Unknown user role: $userRole');
        _customer = null;
        _staff = null;
      }
    } catch (e) {
      print('[AuthProvider] Failed to fetch user data: $e');
      _customer = null;
      _staff = null;
    }
  }

  // ---- PARSE ERROR ----
  String _parseDioError(DioException e) {
    if (e.response != null && e.response?.data != null) {
      if (e.response!.data is Map<String, dynamic> &&
          e.response!.data['message'] != null) {
        return e.response!.data['message'].toString();
      } else {
        return e.response!.data.toString();
      }
    }
    return e.message ?? "Lỗi kết nối server.";
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

  // ---- GETTERS ----
  bool get isLoggedIn => _token != null && _token!.isNotEmpty;
  String? get token => _token;
  User? get currentUser => auth?.data.user;
  Customer? get currentCustomer => _customer;
  Staff? get currentStaff => _staff;
  String? get customerId => _customer?.id;
  String? get staffId => _staff?.staffId;

  // Get user role as UserRole enum
  UserRole? get userRole {
    if (auth?.data.user.role != null) {
      return UserRole.fromValue(auth!.data.user.role);
    }
    return null;
  }

  // Check if user is a technician
  bool get isTechnician => userRole == UserRole.Technician;

  // Check if user is a customer
  bool get isCustomer => userRole == UserRole.Customer;
}
