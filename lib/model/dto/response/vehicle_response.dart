// vehicle_response.dart
import 'package:json_annotation/json_annotation.dart';

part 'vehicle_response.g.dart';

@JsonSerializable()
class VehicleResponse {
  final String id;
  final String customerId;
  final String model;
  final String vin;
  final String licensePlate;
  final int year;
  final int odometerKm;
  final String status;

  VehicleResponse({
    required this.status,
    required this.id,
    required this.customerId,
    required this.model,
    required this.vin,
    required this.licensePlate,
    required this.year,
    required this.odometerKm,
  });

  factory VehicleResponse.fromJson(Map<String, dynamic> json) =>
      _$VehicleResponseFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleResponseToJson(this);
}
