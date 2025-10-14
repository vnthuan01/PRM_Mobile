import 'package:flutter/material.dart';

class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final surface = theme.colorScheme.surface;
    final surfaceHigh = theme.colorScheme.surfaceVariant;
    final textSecondary = isDark ? Colors.grey[300] : Colors.grey[700];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin ứng dụng'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // App Icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(Icons.electric_car, size: 80, color: primary),
              ),
              const SizedBox(height: 24),

              // App Name
              Text(
                'EV Service Center',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // App Version
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Phiên bản 1.0.0',
                  style: TextStyle(
                    color: theme.colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // App Description Card
              _buildCard(
                context,
                title: 'Giới thiệu',
                icon: Icons.description,
                content:
                    'EV Service Center Maintenance Management System - Phần mềm quản lý bảo dưỡng xe điện cho trung tâm dịch vụ',
              ),
              const SizedBox(height: 16),

              // User Roles
              _buildCard(
                context,
                title: 'Đối tượng sử dụng',
                icon: Icons.people,
                contentWidget: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildUserRole(
                      context,
                      Icons.person,
                      'Customer',
                      'Khách hàng',
                      textSecondary,
                    ),
                    _buildUserRole(
                      context,
                      Icons.support_agent,
                      'Staff',
                      'Nhân viên',
                      textSecondary,
                    ),
                    _buildUserRole(
                      context,
                      Icons.engineering,
                      'Technician',
                      'Kỹ thuật viên',
                      textSecondary,
                    ),
                    _buildUserRole(
                      context,
                      Icons.admin_panel_settings,
                      'Admin',
                      'Quản trị viên',
                      textSecondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Customer Features
              _buildFeatureCard(
                context,
                'Chức năng Khách hàng',
                Icons.person_outline,
                [
                  _FeatureItem(
                    icon: Icons.notifications_active,
                    title: 'Theo dõi xe & nhắc nhở',
                    items: [
                      'Nhắc nhở bảo dưỡng định kỳ theo km hoặc thời gian',
                    ],
                  ),
                  _FeatureItem(
                    icon: Icons.calendar_today,
                    title: 'Đặt lịch dịch vụ',
                    items: [
                      'Đặt lịch bảo dưỡng/sửa chữa trực tuyến',
                      'Nhận xác nhận & thông báo trạng thái',
                    ],
                  ),
                  _FeatureItem(
                    icon: Icons.folder_open,
                    title: 'Quản lý hồ sơ & chi phí',
                    items: [
                      'Lưu lịch sử bảo dưỡng xe điện',
                      'Quản lý chi phí bảo dưỡng & sửa chữa',
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Staff Features
              _buildFeatureCard(
                context,
                'Chức năng Trung tâm dịch vụ',
                Icons.business,
                [
                  _FeatureItem(
                    icon: Icons.people_alt,
                    title: 'Quản lý khách hàng & xe',
                    items: ['Hồ sơ khách hàng & xe', 'Lịch sử dịch vụ'],
                  ),
                  _FeatureItem(
                    icon: Icons.event_note,
                    title: 'Quản lý lịch hẹn & dịch vụ',
                    items: [
                      'Tiếp nhận yêu cầu đặt lịch',
                      'Lập lịch cho kỹ thuật viên',
                    ],
                  ),
                  _FeatureItem(
                    icon: Icons.build_circle,
                    title: 'Quản lý quy trình bảo dưỡng',
                    items: [
                      'Theo dõi tiến độ từng xe',
                      'Ghi nhận tình trạng xe',
                    ],
                  ),
                  _FeatureItem(
                    icon: Icons.inventory_2,
                    title: 'Quản lý phụ tùng',
                    items: [
                      'Theo dõi số lượng phụ tùng',
                      'Kiểm soát tồn kho',
                      'AI gợi ý nhu cầu phụ tùng',
                    ],
                  ),
                  _FeatureItem(
                    icon: Icons.groups,
                    title: 'Quản lý nhân sự',
                    items: ['Phân công kỹ thuật viên theo ca/lịch'],
                  ),
                  _FeatureItem(
                    icon: Icons.attach_money,
                    title: 'Quản lý tài chính & báo cáo',
                    items: [
                      'Báo giá dịch vụ & hóa đơn',
                      'Quản lý doanh thu, chi phí, lợi nhuận',
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Contact Info
              Text(
                '© 2025 EV Service Center',
                style: TextStyle(color: textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Text(
                'Phát triển bởi Topic 7 Team',
                style: TextStyle(color: textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    String? content,
    Widget? contentWidget,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            contentWidget ??
                Text(
                  content ?? '',
                  style: TextStyle(
                    height: 1.5,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserRole(
    BuildContext context,
    IconData icon,
    String role,
    String label,
    Color? subtitleColor,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                role,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(label, style: TextStyle(color: subtitleColor, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    List<_FeatureItem> features,
  ) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...features.map((f) => _buildFeatureSection(context, f)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureSection(BuildContext context, _FeatureItem feature) {
    final textSecondary = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[300]
        : Colors.grey[700];
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                feature.icon,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                feature.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...feature.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(left: 26, bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: TextStyle(color: textSecondary, fontSize: 13),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String title;
  final List<String> items;

  _FeatureItem({required this.icon, required this.title, required this.items});
}
