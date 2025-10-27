import 'package:json_annotation/json_annotation.dart';

part 'maintenance.g.dart';

enum MaintenanceStatus {
  @JsonValue(0)
  Pending,
  @JsonValue(1)
  InProgress,
  @JsonValue(2)
  Completed,
  @JsonValue(3)
  Cancelled,
}

extension MaintenanceStatusExtension on MaintenanceStatus {
  String get vietnameseName {
    switch (this) {
      case MaintenanceStatus.Pending:
        return 'Chờ xử lý';
      case MaintenanceStatus.InProgress:
        return 'Đang thực hiện';
      case MaintenanceStatus.Completed:
        return 'Hoàn thành';
      case MaintenanceStatus.Cancelled:
        return 'Đã hủy';
    }
  }

  String get statusCode {
    switch (this) {
      case MaintenanceStatus.Pending:
        return 'pending';
      case MaintenanceStatus.InProgress:
        return 'in_progress';
      case MaintenanceStatus.Completed:
        return 'completed';
      case MaintenanceStatus.Cancelled:
        return 'cancelled';
    }
  }
}

@JsonSerializable()
class Maintenance {
  final String maintenanceId;
  final String vehicleId;
  final String customerId;
  final String bookingId;
  final String staffId;
  final DateTime serviceDate;
  final int odometer;
  final int serviceType;
  final String? serviceTypeName;
  final String description;
  final int status;
  String? vehicleModel;
  String? vehicleLicensePlate;
  final String? statusName;
  final DateTime createdAt;
  final DateTime updatedAt;

  Maintenance({
    required this.maintenanceId,
    required this.vehicleId,
    required this.customerId,
    required this.bookingId,
    required this.staffId,
    required this.serviceDate,
    required this.odometer,
    required this.serviceType,
    this.serviceTypeName,
    required this.description,
    required this.status,
    this.vehicleLicensePlate,
    this.vehicleModel,
    this.statusName,
    required this.createdAt,
    required this.updatedAt,
  });

  // Getter để convert status int thành enum
  MaintenanceStatus get maintenanceStatus {
    switch (status) {
      case 0:
        return MaintenanceStatus.Pending;
      case 1:
        return MaintenanceStatus.InProgress;
      case 2:
        return MaintenanceStatus.Completed;
      case 3:
        return MaintenanceStatus.Cancelled;
      default:
        return MaintenanceStatus.Pending;
    }
  }

  bool get isCompleted {
    return status == 2;
  }

  // Getter để lấy service type name
  String get serviceTypeDisplayName {
    if (serviceTypeName != null && serviceTypeName!.isNotEmpty) {
      return serviceTypeName!;
    }

    switch (serviceType) {
      case 0:
        return 'Bảo dưỡng cơ bản';
      case 1:
        return 'Sửa chữa';
      case 2:
        return 'Kiểm tra định kỳ';
      default:
        return 'Không xác định';
    }
  }

  // Getter để lấy status name
  String get statusDisplayName {
    if (statusName != null && statusName!.isNotEmpty) {
      return statusName!;
    }
    return maintenanceStatus.vietnameseName;
  }

  factory Maintenance.fromJson(Map<String, dynamic> json) =>
      _$MaintenanceFromJson(json);

  Map<String, dynamic> toJson() => _$MaintenanceToJson(this);
}
