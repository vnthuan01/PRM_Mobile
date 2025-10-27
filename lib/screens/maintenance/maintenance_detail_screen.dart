import 'package:flutter/material.dart';
import 'package:prm_project/model/customer.dart';
import 'package:prm_project/model/dto/request/maintenance_status_request.dart';
import 'package:prm_project/model/dto/response/auth_response.dart';
import 'package:prm_project/model/dto/response/vehicle_response.dart';
import 'package:prm_project/model/maintenance.dart';
import 'package:prm_project/model/staff.dart';
import 'package:prm_project/providers/auth_provider.dart';
import 'package:prm_project/services/maintenace_service.dart';
import 'package:prm_project/services/user_service.dart';
import 'package:prm_project/services/vehicle_service.dart';
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

  Future<Map<String, dynamic>?> _fetchMaintenanceDetail() async {
    try {
      final maintenanceService = MaintenanceService();
      final userService = CustomerService();
      final vehicleService = VehicleService();

      final maintenance = await maintenanceService.getMaintenanceById(
        widget.maintenanceId,
      );
      if (maintenance == null) return null;

      final results = await Future.wait([
        userService.getCustomerByCustomerId(maintenance.customerId),
        userService.getStaffByStaffId(maintenance.staffId),
        vehicleService.getVehicleDetail(maintenance.vehicleId),
      ]);

      final customer = results[0] as Customer;
      final staff = results[1];
      final vehicle = results[2];
      print(customer.userId);

      return {
        'maintenance': maintenance,
        'customer': customer,
        'staff': staff,
        'vehicle': vehicle,
      };
    } catch (e, stack) {
      print('[MaintenanceDetailScreen] Error fetching maintenance detail: $e');
      print(stack);
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
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchMaintenanceDetail(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('Không thể tải chi tiết bảo dưỡng'));
          }

          final data = snapshot.data!;
          final maintenance = data['maintenance'] as Maintenance;
          final customer = data['customer'] as Customer?;
          final staff = data['staff'] as Staff?;
          final vehicle = data['vehicle'] as VehicleResponse;

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
                                        SnackBar(
                                          backgroundColor:
                                              Colors.green.shade600,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          content: Row(
                                            children: const [
                                              Icon(
                                                Icons.check_circle_outline,
                                                color: Colors.white,
                                              ),
                                              SizedBox(width: 12),
                                              Text(
                                                'Cập nhật trạng thái thành công!',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                          duration: const Duration(seconds: 2),
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
                                        SnackBar(
                                          backgroundColor: Colors.red.shade600,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          content: Row(
                                            children: const [
                                              Icon(
                                                Icons.error_outline,
                                                color: Colors.white,
                                              ),
                                              SizedBox(width: 12),
                                              Text(
                                                'Cập nhật thất bại',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                          duration: const Duration(seconds: 2),
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
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                  elevation: 6,
                  shadowColor: Colors.black26,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Header ---
                        Row(
                          children: [
                            const Icon(
                              Icons.build_circle_rounded,
                              size: 26,
                              color: Colors.blueAccent,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Thông tin bảo dưỡng',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        const Divider(thickness: 1),
                        const SizedBox(height: 16),

                        // --- Chi tiết thông tin ---
                        _buildInfoTile(
                          icon: Icons.directions_car_rounded,
                          label: 'Xe',
                          value: vehicle != null
                              ? '${vehicle.model ?? "Không rõ"} (${vehicle.licensePlate ?? "Chưa có"})'
                              : 'Đang tải thông tin xe...',
                          isDarkMode: isDarkMode,
                        ),
                        _buildInfoTile(
                          icon: Icons.person_rounded,
                          label: 'Khách hàng',
                          value: customer != null
                              ? '${customer.fullName ?? "Không rõ"} (${customer.email ?? "-"})'
                              : 'Đang tải thông tin khách hàng...',
                          isDarkMode: isDarkMode,
                        ),
                        _buildInfoTile(
                          icon: Icons.engineering_rounded,
                          label: 'Nhân viên',
                          value: staff != null
                              ? '${staff.fullName ?? "Không rõ"} (${staff.email ?? "-"})'
                              : 'Đang tải thông tin nhân viên...',
                          isDarkMode: isDarkMode,
                        ),
                        _buildInfoTile(
                          icon: Icons.home_repair_service_rounded,
                          label: 'Loại dịch vụ',
                          value: maintenance.serviceTypeDisplayName,
                          isDarkMode: isDarkMode,
                        ),
                        _buildInfoTile(
                          icon: Icons.calendar_today_rounded,
                          label: 'Ngày bảo dưỡng',
                          value: DateFormatter.formatDateVietnameseWithDay(
                            maintenance.serviceDate.toLocal(),
                          ),
                          isDarkMode: isDarkMode,
                        ),
                        _buildInfoTile(
                          icon: Icons.speed_rounded,
                          label: 'Số km',
                          value: '${maintenance.odometer} km',
                          isDarkMode: isDarkMode,
                        ),
                        if (maintenance.description.isNotEmpty)
                          _buildInfoTile(
                            icon: Icons.description_rounded,
                            label: 'Mô tả',
                            value: maintenance.description,
                            isDarkMode: isDarkMode,
                          ),
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

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required bool isDarkMode,
  }) {
    final textColor = isDarkMode ? Colors.white70 : Colors.black87;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 22,
            color: isDarkMode ? Colors.blue[200] : Colors.blueAccent,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: textColor.withOpacity(0.85),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
