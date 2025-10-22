import 'package:json_annotation/json_annotation.dart';
import 'package:prm_project/model/maintenance.dart';

part 'maintenance_status_request.g.dart';

@JsonSerializable()
class MaintenanceStatusRequest {
  @JsonKey(fromJson: _statusFromJson, toJson: _statusToJson)
  final MaintenanceStatus status;

  MaintenanceStatusRequest({required this.status});

  factory MaintenanceStatusRequest.fromJson(Map<String, dynamic> json) =>
      _$MaintenanceStatusRequestFromJson(json);

  Map<String, dynamic> toJson() => _$MaintenanceStatusRequestToJson(this);

  // Helper functions to convert enum to/from string
  static MaintenanceStatus _statusFromJson(String status) => MaintenanceStatus
      .values
      .firstWhere((e) => e.toString().split('.').last == status);

  static String _statusToJson(MaintenanceStatus status) =>
      status.toString().split('.').last;
}
