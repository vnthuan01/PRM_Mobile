import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/dto/response/booking_response.dart';
import '../../providers/booking_provider.dart';
import '../../utils/date_formatter.dart';

class AppointmentDetailScreen extends StatelessWidget {
  final String bookingId;

  const AppointmentDetailScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết lịch bảo dưỡng'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          Builder(
            builder: (context) {
              final bookingProvider = Provider.of<BookingProvider>(
                context,
                listen: false,
              );
              if (bookingProvider.bookings.isNotEmpty) {
                final booking = bookingProvider.bookings.firstWhere(
                  (b) => b.bookingId == bookingId,
                  orElse: () => bookingProvider.bookings.first,
                );

                if (booking.bookingStatus.canDelete) {
                  return PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) async {
                      if (value == 'delete') {
                        final confirmed = await _showDeleteConfirmation(
                          context,
                        );
                        if (confirmed == true) {
                          final success = await bookingProvider.deleteBooking(
                            bookingId,
                          );
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã xóa lịch bảo dưỡng'),
                              ),
                            );
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  bookingProvider.error ?? 'Lỗi không xác định',
                                ),
                              ),
                            );
                          }
                        }
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Xóa lịch'),
                          ],
                        ),
                      ),
                    ],
                  );
                }
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: FutureBuilder<Booking?>(
        future: Provider.of<BookingProvider>(
          context,
          listen: false,
        ).getBookingById(bookingId),
        builder: (context, snapshot) {
          print(
            '[AppointmentDetailScreen] Connection state: ${snapshot.connectionState}',
          );
          print('[AppointmentDetailScreen] Has data: ${snapshot.hasData}');
          print('[AppointmentDetailScreen] Has error: ${snapshot.hasError}');
          if (snapshot.hasData) {
            print('[AppointmentDetailScreen] Booking data: ${snapshot.data}');
          }
          if (snapshot.hasError) {
            print('[AppointmentDetailScreen] Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Không thể tải chi tiết lịch bảo dưỡng',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error?.toString() ?? 'Lỗi không xác định',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final booking = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Card
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: _getStatusColor(
                        booking.bookingStatus,
                        isDarkMode,
                      ).withOpacity(0.1),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              booking.bookingStatus,
                              isDarkMode,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getStatusIcon(booking.bookingStatus),
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Trạng thái',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              booking.bookingStatus.vietnameseName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Booking Details
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Thông tin lịch bảo dưỡng',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildDetailRow(
                          'ID lịch:',
                          booking.bookingId,
                          Icons.tag,
                          isDarkMode,
                        ),
                        const SizedBox(height: 12),

                        _buildDetailRow(
                          'Xe:',
                          booking.vehicleId,
                          Icons.directions_car,
                          isDarkMode,
                        ),
                        const SizedBox(height: 12),

                        _buildDetailRow(
                          'Loại dịch vụ:',
                          _getServiceTypeName(booking.serviceType),
                          Icons.build,
                          isDarkMode,
                        ),
                        const SizedBox(height: 12),

                        _buildDetailRow(
                          'Ngày đặt lịch:',
                          DateFormatter.formatDateVietnameseWithDay(
                            DateTime.parse(booking.scheduledDate).toLocal(),
                          ),
                          Icons.calendar_today,
                          isDarkMode,
                        ),
                        const SizedBox(height: 12),

                        if (booking.staffId != null &&
                            booking.staffId!.isNotEmpty)
                          _buildDetailRow(
                            'Nhân viên:',
                            booking.staffId!,
                            Icons.person,
                            isDarkMode,
                          ),

                        if (booking.paymentStatus != null) ...[
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            'Trạng thái thanh toán:',
                            booking.paymentStatus!,
                            Icons.payment,
                            isDarkMode,
                          ),
                        ],

                        if (booking.notes != null &&
                            booking.notes!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            'Ghi chú:',
                            booking.notes!,
                            Icons.note,
                            isDarkMode,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon,
    bool isDarkMode,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(BookingStatus status, bool isDarkMode) {
    if (isDarkMode) {
      switch (status) {
        case BookingStatus.pending:
          return Colors.orange[600]!;
        case BookingStatus.processing:
          return Colors.blue[600]!;
        case BookingStatus.completed:
          return Colors.green[600]!;
        case BookingStatus.cancelled:
          return Colors.red[600]!;
      }
    } else {
      switch (status) {
        case BookingStatus.pending:
          return Colors.orange[400]!;
        case BookingStatus.processing:
          return Colors.blue[400]!;
        case BookingStatus.completed:
          return Colors.green[400]!;
        case BookingStatus.cancelled:
          return Colors.red[400]!;
      }
    }
  }

  IconData _getStatusIcon(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Icons.schedule;
      case BookingStatus.processing:
        return Icons.hourglass_empty;
      case BookingStatus.completed:
        return Icons.check_circle;
      case BookingStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getServiceTypeName(int serviceType) {
    switch (serviceType) {
      case 0:
        return 'Bảo dưỡng cơ bản';
      case 1:
        return 'Sửa chữa';
      default:
        return 'Không xác định';
    }
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text('Bạn có chắc chắn muốn xóa lịch bảo dưỡng này?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }
}
