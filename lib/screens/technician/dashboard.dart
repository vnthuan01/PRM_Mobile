import 'package:flutter/material.dart';
import 'package:prm_project/model/dto/response/auth_response.dart';
import 'package:prm_project/screens/maintenance/maintenance_list_screen.dart';
import 'package:prm_project/providers/maintence_provider.dart';
import 'package:prm_project/services/maintenace_service.dart';
import 'package:provider/provider.dart';

class TechnicianDashboardTab extends StatelessWidget {
  final User user;
  const TechnicianDashboardTab({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== HEADER =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Xin chào, ${user.fullName.split(" ").last} 👋",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: primary.withValues(alpha: 0.15),
                    child: Icon(Icons.engineering_rounded, color: primary),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ===== CA LÀM VIỆC =====
              _buildShiftCard(theme, primary),
              const SizedBox(height: 24),

              // ===== KPI SUMMARY =====
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      icon: Icons.handyman_rounded,
                      color: Colors.blue,
                      label: "Đang xử lý",
                      value: "3",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      icon: Icons.pending_actions_rounded,
                      color: Colors.orange,
                      label: "Chờ xử lý",
                      value: "2",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      icon: Icons.verified_rounded,
                      color: Colors.green,
                      label: "Hoàn tất",
                      value: "8",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ===== QUICK ACTIONS =====
              _buildQuickActionsCard(context, theme, primary),
              const SizedBox(height: 28),

              // ===== XE ĐANG BẢO DƯỠNG =====
              Text(
                "Xe đang bảo dưỡng",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),

              _buildVehicleCard(
                theme,
                model: "VinFast VF e34",
                task: "Thay pin & kiểm tra hệ thống điện",
                progress: 0.7,
                color: Colors.blue,
                imageUrl:
                    "https://autopro8.mediacdn.vn/2021/8/25/autopro-vinfast-vf-e34-da2-16298276092781253989751.jpg",
              ),
              _buildVehicleCard(
                theme,
                model: "VinFast VF 8",
                task: "Bảo dưỡng định kỳ 10.000 km",
                progress: 0.45,
                color: Colors.orange,
                imageUrl:
                    "https://www.vinfastnewway.com.vn/wp-content/uploads/2022/08/vinfast-vf-8-mau-den.jpg",
              ),
              _buildVehicleCard(
                theme,
                model: "VinFast VF 5 Plus",
                task: "Đang rửa xe & kiểm tra hệ thống phanh",
                progress: 1.0,
                color: Colors.green,
                imageUrl:
                    "https://shop.vinfastauto.com/on/demandware.static/-/Sites-app_vinfast_vn-Library/default/dw2df39a3f/images/PDP/VF5/vf5-7.png",
              ),

              const SizedBox(height: 28),

              // ===== THÔNG BÁO =====
              Text(
                "Thông báo gần đây",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              _buildNotificationCard(
                "Xe VF 8 đã bàn giao lúc 15:30.",
                Icons.done_all_rounded,
                Colors.green,
              ),
              _buildNotificationCard(
                "Xe VF e34 cần kiểm tra lại pin trước khi bàn giao.",
                Icons.warning_amber_rounded,
                Colors.orange,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ====== COMPONENTS ======

  Widget _buildShiftCard(ThemeData theme, Color primary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: primary.withValues(alpha: 0.15),
            child: Icon(Icons.schedule_rounded, color: primary, size: 28),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Ca làm việc hôm nay",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                "08:00 - 17:00  |  Đang làm việc",
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required Color color,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVehicleCard(
    ThemeData theme, {
    required String model,
    required String task,
    required double progress,
    required Color color,
    required String imageUrl,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Ảnh nền
            Image.network(imageUrl, fit: BoxFit.cover),

            // Gradient phủ tối để chữ nổi bật
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.65)],
                ),
              ),
            ),

            // Nội dung nổi
            Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        color: color,
                        backgroundColor: Colors.white24,
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(String message, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(message, style: const TextStyle(fontSize: 14)),
      ),
    );
  }

  Widget _buildQuickActionsCard(
    BuildContext context,
    ThemeData theme,
    Color primary,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Thao tác nhanh",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider(
                          create: (_) =>
                              MaintenanceProvider(MaintenanceService()),
                          child: MaintenanceListScreen(),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.build_rounded),
                  label: const Text('Bảo dưỡng'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
