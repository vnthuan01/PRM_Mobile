import 'package:flutter/material.dart';
import 'package:prm_project/model/dto/request/vehicle_request.dart';
import 'package:prm_project/model/dto/response/vehicle_response.dart';
import '../services/vehicle_service.dart';

class VehicleProvider extends ChangeNotifier {
  final VehicleService vehicleService;

  VehicleProvider({required this.vehicleService});

  List<VehicleResponse> _vehicles = [];

  List<VehicleResponse> get vehicles => _vehicles;

  Future<VehicleResponse> createVehicle(VehicleRequest request) async {
    try {
      final created = await vehicleService.createVehicle(request);
      if (created != null) {
        await fetchVehicles(request.customerId);
        return created;
      }
      throw Exception('Failed to create vehicle');
    } catch (e) {
      print('[VehicleProvider] createVehicle error: $e');
      rethrow;
    }
  }

  Future<List<VehicleResponse>> fetchVehicles(String customerId) async {
    try {
      final result = await vehicleService.getCustomerVehicles(customerId);
      _vehicles = result;
      notifyListeners();
      return result;
    } catch (e) {
      print('[VehicleProvider] fetchVehicles error: $e');
      return [];
    }
  }

  Future<VehicleResponse?> getVehicleDetail(String id) async {
    try {
      final vehicle = await vehicleService.getVehicleDetail(id);
      return vehicle;
    } catch (e) {
      print('[VehicleProvider] getVehicleDetail error: $e');
      rethrow;
    }
  }

  Future<VehicleResponse?> updateVehicle(
    String id,
    VehicleRequest request,
  ) async {
    try {
      final updated = await vehicleService.updateVehicle(id, request);
      if (updated != null) {
        await fetchVehicles(request.customerId);
        return updated;
      }
      return null;
    } catch (e) {
      print('[VehicleProvider] updateVehicle error: $e');
      return null;
    }
  }

  Future<bool> deleteVehicle(String id, String customerId) async {
    try {
      await vehicleService.deleteVehicle(id);
      return true;
    } catch (e) {
      print('[VehicleProvider] deleteVehicle error: $e');
      return false;
    }
  }
}
