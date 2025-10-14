// lib/screens/privacy_screen.dart
import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chính sách Bảo mật'),
        centerTitle: true,
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chính sách Bảo mật dành cho Khách hàng',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Phiên bản: 1.0 — EV Service Center Maintenance Management System',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 18),

              // Introduction
              Text(
                '1. Giới thiệu',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Chúng tôi cam kết bảo vệ quyền riêng tư của Khách hàng. Văn bản này giải thích cách hệ thống quản lý, lưu trữ và sử dụng thông tin của bạn khi bạn sử dụng ứng dụng/dịch vụ bảo dưỡng xe điện.',
              ),
              const SizedBox(height: 16),

              // Data collected
              Text(
                '2. Dữ liệu thu thập',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              const Text('Dưới đây là những loại thông tin chúng tôi có thể thu thập từ Khách hàng:'),
              const SizedBox(height: 8),
              _bullet('Thông tin cá nhân: Họ và tên, số điện thoại, email.'),
              _bullet('Thông tin xe: model, VIN, thời gian mua, số km hiện tại.'),
              _bullet('Lịch sử dịch vụ: thời điểm bảo dưỡng, dịch vụ đã làm, chi phí, ghi chú kỹ thuật.'),
              _bullet('Thông tin đặt lịch và trạng thái: yêu cầu đặt lịch, xác nhận, trạng thái (chờ — đang bảo dưỡng — hoàn tất).'),
              const SizedBox(height: 16),

              // Use of data
              Text(
                '3. Mục đích sử dụng dữ liệu',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              const Text('Chúng tôi dùng dữ liệu của bạn để:'),
              const SizedBox(height: 8),
              _bullet('Cung cấp và quản lý lịch sử bảo dưỡng, lịch hẹn và thông báo trạng thái.'),
              _bullet('Gửi nhắc nhở bảo dưỡng định kỳ (theo km hoặc theo thời gian).'),
              _bullet('Hỗ trợ tính toán và hiển thị chi phí bảo dưỡng/quản lý hóa đơn.'),
              _bullet('Cải thiện dịch vụ, phân tích nhu cầu phụ tùng và đề xuất bảo dưỡng phù hợp.'),
              const SizedBox(height: 16),

              // Sharing data
              Text(
                '4. Chia sẻ và bảo mật dữ liệu',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                  'Dữ liệu của bạn chỉ được chia sẻ khi cần thiết cho việc vận hành dịch vụ hoặc khi bạn cho phép:'),
              const SizedBox(height: 8),
              _bullet('Với trung tâm dịch vụ để thực hiện bảo dưỡng và cập nhật trạng thái.'),
              _bullet('Với nhà cung cấp thanh toán nếu bạn chọn thanh toán online.'),
              _bullet('Không bán dữ liệu cá nhân cho bên thứ ba cho mục đích quảng cáo mà không có sự đồng ý rõ ràng.'),
              const SizedBox(height: 16),

              // Retention
              Text(
                '5. Lưu trữ và thời gian lưu dữ liệu',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                  'Hồ sơ bảo dưỡng và thông tin liên quan sẽ được lưu trữ để phục vụ lịch sử dịch vụ và hỗ trợ khách hàng. Bạn có quyền yêu cầu xóa hoặc xuất dữ liệu theo quy định pháp luật.'),
              const SizedBox(height: 16),

              // Rights
              Text(
                '6. Quyền của bạn',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              _bullet('Truy cập, sửa đổi thông tin cá nhân.'),
              _bullet('Yêu cầu xóa dữ liệu (theo chính sách và quy định pháp luật).'),
              _bullet('Rút hoặc cho phép chia sẻ dữ liệu với bên thứ ba.'),
              const SizedBox(height: 18),

              // Contact
              Text(
                '7. Liên hệ',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Nếu bạn có thắc mắc về chính sách bảo mật, vui lòng liên hệ trung tâm dịch vụ hoặc bộ phận hỗ trợ ứng dụng để được hỗ trợ.',
              ),
              const SizedBox(height: 28),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Đóng'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Nếu cần lưu xác nhận của user, gọi API tại đây
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Bạn đã đồng ý Chính sách Bảo mật')),
                        );
                      },
                      child: const Text('Chấp nhận'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // helper bullet
  static Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ',
              style: TextStyle(fontSize: 18, height: 1.45)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
