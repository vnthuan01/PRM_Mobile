// lib/screens/terms_screen.dart
import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Điều khoản Dịch vụ'),
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
              Text('Điều khoản Dịch vụ dành cho Khách hàng',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
              const SizedBox(height: 12),
              const Text(
                'Phiên bản: 1.0 — EV Service Center Maintenance Management System',
              ),
              const SizedBox(height: 18),

              Text(
                '1. Phạm vi áp dụng',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Các điều khoản dưới đây mô tả quyền và nghĩa vụ khi bạn (Khách hàng) sử dụng ứng dụng để đặt lịch, nhận thông báo và theo dõi hồ sơ bảo dưỡng xe điện tại trung tâm dịch vụ.',
              ),
              const SizedBox(height: 16),

              Text(
                '2. Dịch vụ dành cho Khách hàng',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              _bullet('Theo dõi xe & nhắc nhở: hệ thống gửi nhắc nhở bảo dưỡng theo km hoặc theo thời gian.'),
              _bullet('Đặt lịch dịch vụ: bạn có thể đặt lịch bảo dưỡng/sửa chữa trực tuyến.'),
              _bullet('Thông báo trạng thái: bạn sẽ nhận xác nhận và các trạng thái: chờ → đang bảo dưỡng → hoàn tất.'),
              _bullet('Quản lý hồ sơ & chi phí: lưu lịch sử bảo dưỡng và chi phí từng lần.'),
              const SizedBox(height: 16),

              Text(
                '3. Quy trình đặt lịch & hủy lịch',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              const Text('• Đặt lịch: Khách hàng chọn thời gian, loại dịch vụ, và xe. Trung tâm sẽ xác nhận.'),
              const SizedBox(height: 6),
              const Text('• Hủy/Sửa lịch: Khách hàng có thể hủy/sửa trong khung thời gian cho phép. Trung tâm có thể áp dụng phí theo chính sách.'),
              const SizedBox(height: 16),

              Text(
                '4. Thanh toán',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                  'Hệ thống hỗ trợ hiển thị báo giá, phát hành hóa đơn và các phương thức thanh toán online/offline. Mọi giao dịch online có thể được xử lý bởi nhà cung cấp thanh toán bên thứ ba tuân theo chính sách bảo mật.'),
              const SizedBox(height: 16),

              Text(
                '5. Trách nhiệm của Khách hàng',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              _bullet('Cung cấp thông tin chính xác về xe và thông tin liên hệ.'),
              _bullet('Đến đúng giờ theo lịch hẹn hoặc thông báo nếu thay đổi.'),
              _bullet('Thanh toán đầy đủ theo quy định và chính sách trung tâm.'),
              const SizedBox(height: 16),

              Text(
                '6. Giới hạn trách nhiệm',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                  'Mặc dù chúng tôi cố gắng cung cấp thông tin chính xác, trung tâm và ứng dụng có thể không chịu trách nhiệm cho thiệt hại phát sinh do việc sử dụng dịch vụ không đúng hướng dẫn hoặc do các yếu tố nằm ngoài tầm kiểm soát.'),
              const SizedBox(height: 16),

              Text(
                '7. Sửa đổi điều khoản',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                  'Chúng tôi có thể cập nhật điều khoản để cải thiện dịch vụ. Mọi thay đổi sẽ được thông báo rõ ràng trong ứng dụng.'),
              const SizedBox(height: 18),

              Text(
                '8. Liên hệ hỗ trợ',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                  'Nếu có khiếu nại hoặc thắc mắc, vui lòng liên hệ trung tâm dịch vụ hoặc bộ phận hỗ trợ ứng dụng (số điện thoại / email / form liên hệ).'),
              const SizedBox(height: 28),

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
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Bạn đã chấp nhận Điều khoản Dịch vụ')),
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

  static Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 18, height: 1.45)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
