import 'package:flutter/material.dart';
import 'package:prm_project/services/maintenace_service.dart';
import '../model/maintenance.dart';
import '../model/dto/request/maintenance_status_request.dart';

enum UserRole {
  Customer(1),
  Technician(2);

  const UserRole(this.value);
  final int value;

  static UserRole fromValue(int value) {
    switch (value) {
      case 1:
        return UserRole.Customer;
      case 2:
        return UserRole.Technician;
      default:
        return UserRole.Customer;
    }
  }
}

class MaintenanceProvider extends ChangeNotifier {
  final MaintenanceService _repository;

  bool isLoading = false;
  String? error;

  List<Maintenance> maintenances = [];
  Maintenance? selectedMaintenance;

  MaintenanceProvider(this._repository);
  bool isFetchingMore = false;
  bool hasMore = true;
  int currentPage = 1;
  final int pageSize = 5;

  void setIsLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void selectMaintenance(Maintenance maintenance) {
    selectedMaintenance = maintenance;
    notifyListeners();
  }

  String _handleError(Object e) {
    return e.toString();
  }

  Future<void> fetchMaintenances({
    required String userId,
    required UserRole role,
  }) async {
    if (isLoading) return;

    print('[MaintenanceProvider] Fetch page 1...');
    setIsLoading(true);
    currentPage = 1;
    hasMore = true;

    try {
      List<Maintenance> result;
      if (role == UserRole.Technician) {
        result = await _repository.getMaintenanceByStaffId(
          staffId: userId,
          pageNumber: currentPage,
          pageSize: pageSize,
        );
      } else {
        result = await _repository.getMaintenanceByCustomerId(
          customerId: userId,
          pageNumber: currentPage,
          pageSize: pageSize,
        );
      }

      maintenances = result;
      hasMore = result.length == pageSize;
      error = null;
    } catch (e) {
      error = _handleError(e);
      maintenances = [];
    } finally {
      setIsLoading(false);
    }
  }

  Future<void> fetchMoreMaintenances({
    required String userId,
    required UserRole role,
  }) async {
    if (isFetchingMore || !hasMore) return;

    isFetchingMore = true;
    notifyListeners();

    try {
      final nextPage = currentPage + 1;
      print('[MaintenanceProvider] Fetch more page $nextPage...');

      List<Maintenance> newItems;
      if (role == UserRole.Technician) {
        newItems = await _repository.getMaintenanceByStaffId(
          staffId: userId,
          pageNumber: nextPage,
          pageSize: pageSize,
        );
      } else {
        newItems = await _repository.getMaintenanceByCustomerId(
          customerId: userId,
          pageNumber: nextPage,
          pageSize: pageSize,
        );
      }

      if (newItems.isEmpty) {
        hasMore = false;
      } else {
        maintenances.addAll(newItems);
        currentPage = nextPage;
        hasMore = newItems.length == pageSize;
      }

      error = null;
    } catch (e) {
      error = _handleError(e);
    } finally {
      isFetchingMore = false;
      notifyListeners();
    }
  }

  Future<Maintenance?> getMaintenanceById(String id) async {
    print('[MaintenanceProvider] Getting maintenance by ID: $id');
    setIsLoading(true);
    Maintenance? result;
    try {
      result = maintenances.firstWhere((m) => m.maintenanceId == id);
      selectedMaintenance = result;
      print('[MaintenanceProvider] Found maintenance: ${result.maintenanceId}');
      error = null;
    } catch (e) {
      print('[MaintenanceProvider] Maintenance not found: $e');
      result = null;
      error = "Không tìm thấy bảo dưỡng";
    } finally {
      setIsLoading(false);
    }
    return result;
  }

  Future<bool> updateMaintenanceStatus(
    String maintenanceId,
    MaintenanceStatusRequest request,
  ) async {
    setIsLoading(true);
    bool success = false;
    try {
      success = await _repository.updateMaintenanceStatus(
        maintenanceId: maintenanceId,
        request: request,
      );

      if (success) {
        int index = maintenances.indexWhere(
          (m) => m.maintenanceId == maintenanceId,
        );
        if (index != -1) {
          final old = maintenances[index];
          maintenances[index] = Maintenance(
            maintenanceId: old.maintenanceId,
            vehicleId: old.vehicleId,
            customerId: old.customerId,
            bookingId: old.bookingId,
            staffId: old.staffId,
            serviceDate: old.serviceDate,
            odometer: old.odometer,
            serviceType: old.serviceType,
            serviceTypeName: old.serviceTypeName,
            description: old.description,
            status: request.status.index,
            statusName: request.status.vietnameseName,
            createdAt: old.createdAt,
            updatedAt: DateTime.now(),
          );
        }
        notifyListeners();
      }
      error = null;
    } catch (e) {
      error = _handleError(e);
    } finally {
      setIsLoading(false);
    }
    return success;
  }

  void clearError() {
    if (error != null) {
      error = null;
      notifyListeners();
    }
  }
}
