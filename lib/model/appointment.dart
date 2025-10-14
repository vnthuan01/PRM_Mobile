import 'package:flutter/material.dart';

enum AppointmentStatus { pending, confirmed, inProgress, completed, cancelled }

class Appointment {
  final String id;
  final String userId;
  final String vehicleId;
  final DateTime appointmentDate;
  final String serviceType;
  final String description;
  final AppointmentStatus status;
  final DateTime createdAt;
  final String? notes;

  Appointment({
    required this.id,
    required this.userId,
    required this.vehicleId,
    required this.appointmentDate,
    required this.serviceType,
    required this.description,
    required this.status,
    required this.createdAt,
    this.notes,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
    id: json['id'] ?? '',
    userId: json['userId'] ?? '',
    vehicleId: json['vehicleId'] ?? '',
    appointmentDate: json['appointmentDate'] != null
        ? DateTime.parse(json['appointmentDate'])
        : DateTime.now(),
    serviceType: json['serviceType'] ?? '',
    description: json['description'] ?? '',
    status: AppointmentStatus.values.firstWhere(
      (e) => e.toString() == 'AppointmentStatus.${json['status']}',
      orElse: () => AppointmentStatus.pending,
    ),
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : DateTime.now(),
    notes: json['notes'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'vehicleId': vehicleId,
    'appointmentDate': appointmentDate.toIso8601String(),
    'serviceType': serviceType,
    'description': description,
    'status': status.toString().split('.').last,
    'createdAt': createdAt.toIso8601String(),
    'notes': notes,
  };

  String getStatusText() {
    switch (status) {
      case AppointmentStatus.pending:
        return 'Chờ xác nhận';
      case AppointmentStatus.confirmed:
        return 'Đã xác nhận';
      case AppointmentStatus.inProgress:
        return 'Đang bảo dưỡng';
      case AppointmentStatus.completed:
        return 'Hoàn tất';
      case AppointmentStatus.cancelled:
        return 'Đã hủy';
    }
  }

  Color getStatusColor() {
    switch (status) {
      case AppointmentStatus.pending:
        return Colors.orange;
      case AppointmentStatus.confirmed:
        return Colors.blue;
      case AppointmentStatus.inProgress:
        return Colors.purple;
      case AppointmentStatus.completed:
        return Colors.green;
      case AppointmentStatus.cancelled:
        return Colors.red;
    }
  }
}
