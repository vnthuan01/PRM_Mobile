import 'package:dio/dio.dart';
import 'package:prm_project/model/customer.dart';
import 'package:prm_project/model/dto/response/auth_response.dart';
import 'package:prm_project/model/staff.dart';
import 'package:prm_project/services/api_service.dart';

class CustomerService {
  final ApiService _api = ApiService();

  Future<User?> getUserById(String userId) async {
    try {
      print('[UserService] GET /api/Auth/id?$userId');
      final response = await _api.get('/Auth/id?$userId');

      if (response.statusCode == 200 && response.data != null) {
        return User.fromJson(response.data);
      }

      print('[UserService] Unexpected response: ${response.data}');
      return null;
    } on DioException catch (e) {
      print('[UserService] Error: ${e.message}');
      return null;
    }
  }

  Future<Customer?> getCustomerByUserId(String userId) async {
    try {
      print('[CustomerService] Fetching GET /Customer/user/$userId');
      final response = await _api.get('/Customer/user/$userId');

      if (response.statusCode == 200) {
        final customer = Customer.fromJson(response.data);
        print('[CustomerService] Found $customer');
        return customer;
      }
      return null;
    } on DioException catch (e) {
      print('[CustomerService] getCustomerByUserId error: ${e.message}');
      if (e.response != null) {
        print('[CustomerService] Error response: ${e.response!.data}');
      }
      // Return null instead of rethrowing for technicians who don't have customer records
      return null;
    }
  }

  Future<Customer?> getCustomerByCustomerId(String customerId) async {
    try {
      print('[CustomerService] Fetching GET /Customer/$customerId');
      final response = await _api.get('/Customer/$customerId');

      if (response.statusCode == 200) {
        print('[CustomerService] Response: ${response.data}');

        //Check structure before parsing
        if (response.data is Map<String, dynamic>) {
          final json = response.data;

          //Some APIs wrap the data, some don't
          final customerData = json.containsKey('data') ? json['data'] : json;

          if (json['isSuccess'] == true && customerData != null) {
            final customer = Customer.fromJson(customerData);
            print('[CustomerService] Found ${customer.toJson()}');
            return customer;
          } else {
            print(
              '[CustomerService] Failed: ${json['message'] ?? "No message"}',
            );
            return null;
          }
        }
      }

      print('[CustomerService] Non-200 response: ${response.statusCode}');
      return null;
    } on DioException catch (e) {
      print('[CustomerService] getCustomerByCustomerId error: ${e.message}');
      if (e.response != null) {
        print('[CustomerService] Error response: ${e.response!.data}');
      }
      //Return null instead of rethrowing (avoid crashing)
      return null;
    } catch (e) {
      print('[CustomerService] Unexpected error: $e');
      return null;
    }
  }

  Future<Staff?> getStaffByStaffId(String staffId) async {
    try {
      print('[StaffService] Fetching GET /Staff/$staffId');
      final response = await _api.get('/Staff/$staffId');
      if (response.statusCode == 200) {
        final staffData = response.data['data'];
        if (staffData != null) {
          final staff = Staff.fromJson(staffData);
          print('[StaffService] Found $staff');
          return staff;
        }
      }
      return null;
    } on DioException catch (e) {
      print('[StaffService] getStaffByUserId error: ${e.message}');
      if (e.response != null) {
        print('[StaffService] Error response: ${e.response!.data}');
      }
      return null;
    }
  }

  Future<Staff?> getStaffByUserId(String userId) async {
    try {
      print('[StaffService] Fetching GET /Staff/userId?userId=$userId');
      final response = await _api.get('/Staff/userId?userId=$userId');
      if (response.statusCode == 200) {
        final staffData = response.data['data'];
        if (staffData != null) {
          final staff = Staff.fromJson(staffData);
          print('[StaffService] Found $staff');
          return staff;
        }
      }
      return null;
    } on DioException catch (e) {
      print('[StaffService] getStaffByUserId error: ${e.message}');
      if (e.response != null) {
        print('[StaffService] Error response: ${e.response!.data}');
      }
      return null;
    }
  }
}
