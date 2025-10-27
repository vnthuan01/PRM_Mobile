import 'package:json_annotation/json_annotation.dart';
part 'vehicle_response.g.dart';

@JsonSerializable()
class VehicleResponse {
  final String? status;
  final String? id;
  final String? customerId;
  final String? model;
  final String? vin;
  final String? licensePlate;
  final int? year;
  final int? odometerKm;
  final String? createdAt;
  final String? updatedAt;

  VehicleResponse({
    this.status,
    this.id,
    this.customerId,
    this.model,
    this.vin,
    this.licensePlate,
    this.year,
    this.odometerKm,
    this.createdAt,
    this.updatedAt,
  });

  factory VehicleResponse.fromJson(Map<String, dynamic> json) =>
      _$VehicleResponseFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleResponseToJson(this);
}
