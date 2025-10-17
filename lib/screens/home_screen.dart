// HomeScreen.dart
import 'package:flutter/material.dart';
import 'package:prm_project/screens/appointment/appointment_list_screen.dart';
import 'appointment/appointment_create_screen.dart';
import 'profile_screen.dart';
import '../model/auth_response.dart';

class HomeScreen extends StatefulWidget {
  final User userData;

  const HomeScreen({super.key, required this.userData});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _HomeTab(userData: widget.userData), // truyền userData vào HomeTab
      const AppointmentListScreen(),
      ProfileScreen(userData: widget.userData),
    ];
  }

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
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        height: 88,
        color: Colors.transparent,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
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

// Bottom nav item
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
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              if (isActive)
                Positioned(
                  top: -20,
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
                              color: activeColor.withOpacity(0.4),
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

// HomeTab
class _HomeTab extends StatelessWidget {
  final User userData;
  const _HomeTab({required this.userData});

  static final List<_Feature> features = [
    _Feature(Icons.directions_car, "Theo dõi xe", "Nhắc nhở bảo dưỡng định kỳ"),
    _Feature(
      Icons.schedule,
      "Đặt lịch dịch vụ",
      "Bảo dưỡng hoặc sửa chữa trực tuyến",
    ),
    _Feature(
      Icons.receipt_long,
      "Quản lý hồ sơ",
      "Lưu lịch sử bảo dưỡng và chi phí",
    ),
    _Feature(
      Icons.notifications,
      "Thông báo",
      "Trạng thái: chờ – đang làm – hoàn tất",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EV Service Center Maintenance!\nWelcome to EV Service Center',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm xe của bạn...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Theme.of(context).scaffoldBackgroundColor,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final f = features[index];
                return _FeatureCard(
                  icon: f.icon,
                  title: f.title,
                  subtitle: f.subtitle,
                  onTap: () async {
                    switch (f.title) {
                      case "Đặt lịch dịch vụ":
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AppointmentCreateScreen(
                              customerId: userData.id,
                            ),
                          ),
                        );
                        if (result == true) {
                          final homeState = context
                              .findAncestorStateOfType<_HomeScreenState>();
                          homeState?._onItemTapped(1);
                        }
                        break;
                      case "Theo dõi xe":
                        break;
                      case "Quản lý hồ sơ":
                        final homeState = context
                            .findAncestorStateOfType<_HomeScreenState>();
                        homeState?._onItemTapped(2);
                        break;
                      case "Thông báo":
                        break;
                    }
                  },
                );
              }, childCount: features.length),
            ),
          ),
        ],
      ),
    );
  }
}

// Feature
class _Feature {
  final IconData icon;
  final String title;
  final String subtitle;
  _Feature(this.icon, this.title, this.subtitle);
}

// FeatureCard
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w400),
                softWrap: true,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
