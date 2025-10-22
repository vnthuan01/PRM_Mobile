import 'package:json_annotation/json_annotation.dart';
part 'booking_request.g.dart';

@JsonSerializable()
class BookingRequest {
  final String customerId;
  final String vehicleId;
  final String? staffId;
  final int serviceType;
  final String scheduledDate;
  final String? notes;

  BookingRequest({
    required this.customerId,
    required this.vehicleId,
    this.staffId,
    required this.serviceType,
    required this.scheduledDate,
    this.notes,
  });

  factory BookingRequest.fromJson(Map<String, dynamic> json) =>
      _$BookingRequestFromJson(json);
  Map<String, dynamic> toJson() => _$BookingRequestToJson(this);
}
