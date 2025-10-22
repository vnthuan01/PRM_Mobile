import 'package:dio/dio.dart';
import '../model/dto/request/vehicle_request.dart';
import '../model/dto/response/vehicle_response.dart';
import 'api_service.dart';

class VehicleService {
  final ApiService _api = ApiService();

  Future<List<VehicleResponse>> getCustomerVehicles(String customerId) async {
    try {
      print('[VehicleService] GET /api/Vehicle/customer/$customerId');
      final response = await _api.get('/Vehicle/customer/$customerId');

      if (response.statusCode == 200) {
        final body = response.data;

        // Xử lý trường hợp API trả về list hoặc object chứa list
        final list = body is List
            ? body
            : (body['data'] is List ? body['data'] : []);

        final vehicles = list
            .map<VehicleResponse>((e) => VehicleResponse.fromJson(e))
            .toList();

        print('[VehicleService] Found ${vehicles.length} vehicles');
        return vehicles;
      } else {
        throw Exception('Failed to load vehicles (${response.statusCode})');
      }
    } on DioException catch (e) {
      print('[VehicleService] getCustomerVehicles error: ${e.message}');
      if (e.response != null) {
        print('[VehicleService] Error response: ${e.response!.data}');
      }
      rethrow;
    } catch (e) {
      print('[VehicleService] Unexpected error: $e');
      return [];
    }
  }

  Future<VehicleResponse?> getVehicleDetail(String id) async {
    try {
      print('[VehicleService] GET /api/Vehicle/$id');
      final response = await _api.get('/Vehicle/$id');

      if (response.statusCode == 200) {
        final vehicle = VehicleResponse.fromJson(response.data);
        print('[VehicleService] Found vehicle: $vehicle');
        return vehicle;
      }
      return null;
    } on DioException catch (e) {
      print('[VehicleService] getVehicleDetail error: ${e.message}');
      if (e.response != null)
        print('[VehicleService] Error response: ${e.response!.data}');
      rethrow;
    }
  }

  Future<VehicleResponse?> createVehicle(VehicleRequest request) async {
    try {
      final data = request.toJson();
      print('[VehicleService] POST /api/Vehicle with data: $data');
      final response = await _api.post('/Vehicle', data: data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final createdVehicle = VehicleResponse.fromJson(response.data);
        print('[VehicleService] Created vehicle: $createdVehicle');
        return createdVehicle;
      }
      return null;
    } on DioException catch (e) {
      print('[VehicleService] createVehicle error: ${e.message}');
      if (e.response != null)
        print('[VehicleService] Error response: ${e.response!.data}');
      rethrow;
    }
  }

  Future<VehicleResponse?> updateVehicle(
    String id,
    VehicleRequest request,
  ) async {
    try {
      final data = request.toJson();
      print('[VehicleService] PUT /api/Vehicle/$id with data: $data');
      final response = await _api.put('/Vehicle/$id', data: data);

      if (response.statusCode == 200) {
        final updatedVehicle = VehicleResponse.fromJson(response.data);
        print('[VehicleService] Updated vehicle: $updatedVehicle');
        return updatedVehicle;
      }
      return null;
    } on DioException catch (e) {
      print('[VehicleService] updateVehicle error: ${e.message}');
      if (e.response != null)
        print('[VehicleService] Error response: ${e.response!.data}');
      rethrow;
    }
  }

  Future<bool> deleteVehicle(String id) async {
    try {
      print('[VehicleService] DELETE /api/Vehicle/$id');
      final response = await _api.delete('/Vehicle/$id');

      if (response.statusCode == 200) {
        print('[VehicleService] Deleted vehicle $id');
        return true;
      }
      return false;
    } on DioException catch (e) {
      print('[VehicleService] deleteVehicle error: ${e.message}');
      if (e.response != null)
        print('[VehicleService] Error response: ${e.response!.data}');
      rethrow;
    }
  }
}
