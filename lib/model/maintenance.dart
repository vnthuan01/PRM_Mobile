import 'package:json_annotation/json_annotation.dart';

part 'maintenance.g.dart';

enum MaintenanceStatus { Pending, InProgress, Completed, Cancelled }

@JsonSerializable()
class Maintenance {
  final String id;
  final String vehicleId;
  final String customerId;
  final String bookingId;
  final String staffId;
  final DateTime serviceDate;
  final int odometer;
  final int serviceType;
  final String description;
  final MaintenanceStatus status;

  Maintenance({
    required this.id,
    required this.vehicleId,
    required this.customerId,
    required this.bookingId,
    required this.staffId,
    required this.serviceDate,
    required this.odometer,
    required this.serviceType,
    required this.description,
    required this.status,
  });

  factory Maintenance.fromJson(Map<String, dynamic> json) =>
      _$MaintenanceFromJson(json);

  Map<String, dynamic> toJson() => _$MaintenanceToJson(this);
}
