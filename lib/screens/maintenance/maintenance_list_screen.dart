import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prm_project/model/maintenance.dart';
import 'package:prm_project/providers/maintence_provider.dart';
import 'package:prm_project/providers/auth_provider.dart';
import 'package:prm_project/screens/maintenance/maintenance_detail_screen.dart';
import 'package:prm_project/utils/date_formatter.dart';

class MaintenanceListScreen extends StatefulWidget {
  const MaintenanceListScreen({super.key});

  @override
  State<MaintenanceListScreen> createState() => _MaintenanceListScreenState();
}

class _MaintenanceListScreenState extends State<MaintenanceListScreen>
    with AutomaticKeepAliveClientMixin {
  bool _initialized = false;
  MaintenanceStatus? _selectedStatus;

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchInitial();
      });
      _initialized = true;
    }
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification) {
      final provider = context.read<MaintenanceProvider>();
      if (notification.metrics.pixels >=
              notification.metrics.maxScrollExtent - 200 &&
          !provider.isFetchingMore &&
          provider.hasMore) {
        Future.microtask(() {
          if (mounted) _fetchMore();
        });
      }
    }
    return false;
  }

  Future<void> _fetchInitial() async {
    final auth = context.read<AuthProvider>();
    final provider = context.read<MaintenanceProvider>();

    String? id;
    UserRole? role;

    if (auth.isCustomer && auth.customerId != null) {
      id = auth.customerId;
      role = UserRole.Customer;
    } else if (auth.isTechnician && auth.staffId != null) {
      id = auth.staffId;
      role = UserRole.Technician;
    }

    if (id != null && role != null) {
      await provider.fetchMaintenances(userId: id, role: role, newPagesize: 5);
    }
  }

  Future<void> _fetchMore() async {
    final auth = context.read<AuthProvider>();
    final provider = context.read<MaintenanceProvider>();

    String? id;
    UserRole? role;

    if (auth.isCustomer && auth.customerId != null) {
      id = auth.customerId;
      role = UserRole.Customer;
    } else if (auth.isTechnician && auth.staffId != null) {
      id = auth.staffId;
      role = UserRole.Technician;
    }

    if (id != null && role != null) {
      await provider.fetchMoreMaintenances(userId: id, role: role);
    }
  }

  Color _getStatusColor(MaintenanceStatus status, bool isDark) {
    switch (status) {
      case MaintenanceStatus.Pending:
        return isDark ? Colors.orange[600]! : Colors.orange[400]!;
      case MaintenanceStatus.InProgress:
        return isDark ? Colors.blue[600]! : Colors.blue[400]!;
      case MaintenanceStatus.Completed:
        return isDark ? Colors.green[600]! : Colors.green[400]!;
      case MaintenanceStatus.Cancelled:
        return isDark ? Colors.red[600]! : Colors.red[400]!;
    }
  }

  String _statusDisplayName(MaintenanceStatus status) {
    switch (status) {
      case MaintenanceStatus.Pending:
        return "Đang chờ";
      case MaintenanceStatus.InProgress:
        return "Đang thực hiện";
      case MaintenanceStatus.Completed:
        return "Hoàn thành";
      case MaintenanceStatus.Cancelled:
        return "Đã hủy";
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        title: Consumer<AuthProvider>(
          builder: (context, auth, _) => Text(
            auth.isTechnician ? 'Danh sách bảo dưỡng' : 'Lịch sử bảo dưỡng',
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchInitial),
        ],
      ),
      body: Column(
        children: [
          // Filter dropdown
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: DropdownButton<MaintenanceStatus?>(
              value: _selectedStatus,
              hint: const Text("Tất cả"),
              isExpanded: true,
              items: [
                const DropdownMenuItem(value: null, child: Text("Tất cả")),
                ...MaintenanceStatus.values.map(
                  (status) => DropdownMenuItem(
                    value: status,
                    child: Text(_statusDisplayName(status)),
                  ),
                ),
              ],
              onChanged: (value) async {
                setState(() {
                  _selectedStatus = value;
                });
                // Fetch data based on selected status
                if (value != null) {
                  final provider = context.read<MaintenanceProvider>();
                  await provider.fetchMaintenancesByStatus(value.index);
                } else {
                  // Fetch all data
                  _fetchInitial();
                }
              },
            ),
          ),
          Expanded(
            child: Consumer<MaintenanceProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.maintenances.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Filter maintenances based on selected status
                final filteredMaintenances = (_selectedStatus == null)
                    ? provider.maintenances
                    : provider.maintenances
                          .where((m) => m.maintenanceStatus == _selectedStatus)
                          .toList();

                if (filteredMaintenances.isEmpty) {
                  return const Center(
                    child: Text('Không có dữ liệu bảo dưỡng.'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _fetchInitial,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: _onScrollNotification,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount:
                          filteredMaintenances.length +
                          (provider.isFetchingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= filteredMaintenances.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final item = filteredMaintenances[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 4,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () async {
                              provider.selectMaintenance(item);
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MaintenanceDetailScreen(
                                    maintenanceId: item.maintenanceId,
                                  ),
                                ),
                              );
                              if (mounted) _fetchInitial();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Xe: ${item.vehicleModel ?? "Không rõ"} (${item.vehicleLicensePlate ?? "Chưa có"})',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: isDark
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              item.serviceTypeDisplayName,
                                              style: TextStyle(
                                                color: isDark
                                                    ? Colors.grey[300]
                                                    : Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(
                                            item.maintenanceStatus,
                                            isDark,
                                          ).withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          item.statusDisplayName,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: _getStatusColor(
                                              item.maintenanceStatus,
                                              isDark,
                                            ),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Ngày: ${DateFormatter.formatDateVietnamese(item.serviceDate.toLocal())}',
                                      ),
                                    ],
                                  ),
                                  if (item.description.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        item.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontStyle: FontStyle.italic,
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
              },
            ),
          ),
        ],
      ),
    );
  }
}
