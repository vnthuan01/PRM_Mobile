import 'package:flutter/material.dart';
import 'package:prm_project/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../model/dto/response/booking_response.dart';
import '../../utils/date_formatter.dart';
import 'appointment_create_screen.dart';
import 'appointment_detail_screen.dart';

class AppointmentListScreen extends StatefulWidget {
  final String? customerId;
  const AppointmentListScreen({super.key, this.customerId});

  @override
  State<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchBookings();
    });
  }

  void _fetchBookings() {
    final bookingProvider = Provider.of<BookingProvider>(
      context,
      listen: false,
    );
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final customerIdToUse = widget.customerId ?? authProvider.customerId ?? '';
    bookingProvider.fetchBookingsByCustomer(customerIdToUse);
  }

  void _navigateToCreate() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final customerIdToUse = widget.customerId ?? authProvider.customerId ?? '';
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AppointmentCreateScreen(customerId: customerIdToUse),
      ),
    );
    if (result == true) _fetchBookings();
  }

  void _navigateToDetail(String bookingId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AppointmentDetailScreen(bookingId: bookingId),
      ),
    );
  }

  String _serviceTypeName(int? type) {
    switch (type) {
      case 0:
        return 'Bảo dưỡng cơ bản';
      case 1:
        return 'Sửa chữa';
      default:
        return 'Không xác định';
    }
  }

  Color _statusColor(BookingStatus status, bool isDarkMode) {
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

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bookingProvider = Provider.of<BookingProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: const Text('Danh sách lịch bảo dưỡng'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _navigateToCreate),
        ],
      ),
      body: bookingProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookingProvider.bookings.isEmpty
          ? const Center(child: Text('Không có lịch nào'))
          : RefreshIndicator(
              onRefresh: () async => _fetchBookings(),
              child: ListView.builder(
                itemCount: bookingProvider.bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookingProvider.bookings[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    elevation: 4,
                    child: InkWell(
                      onTap: () => _navigateToDetail(booking.id),
                      borderRadius: BorderRadius.circular(16),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Góc trái màu status
                            Container(
                              width: 8,
                              decoration: BoxDecoration(
                                color: _statusColor(
                                  booking.bookingStatus,
                                  isDarkMode,
                                ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  bottomLeft: Radius.circular(16),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header: Vehicle + Service + menu
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                booking.vehicleId,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: isDarkMode
                                                      ? Colors.white
                                                      : Colors.black,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                _serviceTypeName(
                                                  booking.serviceType,
                                                ),
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: isDarkMode
                                                      ? Colors.grey[300]
                                                      : Colors.grey[800],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Icon menu nếu không canceled
                                        PopupMenuButton<String>(
                                          icon: Icon(
                                            Icons.more_vert,
                                            color: isDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                          onSelected: (value) async {
                                            if (value == 'delete' &&
                                                booking
                                                    .bookingStatus
                                                    .canDelete) {
                                              final confirmed =
                                                  await _showDeleteConfirmation(
                                                    context,
                                                  );
                                              if (confirmed == true) {
                                                final success =
                                                    await bookingProvider
                                                        .deleteBooking(
                                                          booking.id,
                                                        );
                                                if (success) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Đã xóa lịch bảo dưỡng',
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        bookingProvider.error ??
                                                            'Lỗi không xác định',
                                                      ),
                                                    ),
                                                  );
                                                }
                                              }
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            if (booking.bookingStatus.canDelete)
                                              const PopupMenuItem(
                                                value: 'delete',
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.delete,
                                                      color: Colors.red,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text('Xóa lịch'),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    // Status
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _statusColor(
                                          booking.bookingStatus,
                                          isDarkMode,
                                        ).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        booking.bookingStatus.vietnameseName,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: _statusColor(
                                            booking.bookingStatus,
                                            isDarkMode,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // Ngày
                                    Text(
                                      'Ngày: ${DateFormatter.formatDateVietnamese(DateTime.parse(booking.scheduledDate).toLocal())}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isDarkMode
                                            ? Colors.grey[300]
                                            : Colors.grey[800],
                                      ),
                                    ),

                                    if (booking.notes != null &&
                                        booking.notes!.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Ghi chú: ${booking.notes}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isDarkMode
                                              ? Colors.grey[300]
                                              : Colors.grey[800],
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 4),

                                    // Nhân viên
                                    if (booking.staffId != null &&
                                        booking.staffId!.isNotEmpty)
                                      Text(
                                        'Nhân viên: ${booking.staffId}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isDarkMode
                                              ? Colors.grey[300]
                                              : Colors.grey[800],
                                        ),
                                      ),
                                    const SizedBox(height: 8),

                                    // ProgressBar nếu processing
                                    if (booking.bookingStatus ==
                                        BookingStatus.processing)
                                      LinearProgressIndicator(
                                        value: 0.5,
                                        backgroundColor: isDarkMode
                                            ? Colors.grey[700]
                                            : Colors.grey[300],
                                        color: isDarkMode
                                            ? Colors.lightBlueAccent
                                            : Colors.blue,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
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
