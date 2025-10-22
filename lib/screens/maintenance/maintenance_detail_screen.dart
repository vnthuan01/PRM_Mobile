import 'package:flutter/material.dart';
import 'package:prm_project/model/dto/request/maintenance_status_request.dart';
import 'package:prm_project/model/maintenance.dart';
import 'package:prm_project/providers/auth_provider.dart';
import 'package:prm_project/services/maintenace_service.dart';
import 'package:provider/provider.dart';
import '../../utils/date_formatter.dart';

class MaintenanceDetailScreen extends StatefulWidget {
  final String maintenanceId;

  const MaintenanceDetailScreen({super.key, required this.maintenanceId});

  @override
  State<MaintenanceDetailScreen> createState() =>
      _MaintenanceDetailScreenState();
}

class _MaintenanceDetailScreenState extends State<MaintenanceDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchMaintenanceDetail();
    });
  }

  Future<Maintenance?> _fetchMaintenanceDetail() async {
    try {
      final maintenanceService = MaintenanceService();
      final maintenance = await maintenanceService.getMaintenanceById(
        widget.maintenanceId,
      );
      return maintenance;
    } catch (e) {
      print('[MaintenanceDetailScreen] Error fetching maintenance: $e');
      return null;
    }
  }

  String _getStatusVietnamese(MaintenanceStatus status) {
    switch (status) {
      case MaintenanceStatus.Pending:
        return 'Chờ xử lý';
      case MaintenanceStatus.InProgress:
        return 'Đang thực hiện';
      case MaintenanceStatus.Completed:
        return 'Hoàn thành';
      case MaintenanceStatus.Cancelled:
        return 'Đã hủy';
    }
  }

  Color _getStatusColor(MaintenanceStatus status, bool isDarkMode) {
    if (isDarkMode) {
      switch (status) {
        case MaintenanceStatus.Pending:
          return Colors.orange[600]!;
        case MaintenanceStatus.InProgress:
          return Colors.blue[600]!;
        case MaintenanceStatus.Completed:
          return Colors.green[600]!;
        case MaintenanceStatus.Cancelled:
          return Colors.red[600]!;
      }
    } else {
      switch (status) {
        case MaintenanceStatus.Pending:
          return Colors.orange[400]!;
        case MaintenanceStatus.InProgress:
          return Colors.blue[400]!;
        case MaintenanceStatus.Completed:
          return Colors.green[400]!;
        case MaintenanceStatus.Cancelled:
          return Colors.red[400]!;
      }
    }
  }

  IconData _getStatusIcon(MaintenanceStatus status) {
    switch (status) {
      case MaintenanceStatus.Pending:
        return Icons.schedule;
      case MaintenanceStatus.InProgress:
        return Icons.hourglass_empty;
      case MaintenanceStatus.Completed:
        return Icons.check_circle;
      case MaintenanceStatus.Cancelled:
        return Icons.cancel;
    }
  }

  // Removed _getServiceTypeName method since we now use maintenance.serviceTypeDisplayName

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết bảo dưỡng'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchMaintenanceDetail,
          ),
        ],
      ),
      body: FutureBuilder<Maintenance?>(
        future: _fetchMaintenanceDetail(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Không thể tải chi tiết bảo dưỡng',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error?.toString() ?? 'Lỗi không xác định',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {}); // Trigger rebuild to retry
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          final maintenance = snapshot.data!;
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
                        maintenance.maintenanceStatus,
                        isDarkMode,
                      ).withOpacity(0.1),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              maintenance.maintenanceStatus,
                              isDarkMode,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getStatusIcon(maintenance.maintenanceStatus),
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
                              maintenance.statusDisplayName,
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
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    if (authProvider.isTechnician) {
                      return Card(
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
                                'Cập nhật trạng thái',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<MaintenanceStatus>(
                                value: maintenance.maintenanceStatus,
                                decoration: InputDecoration(
                                  labelText: 'Trạng thái mới',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                items: MaintenanceStatus.values
                                    .map(
                                      (status) => DropdownMenuItem(
                                        value: status,
                                        child: Text(
                                          _getStatusVietnamese(status),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (status) async {
                                  if (status != null &&
                                      status != maintenance.maintenanceStatus) {
                                    final maintenanceService =
                                        MaintenanceService();

                                    final success = await maintenanceService
                                        .updateMaintenanceStatus(
                                          maintenanceId:
                                              maintenance.maintenanceId,
                                          request: MaintenanceStatusRequest(
                                            status: status,
                                          ),
                                        );

                                    if (success) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Cập nhật trạng thái thành công!',
                                          ),
                                        ),
                                      );

                                      final updatedMaintenance =
                                          await _fetchMaintenanceDetail();
                                      if (mounted &&
                                          updatedMaintenance != null) {
                                        setState(
                                          () {},
                                        ); // rebuild FutureBuilder
                                      }
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Cập nhật thất bại'),
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Maintenance Details
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
                          'Thông tin bảo dưỡng',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildDetailRow(
                          'ID bảo dưỡng:',
                          maintenance.maintenanceId,
                          Icons.tag,
                          isDarkMode,
                        ),
                        const SizedBox(height: 12),

                        _buildDetailRow(
                          'Xe:',
                          maintenance.vehicleId,
                          Icons.directions_car,
                          isDarkMode,
                        ),
                        const SizedBox(height: 12),

                        _buildDetailRow(
                          'Khách hàng:',
                          maintenance.customerId,
                          Icons.person,
                          isDarkMode,
                        ),
                        const SizedBox(height: 12),

                        _buildDetailRow(
                          'Nhân viên:',
                          maintenance.staffId,
                          Icons.engineering,
                          isDarkMode,
                        ),
                        const SizedBox(height: 12),

                        _buildDetailRow(
                          'Loại dịch vụ:',
                          maintenance.serviceTypeDisplayName,
                          Icons.build,
                          isDarkMode,
                        ),
                        const SizedBox(height: 12),

                        _buildDetailRow(
                          'Ngày bảo dưỡng:',
                          DateFormatter.formatDateVietnameseWithDay(
                            maintenance.serviceDate.toLocal(),
                          ),
                          Icons.calendar_today,
                          isDarkMode,
                        ),
                        const SizedBox(height: 12),

                        _buildDetailRow(
                          'Số km:',
                          '${maintenance.odometer} km',
                          Icons.speed,
                          isDarkMode,
                        ),
                        const SizedBox(height: 12),

                        if (maintenance.description.isNotEmpty) ...[
                          _buildDetailRow(
                            'Mô tả:',
                            maintenance.description,
                            Icons.description,
                            isDarkMode,
                          ),
                          const SizedBox(height: 12),
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
}
