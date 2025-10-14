import 'package:flutter/material.dart';
import 'list_screen.dart'; // Đảm bảo bạn đã import các màn hình
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Danh sách các trang không thay đổi
  final List<Widget> _pages = const [_HomeTab(), ListScreen(), ProfileScreen()];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: IndexedStack(index: _currentIndex, children: _pages),
      ),
      // 1. Đơn giản hóa cấu trúc BottomNavigationBar
      // Sử dụng Stack để cho phép item active "tràn" ra ngoài
      bottomNavigationBar: Container(
        height: 88, // Tăng chiều cao để có không gian cho item nổi lên
        color: Colors.transparent, // Nền của SizedBox là trong suốt
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            // Nền trắng bo góc của thanh bar
            Container(
              height: 64,
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // 2. Sử dụng widget _BottomNavItem mới cho tất cả các item
                  _BottomNavItem(
                    icon: Icons.list_alt,
                    label: 'Danh sách',
                    index: 1,
                    currentIndex: _currentIndex,
                    activeColor: primaryColor,
                    onTap: _onItemTapped,
                  ),
                  _BottomNavItem(
                    icon: Icons.home_filled,
                    label: 'Trang chủ',
                    index: 0,
                    currentIndex: _currentIndex,
                    activeColor: primaryColor,
                    onTap: _onItemTapped,
                  ),
                  _BottomNavItem(
                    icon: Icons.person,
                    label: 'Cá nhân',
                    index: 2,
                    currentIndex: _currentIndex,
                    activeColor: primaryColor,
                    onTap: _onItemTapped,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 3. Widget hợp nhất cho tất cả các item trong thanh điều hướng
class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;
  final Color activeColor;
  final Function(int) onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = index == currentIndex;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.translucent,
        child: SizedBox(
          height: double.infinity,
          child: Stack(
            clipBehavior: Clip.none, // cho phép icon nổi ra ngoài
            alignment: Alignment.center,
            children: [
              // Icon active
              if (isActive)
                Positioned(
                  top: -20, // nổi lên 20px trên container
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutBack,
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: activeColor,
                          boxShadow: [
                            BoxShadow(
                              color: activeColor.withValues(alpha: 0.4),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(icon, color: Colors.white, size: 26),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: TextStyle(
                          color: activeColor,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Icon(icon, size: 28, color: Colors.grey[600]),
            ],
          ),
        ),
      ),
    );
  }
}

// Màn hình Home Tab không thay đổi
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'EV Service Center Maintenance! \nWelcome to EV Service Center',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Tìm xe của bạn...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Category / Feature Grid
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              children: const [
                _FeatureCard(
                  icon: Icons.directions_car,
                  title: "Theo dõi xe",
                  subtitle: "Nhắc nhở bảo dưỡng định kỳ",
                ),
                _FeatureCard(
                  icon: Icons.schedule,
                  title: "Đặt lịch dịch vụ",
                  subtitle: "Bảo dưỡng hoặc sửa chữa trực tuyến",
                ),
                _FeatureCard(
                  icon: Icons.receipt_long,
                  title: "Quản lý hồ sơ",
                  subtitle: "Lưu lịch sử bảo dưỡng và chi phí",
                ),
                _FeatureCard(
                  icon: Icons.notifications,
                  title: "Thông báo",
                  subtitle: "Trạng thái: chờ – đang làm – hoàn tất",
                ),
              ],
            ),

            const SizedBox(height: 24),
            // Optional: nút "Xem tất cả" hoặc thêm section
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text(
                'Xem tất cả',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: () {
          // TODO: navigate đến màn hình chức năng tương ứng
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: primaryColor.withValues(alpha: 0.1),
                child: Icon(icon, color: primaryColor, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w100),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
