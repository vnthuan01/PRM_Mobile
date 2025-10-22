import 'package:json_annotation/json_annotation.dart';
part 'booking_response.g.dart';

enum BookingStatus {
  @JsonValue(0)
  pending,
  @JsonValue(1)
  processing,
  @JsonValue(2)
  completed,
  @JsonValue(3)
  cancelled,
}

extension BookingStatusExtension on BookingStatus {
  String get vietnameseName {
    switch (this) {
      case BookingStatus.pending:
        return 'Chờ xử lý';
      case BookingStatus.processing:
        return 'Đang xử lý';
      case BookingStatus.completed:
        return 'Hoàn thành';
      case BookingStatus.cancelled:
        return 'Đã hủy';
    }
  }

  String get statusCode {
    switch (this) {
      case BookingStatus.pending:
        return 'pending';
      case BookingStatus.processing:
        return 'processing';
      case BookingStatus.completed:
        return 'completed';
      case BookingStatus.cancelled:
        return 'cancelled';
    }
  }

  bool get canDelete => this == BookingStatus.pending;
}

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

  BookingStatus get bookingStatus {
    switch (status.toLowerCase()) {
      case 'pending':
        return BookingStatus.pending;
      case 'processing':
        return BookingStatus.processing;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.pending;
    }
  }
}
