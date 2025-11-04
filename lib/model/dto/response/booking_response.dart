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
  final String bookingId;
  final String customerId;
  final String vehicleId;
  final String? staffId;
  final int serviceType; // giữ nguyên kiểu int
  final String scheduledDate;
  final dynamic status;
  final String? notes;
  final double? totalCost;
  final String? paymentStatus;
  final String? createdAt;
  final String? updatedAt;

  Booking({
    required this.bookingId,
    required this.customerId,
    required this.vehicleId,
    this.staffId,
    required this.serviceType,
    required this.scheduledDate,
    this.status,
    this.notes,
    this.totalCost,
    this.paymentStatus,
    this.createdAt,
    this.updatedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    int parsedServiceType;
    final serviceTypeValue = json['serviceType'];

    if (serviceTypeValue is int) {
      parsedServiceType = serviceTypeValue;
    } else if (serviceTypeValue is String) {
      switch (serviceTypeValue.toLowerCase()) {
        case 'maintenance':
          parsedServiceType = 0;
          break;
        case 'repair':
          parsedServiceType = 1;
          break;
        default:
          parsedServiceType = -1;
      }
    } else {
      parsedServiceType = -1;
    }

    return Booking(
      bookingId: json['bookingId'] ?? '',
      customerId: json['customerId'] ?? '',
      vehicleId: json['vehicleId'] ?? '',
      staffId: json['staffId'],
      serviceType: parsedServiceType,
      scheduledDate: json['scheduledDate'] ?? '',
      status: json['status'],
      notes: json['notes'],
      totalCost: (json['totalCost'] is num)
          ? (json['totalCost'] as num).toDouble()
          : null,
      paymentStatus: json['paymentStatus'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() => _$BookingToJson(this);

  BookingStatus get bookingStatus {
    if (status is String) {
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
    } else if (status is int) {
      switch (status) {
        case 0:
          return BookingStatus.pending;
        case 1:
          return BookingStatus.processing;
        case 2:
          return BookingStatus.completed;
        case 3:
          return BookingStatus.cancelled;
        default:
          return BookingStatus.pending;
      }
    }
    return BookingStatus.pending;
  }

  String get serviceTypeName {
    switch (serviceType) {
      case 0:
        return 'Bảo dưỡng';
      case 1:
        return 'Sửa chữa';
      default:
        return 'Không xác định';
    }
  }
}

@JsonSerializable()
class BookingResponse {
  final bool success;
  final String message;
  final Booking? data;

  BookingResponse({required this.success, required this.message, this.data});

  factory BookingResponse.fromJson(Map<String, dynamic> json) =>
      _$BookingResponseFromJson(json);
  Map<String, dynamic> toJson() => _$BookingResponseToJson(this);
}
