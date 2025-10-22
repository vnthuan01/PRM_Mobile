import 'package:flutter/material.dart';
import 'package:prm_project/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../model/dto/response/booking_response.dart';
import '../../utils/date_formatter.dart';
import 'appointment_create_screen.dart';
import 'appointment_detail_screen.dart';

class AppointmentListScreen extends StatefulWidget {
  const AppointmentListScreen({super.key});

  @override
  State<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  bool _hasInitialized = false;
  BookingStatus? _selectedStatus; // Filter status

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitialized) {
      _fetchBookings();
      _hasInitialized = true;
    }
  }

  void _fetchBookings() {
    final bookingProvider = Provider.of<BookingProvider>(
      context,
      listen: false,
    );
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final customerIdToUse = authProvider.customerId ?? '';

    if (authProvider.isLoggedIn &&
        authProvider.isCustomer &&
        customerIdToUse.isNotEmpty) {
      bookingProvider.fetchBookingsByCustomer(customerIdToUse);
    }
  }

  void _refreshData() {
    _hasInitialized = false;
    _fetchBookings();
    _hasInitialized = true;
  }

  void _navigateToCreate() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final customerIdToUse = authProvider.customerId ?? '';
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AppointmentCreateScreen(customerId: customerIdToUse),
      ),
    );
    if (result == true) _refreshData();
  }

  void _navigateToDetail(String bookingId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AppointmentDetailScreen(bookingId: bookingId),
      ),
    );
    if (mounted) _refreshData();
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

    // Lọc bookings theo status đã chọn
    final filteredBookings = (_selectedStatus == null)
        ? bookingProvider.bookings
        : bookingProvider.bookings
              .where((b) => b.bookingStatus == _selectedStatus)
              .toList();

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
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Không có lịch nào',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hãy tạo lịch bảo dưỡng đầu tiên của bạn',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _navigateToCreate,
                    icon: const Icon(Icons.add),
                    label: const Text('Tạo lịch mới'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Dropdown filter status
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: DropdownButton<BookingStatus>(
                    isExpanded: true,
                    value: _selectedStatus,
                    hint: const Text('Tất cả trạng thái'),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Tất cả'),
                      ),
                      ...BookingStatus.values.map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.vietnameseName),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    },
                  ),
                ),

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async => _refreshData(),
                    child: filteredBookings.isEmpty
                        ? const Center(child: Text('Không có booking phù hợp.'))
                        : ListView.builder(
                            itemCount: filteredBookings.length,
                            itemBuilder: (context, index) {
                              final booking = filteredBookings[index];
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
                                  onTap: () =>
                                      _navigateToDetail(booking.bookingId),
                                  borderRadius: BorderRadius.circular(16),
                                  child: IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Container(
                                          width: 8,
                                          decoration: BoxDecoration(
                                            color: _statusColor(
                                              booking.bookingStatus,
                                              isDarkMode,
                                            ),
                                            borderRadius:
                                                const BorderRadius.only(
                                                  topLeft: Radius.circular(16),
                                                  bottomLeft: Radius.circular(
                                                    16,
                                                  ),
                                                ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const SizedBox(
                                                            height: 4,
                                                          ),
                                                          Text(
                                                            _serviceTypeName(
                                                              booking
                                                                  .serviceType,
                                                            ),
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              color: isDarkMode
                                                                  ? Colors
                                                                        .grey[300]
                                                                  : Colors
                                                                        .grey[800],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),

                                                // Status
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: _statusColor(
                                                      booking.bookingStatus,
                                                      isDarkMode,
                                                    ).withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    booking
                                                        .bookingStatus
                                                        .vietnameseName,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
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
                                                    booking
                                                        .notes!
                                                        .isNotEmpty) ...[
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
                                                if (booking.paymentStatus !=
                                                    null)
                                                  Text(
                                                    'Thanh toán: ${booking.paymentStatus}',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: isDarkMode
                                                          ? Colors.grey[300]
                                                          : Colors.grey[800],
                                                    ),
                                                  ),
                                                const SizedBox(height: 8),

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
                ),
              ],
            ),
    );
  }
}
