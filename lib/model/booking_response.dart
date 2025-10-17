import 'package:json_annotation/json_annotation.dart';
part 'booking_response.g.dart';

@JsonSerializable()
class Booking {
  final String id;
  final String customerId;
  final String vehicleId;
  final String? staffId;
  final int serviceType;
  final String scheduledDate;
  final String status;
  final String? notes;

  Booking({
    required this.id,
    required this.customerId,
    required this.vehicleId,
    this.staffId,
    required this.serviceType,
    required this.scheduledDate,
    required this.status,
    this.notes,
  });

  factory Booking.fromJson(Map<String, dynamic> json) =>
      _$BookingFromJson(json);
  Map<String, dynamic> toJson() => _$BookingToJson(this);
}
