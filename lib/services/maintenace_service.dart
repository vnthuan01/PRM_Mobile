import 'package:dio/dio.dart';
import '../model/maintenance.dart';
import '../model/dto/request/maintenance_status_request.dart';
import 'api_service.dart';

class MaintenanceService {
  final ApiService _api = ApiService();

  Future<List<Maintenance>> getMaintenanceByStaffId({
    required String staffId,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      print(
        '[MaintenanceService] GET /api/Maintenance/staff/$staffId?pageNumber=$pageNumber&pageSize=$pageSize',
      );
      final response = await _api.get(
        '/api/Maintenance/staff/$staffId',
        queryParameters: {'pageNumber': pageNumber, 'pageSize': pageSize},
      );

      if (response.statusCode == 200) {
        final data = response.data as List;
        final maintenances = data.map((e) => Maintenance.fromJson(e)).toList();
        print('[MaintenanceService] Found ${maintenances.length} maintenances');
        return maintenances;
      }
      return [];
    } on DioException catch (e) {
      print('[MaintenanceService] getMaintenanceByStaffId error: ${e.message}');
      if (e.response != null)
        print('[MaintenanceService] Error response: ${e.response!.data}');
      rethrow;
    }
  }

  Future<bool> updateMaintenanceStatus({
    required String maintenanceId,
    required MaintenanceStatusRequest request,
  }) async {
    try {
      print(
        '[MaintenanceService] PATCH /api/Maintenance/$maintenanceId/status with data: ${request.toJson()}',
      );
      final response = await _api.patch(
        '/api/Maintenance/$maintenanceId/status',
        request.toJson(),
      );

      if (response.statusCode == 200) {
        print('[MaintenanceService] Updated successfully');
        return true;
      }
      return false;
    } on DioException catch (e) {
      print('[MaintenanceService] updateMaintenanceStatus error: ${e.message}');
      if (e.response != null)
        print('[MaintenanceService] Error response: ${e.response!.data}');
      rethrow;
    }
  }
}
