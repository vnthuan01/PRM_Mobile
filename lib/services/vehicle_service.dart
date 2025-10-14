import 'api_service.dart';

class VehicleService {
  final ApiService _api = ApiService();

  Future<List<dynamic>> getCustomerVehicles(String customerId) async {
    final response = await _api.get(
      '/vehicles',
      queryParameters: {'customerId': customerId},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getVehicleDetail(String id) async {
    final response = await _api.get('/vehicles/$id');
    return response.data;
  }
}
