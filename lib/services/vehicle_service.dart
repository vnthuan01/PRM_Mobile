import 'package:dio/dio.dart';
import '../model/vehicle.dart';
import 'api_service.dart';

class VehicleService {
  final ApiService _api = ApiService();

  /// Lấy danh sách xe của 1 khách hàng
  Future<List<Vehicle>> getCustomerVehicles(String customerId) async {
    try {
      print('[VehicleService] GET /api/Vehicle/customer/$customerId');
      final response = await _api.get('/api/Vehicle/customer/$customerId');

      if (response.statusCode == 200) {
        final data = response.data as List;
        final vehicles = data.map((e) => Vehicle.fromJson(e)).toList();
        print('[VehicleService] Found ${vehicles.length} vehicles');
        return vehicles;
      }

      return [];
    } on DioException catch (e) {
      print('[VehicleService] getCustomerVehicles error: ${e.message}');
      if (e.response != null)
        print('[VehicleService] Error response: ${e.response!.data}');
      rethrow;
    }
  }

  /// Lấy chi tiết 1 xe
  Future<Vehicle?> getVehicleDetail(String id) async {
    try {
      print('[VehicleService] GET /api/Vehicle/$id');
      final response = await _api.get('/api/Vehicle/$id');

      if (response.statusCode == 200) {
        final vehicle = Vehicle.fromJson(response.data);
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

  /// Tạo xe mới
  Future<Vehicle?> createVehicle(Vehicle vehicle) async {
    try {
      final data = vehicle.toJson();
      print('[VehicleService] POST /api/Vehicle with data: $data');
      final response = await _api.post('/api/Vehicle', data: data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final createdVehicle = Vehicle.fromJson(response.data);
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

  /// Cập nhật xe
  Future<Vehicle?> updateVehicle(String id, Vehicle vehicle) async {
    try {
      final data = vehicle.toJson();
      print('[VehicleService] PUT /api/Vehicle/$id with data: $data');
      final response = await _api.put('/api/Vehicle/$id', data: data);

      if (response.statusCode == 200) {
        final updatedVehicle = Vehicle.fromJson(response.data);
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

  /// Xoá xe
  Future<bool> deleteVehicle(String id) async {
    try {
      print('[VehicleService] DELETE /api/Vehicle/$id');
      final response = await _api.delete('/api/Vehicle/$id');

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
