import 'package:dio/dio.dart';
import '../model/maintenance.dart';
import '../model/dto/request/maintenance_status_request.dart';
import 'api_service.dart';

class MaintenanceService {
  final ApiService _api = ApiService();

  Future<Maintenance?> getMaintenanceById(String maintenanceId) async {
    try {
      print('[MaintenanceService] GET /api/Maintenance/$maintenanceId');
      final response = await _api.get('/Maintenance/$maintenanceId');

      if (response.statusCode == 200) {
        print('[MaintenanceService] Response status: ${response.statusCode}');
        print('[MaintenanceService] Response data: ${response.data}');

        // Handle both direct object and wrapped response
        dynamic maintenanceData;
        if (response.data is Map<String, dynamic> &&
            response.data.containsKey('data')) {
          maintenanceData = response.data['data'];
        } else {
          maintenanceData = response.data;
        }

        if (maintenanceData != null) {
          final maintenance = Maintenance.fromJson(maintenanceData);
          print(
            '[MaintenanceService] Parsed maintenance: ${maintenance.maintenanceId}',
          );
          return maintenance;
        }
      }
      return null;
    } on DioException catch (e) {
      print('[MaintenanceService] getMaintenanceById error: ${e.message}');
      if (e.response != null) {
        print('[MaintenanceService] Error response: ${e.response!.data}');
      }
      rethrow;
    }
  }

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
        '/Maintenance/staff/$staffId',
        queryParameters: {'pageNumber': pageNumber, 'pageSize': pageSize},
      );

      print('[MaintenanceService] Response status: ${response.statusCode}');
      print('[MaintenanceService] Response data: ${response.data}');

      if (response.statusCode == 200) {
        if (response.data is List) {
          final data = response.data as List;
          final maintenances = data
              .map((e) => Maintenance.fromJson(e))
              .toList();
          print(
            '[MaintenanceService] Found ${maintenances.length} maintenances for staff',
          );
          return maintenances;
        } else if (response.data is Map && response.data['data'] is List) {
          final data = response.data['data'] as List;
          final maintenances = data
              .map((e) => Maintenance.fromJson(e))
              .toList();
          print(
            '[MaintenanceService] Found ${maintenances.length} maintenances for staff (wrapped)',
          );
          return maintenances;
        } else {
          print(
            '[MaintenanceService] Unexpected response format: ${response.data}',
          );
          return [];
        }
      }
      return [];
    } on DioException catch (e) {
      print('[MaintenanceService] getMaintenanceByStaffId error: ${e.message}');
      if (e.response != null)
        print('[MaintenanceService] Error response: ${e.response!.data}');
      rethrow;
    }
  }

  Future<List<Maintenance>> getMaintenanceByCustomerId({
    required String customerId,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      print(
        '[MaintenanceService] GET /api/Maintenance/customer/$customerId?pageNumber=$pageNumber&pageSize=$pageSize',
      );
      final response = await _api.get(
        '/Maintenance/customer/$customerId',
        queryParameters: {'pageNumber': pageNumber, 'pageSize': pageSize},
      );

      print('[MaintenanceService] Response status: ${response.statusCode}');
      print('[MaintenanceService] Response data: ${response.data}');

      if (response.statusCode == 200) {
        if (response.data is List) {
          final data = response.data as List;
          final maintenances = data
              .map((e) => Maintenance.fromJson(e))
              .toList();
          print(
            '[MaintenanceService] Found ${maintenances.length} maintenances for customer',
          );
          return maintenances;
        } else if (response.data is Map && response.data['data'] is List) {
          final data = response.data['data'] as List;
          final maintenances = data
              .map((e) => Maintenance.fromJson(e))
              .toList();
          print(
            '[MaintenanceService] Found ${maintenances.length} maintenances for customer (wrapped)',
          );
          return maintenances;
        } else {
          print(
            '[MaintenanceService] Unexpected response format: ${response.data}',
          );
          return [];
        }
      }
      return [];
    } on DioException catch (e) {
      print(
        '[MaintenanceService] getMaintenanceByCustomerId error: ${e.message}',
      );
      if (e.response != null)
        print('[MaintenanceService] Error response: ${e.response!.data}');
      rethrow;
    }
  }

  Future<List<Maintenance>> getMaintenanceByStatus(int status) async {
    try {
      print('[MaintenanceService] GET /api/Maintenance/status/$status');
      final response = await _api.get('/Maintenance/status/$status');

      print('[MaintenanceService] Response status: ${response.statusCode}');
      print('[MaintenanceService] Response data: ${response.data}');

      if (response.statusCode == 200) {
        if (response.data is List) {
          final data = response.data as List;
          final maintenances = data
              .map((e) => Maintenance.fromJson(e))
              .toList();
          print(
            '[MaintenanceService] Found ${maintenances.length} maintenances with status $status',
          );
          return maintenances;
        } else if (response.data is Map && response.data['data'] is List) {
          final data = response.data['data'] as List;
          final maintenances = data
              .map((e) => Maintenance.fromJson(e))
              .toList();
          print(
            '[MaintenanceService] Found ${maintenances.length} maintenances with status $status (wrapped)',
          );
          return maintenances;
        } else {
          print(
            '[MaintenanceService] Unexpected response format: ${response.data}',
          );
          return [];
        }
      }
      return [];
    } on DioException catch (e) {
      print('[MaintenanceService] getMaintenanceByStatus error: ${e.message}');
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
        '/Maintenance/$maintenanceId/status',
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
