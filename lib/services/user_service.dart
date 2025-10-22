import 'package:dio/dio.dart';
import 'package:prm_project/model/customer.dart';
import 'package:prm_project/services/api_service.dart';

class CustomerService {
  final ApiService _api = ApiService();

  /// Lấy danh sách booking của khách hàng
  Future<Customer> getCustomerByUserId(String userId) async {
    try {
      print('[CustomerService] Fetching GET /Customer/user?userId=$userId');
      final response = await _api.get(
        '/Customer/user',
        queryParameters: {'userId': userId},
      );

      if (response.statusCode == 200) {
        final customer = Customer.fromJson(response.data);
        print('[CustomerService] Found $customer');
        return customer;
      }
      return Customer(
        id: '',
        userId: '',
        address: '',
        status: '',
        createdAt: '',
      );
    } on DioException catch (e) {
      print('[CustomerService] getCustomerByUserId error: ${e.message}');
      if (e.response != null) {
        print('[CustomerService] Error response: ${e.response!.data}');
      }
      rethrow;
    }
  }
}
