import 'package:json_annotation/json_annotation.dart';

part 'vehicle.g.dart';

@JsonSerializable()
class Vehicle {
  final String customerId;
  final String model;
  final String vin;
  final String licensePlate;
  final int year;
  final int odometerKm;
  final String status;

  Vehicle({
    required this.customerId,
    required this.model,
    required this.vin,
    required this.licensePlate,
    required this.year,
    required this.odometerKm,
    required this.status,
  });

  /// Tạo object từ JSON
  factory Vehicle.fromJson(Map<String, dynamic> json) =>
      _$VehicleFromJson(json);

  /// Chuyển object sang JSON
  Map<String, dynamic> toJson() => _$VehicleToJson(this);
}
