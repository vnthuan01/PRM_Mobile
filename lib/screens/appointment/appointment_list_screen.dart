import 'package:flutter/material.dart';
import '../../widgets/selection_modal.dart';
import 'appointment_create_screen.dart';

class AppointmentListScreen extends StatefulWidget {
  const AppointmentListScreen({super.key});

  @override
  State<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  final List<Map<String, String>> staffList = [
    {'id': 's1', 'name': 'Nguyen Van A'},
    {'id': 's2', 'name': 'Tran Thi B'},
    {'id': 's3', 'name': 'Le Van C'},
  ];

  final List<Map<String, dynamic>> mockBookings = [
    {
      'id': 'b1',
      'vehicleId': 'Xe Model 1',
      'scheduledDate': DateTime.now()
          .add(const Duration(days: 1))
          .toIso8601String(),
      'serviceType': 0,
      'status': 'pending',
      'notes': 'Kiểm tra pin',
      'staffId': null,
    },
    {
      'id': 'b2',
      'vehicleId': 'Xe Model 2',
      'scheduledDate': DateTime.now()
          .add(const Duration(days: 3))
          .toIso8601String(),
      'serviceType': 1,
      'status': 'inprogress',
      'notes': 'Thay dầu',
      'staffId': 's2',
    },
    {
      'id': 'b3',
      'vehicleId': 'Xe Model 3',
      'scheduledDate': DateTime.now()
          .add(const Duration(days: 5))
          .toIso8601String(),
      'serviceType': 2,
      'status': 'completed',
      'notes': '',
      'staffId': 's1',
    },
    {
      'id': 'b4',
      'vehicleId': 'Xe Model 4',
      'scheduledDate': DateTime.now()
          .add(const Duration(days: 2))
          .toIso8601String(),
      'serviceType': 0,
      'status': 'canceled',
      'notes': 'Khách hủy',
      'staffId': null,
    },
  ];

  List<Map<String, dynamic>> bookings = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  void _fetchBookings() {
    setState(() => isLoading = true);
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        bookings = mockBookings;
        isLoading = false;
      });
    });
  }

  void _navigateToCreate() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AppointmentCreateScreen(customerId: 'customer_mock'),
      ),
    );
    if (result == true) _fetchBookings();
  }

  void _assignStaff(String bookingId) async {
    String? selectedStaffId;
    await showSelectionModal(
      context: context,
      title: 'Chọn nhân viên',
      items: staffList,
      selectedId: null,
      onSelected: (id) => selectedStaffId = id,
    );

    if (selectedStaffId != null) {
      final idx = bookings.indexWhere((b) => b['id'] == bookingId);
      if (idx != -1) {
        setState(() {
          bookings[idx]['staffId'] = selectedStaffId;
        });
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gán nhân viên thành công')));
    }
  }

  String _serviceTypeName(int? type) {
    switch (type) {
      case 0:
        return 'Bảo dưỡng cơ bản';
      case 1:
        return 'Bảo dưỡng nâng cao';
      case 2:
        return 'Sửa chữa';
      default:
        return 'Không xác định';
    }
  }

  Color _statusColor(String status, bool isDarkMode) {
    if (isDarkMode) return Colors.grey[800]!;
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange[200]!;
      case 'inprogress':
        return Colors.blue[200]!;
      case 'completed':
        return Colors.green[200]!;
      case 'canceled':
        return Colors.red[200]!;
      default:
        return Colors.grey[200]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: const Text('Danh sách lịch bảo dưỡng'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _navigateToCreate),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookings.isEmpty
          ? const Center(child: Text('Không có lịch nào'))
          : RefreshIndicator(
              onRefresh: () async => _fetchBookings(),
              child: ListView.builder(
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    elevation: 4,
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Góc trái màu status
                          Container(
                            width: 8,
                            decoration: BoxDecoration(
                              color: _statusColor(
                                booking['status'] ?? '',
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
                                              booking['vehicleId'],
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
                                                booking['serviceType'],
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
                                        onSelected: (value) {
                                          if (value == 'assign') {
                                            _assignStaff(
                                              booking['id'],
                                            ); // bỏ await
                                          } else if (value == 'delete') {
                                            setState(() {
                                              bookings.removeWhere(
                                                (b) => b['id'] == booking['id'],
                                              );
                                            });
                                          }
                                        },
                                        itemBuilder: (context) => const [
                                          PopupMenuItem(
                                            value: 'assign',
                                            child: Text('Đổi nhân viên'),
                                          ),
                                          PopupMenuItem(
                                            value: 'delete',
                                            child: Text('Xoá lịch'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // Ngày
                                  Text(
                                    'Ngày: ${DateTime.parse(booking['scheduledDate']).toLocal().day.toString().padLeft(2, '0')}/'
                                    '${DateTime.parse(booking['scheduledDate']).toLocal().month.toString().padLeft(2, '0')}/'
                                    '${DateTime.parse(booking['scheduledDate']).toLocal().year}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDarkMode
                                          ? Colors.grey[300]
                                          : Colors.grey[800],
                                    ),
                                  ),

                                  if ((booking['notes'] ?? '').isNotEmpty)
                                    Text(
                                      'Ghi chú: ${booking['notes']}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isDarkMode
                                            ? Colors.grey[300]
                                            : Colors.grey[800],
                                      ),
                                    ),
                                  const SizedBox(height: 8),

                                  // Nhân viên
                                  if (booking['staffId'] != null &&
                                      booking['staffId'] != '')
                                    Text(
                                      'Nhân viên: ${staffList.firstWhere((s) => s['id'] == booking['staffId'], orElse: () => {'name': 'Unknown'})['name']}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isDarkMode
                                            ? Colors.grey[300]
                                            : Colors.grey[800],
                                      ),
                                    ),
                                  const SizedBox(height: 8),

                                  // ProgressBar nếu inprogress
                                  if (booking['status'] == 'inprogress')
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
                  );
                },
              ),
            ),
    );
  }
}
