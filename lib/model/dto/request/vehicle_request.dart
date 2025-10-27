// vehicle_request.dart
import 'package:json_annotation/json_annotation.dart';

part 'vehicle_request.g.dart';

@JsonSerializable()
class VehicleRequest {
  final String customerId;
  final String model;
  final String vin;
  final String? licensePlate;
  final int year;
  final int odometerKm;
  final String? status;

  VehicleRequest({
    required this.customerId,
    required this.model,
    required this.vin,
    this.licensePlate,
    required this.year,
    required this.odometerKm,
    this.status,
  });

  factory VehicleRequest.fromJson(Map<String, dynamic> json) =>
      _$VehicleRequestFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleRequestToJson(this);
}
