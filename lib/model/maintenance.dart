import 'package:json_annotation/json_annotation.dart';

part 'maintenance.g.dart';

enum MaintenanceStatus {
  @JsonValue('Pending')
  Pending,
  @JsonValue('InProgress')
  InProgress,
  @JsonValue('Completed')
  Completed,
  @JsonValue('Cancelled')
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

  /// ⚙️ C# backend trả `serviceType` là int (0–9)
  final String serviceType;

  final String? serviceTypeName;
  final String description;

  /// 🔁 C# backend trả `status` là string ("Pending", ...)
  final String status;

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

  MaintenanceStatus get maintenanceStatus {
    switch (status.toLowerCase()) {
      case 'pending':
        return MaintenanceStatus.Pending;
      case 'inprogress':
        return MaintenanceStatus.InProgress;
      case 'completed':
        return MaintenanceStatus.Completed;
      case 'cancelled':
        return MaintenanceStatus.Cancelled;
      default:
        return MaintenanceStatus.Pending;
    }
  }

  bool get isCompleted => maintenanceStatus == MaintenanceStatus.Completed;

  /// ✅ Map serviceType (int) sang tên tiếng Việt
  String get serviceTypeDisplayName {
    if (serviceTypeName != null && serviceTypeName!.isNotEmpty) {
      return serviceTypeName!;
    }

    switch (serviceType) {
      case 0:
        return 'Bảo dưỡng định kỳ';
      case 1:
        return 'Kiểm tra pin';
      case 2:
        return 'Bảo dưỡng phanh';
      case 3:
        return 'Thay lốp';
      case 4:
        return 'Sửa hệ thống treo';
      case 5:
        return 'Sửa hệ thống điện';
      case 6:
        return 'Sửa hệ thống sạc';
      case 7:
        return 'Sửa chữa chung';
      case 8:
        return 'Kiểm tra tổng quát';
      case 9:
        return 'Khẩn cấp';
      default:
        return 'Không xác định';
    }
  }

  /// ✅ Lấy tên trạng thái tiếng Việt
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
