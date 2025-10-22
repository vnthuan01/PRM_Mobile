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

  // Helper functions to convert enum to/from integer
  static MaintenanceStatus _statusFromJson(int status) =>
      MaintenanceStatus.values.firstWhere((e) => e.index == status);

  static int _statusToJson(MaintenanceStatus status) => status.index;
}
