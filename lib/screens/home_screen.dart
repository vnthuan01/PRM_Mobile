// HomeScreen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prm_project/screens/appointment/appointment_create_screen.dart';
import 'package:prm_project/screens/appointment/appointment_list_screen.dart';
import 'package:prm_project/providers/auth_provider.dart';
import 'profile_screen.dart';
import '../model/dto/response/auth_response.dart';

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
      const AppointmentListScreen(), // Will get customerId from auth provider
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
                    color: Colors.black.withValues(alpha: 0.08),
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

// HomeTab
class _HomeTab extends StatelessWidget {
  final User userData;
  _HomeTab({required this.userData});

  static final List<_Service> services = [
    _Service('Kiểm tra pin', Icons.battery_charging_full),
    _Service('Bảo dưỡng định kỳ', Icons.build),
    _Service('Sửa chữa nhanh', Icons.flash_on),
    _Service('Vệ sinh xe', Icons.cleaning_services),
  ];

  static final List<_Vehicle> vehicles = [
    _Vehicle(
      'VF e34',
      'https://drive.gianhangvn.com/image/vinfast-vf-e34-xanh-duong-2282022j30802.jpg',
      'Đang bảo dưỡng',
    ),
    _Vehicle(
      'VF 8',
      'https://storage.googleapis.com/vinfast-data-01/danh-gia-hinh-anh-vf-8-ngoai-that_1671722603.jpg',
      'Hoàn tất',
    ),
  ];

  final _Booking? inProgressBooking = _Booking(
    code: 'REQ251017001',
    service: 'Bảo dưỡng định kỳ',
    vehicle: 'VF e34',
    status: 'In Progress',
  );

  // Demo #SpecialForYou items
  static final List<_Feature> specialForYou = [
    _Feature(Icons.electric_bike, 'Ưu đãi pin', 'Giảm giá 20% khi thay pin'),
    _Feature(
      Icons.build_circle,
      'Dịch vụ định kỳ',
      'Bảo dưỡng toàn diện xe của bạn',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // AppBar kiểu Sliver
          SliverAppBar(
            pinned: true,
            backgroundColor: primaryColor,
            expandedHeight: 100,
            elevation: 4,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor.withValues(alpha: 0.9),
                    primaryColor.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                title: Text(
                  'Welcome ${userData.fullName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),

          // Search field
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm xe của bạn...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.onSecondary,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          // #SpecialForYou Horizontal
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#SpecialForYou',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 170,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const ClampingScrollPhysics(),
                      itemCount: specialForYou.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final item = specialForYou[index];
                        return SizedBox(
                          width: 250,
                          child: _FeatureCard(
                            icon: item.icon,
                            title: item.title,
                            subtitle: item.subtitle,
                            onTap: () {
                              final authProvider = Provider.of<AuthProvider>(
                                context,
                                listen: false,
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AppointmentCreateScreen(
                                    customerId: authProvider.customerId ?? '',
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Dịch vụ bảo dưỡng Grid
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.08),
                    Theme.of(
                      context,
                    ).colorScheme.surface.withValues(alpha: 0.9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.0,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: services.map((s) {
                  return _ServiceCard(
                    service: s,
                    onTap: () {
                      final authProvider = Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AppointmentListScreen(
                            customerId: authProvider.customerId ?? '',
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          ),
          // Xe của khách Horizontal
          SliverPadding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Xe của bạn',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 220,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const ClampingScrollPhysics(),
                      itemCount: vehicles.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final vehicle = vehicles[index];
                        return _VehicleCard(vehicle: vehicle);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Booking in progress
          if (inProgressBooking != null)
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: _BookingCard(booking: inProgressBooking!),
              ),
            ),
        ],
      ),
    );
  }
}

// Service model & card
class _Service {
  final String name;
  final IconData icon;
  _Service(this.name, this.icon);
}

class _ServiceCard extends StatelessWidget {
  final _Service service;
  final VoidCallback? onTap; // <– thêm dòng này

  const _ServiceCard({required this.service, this.onTap});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap, // <– sử dụng onTap truyền vào
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: primaryColor.withValues(alpha: 0.1),
              child: Icon(service.icon, color: primaryColor, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              service.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

// Vehicle model & card
class _Vehicle {
  final String name;
  final String image;
  final String status;
  _Vehicle(this.name, this.image, this.status);
}

class _VehicleCard extends StatelessWidget {
  final _Vehicle vehicle;
  const _VehicleCard({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardWidth = 300.0;
    final cardHeight = 220.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          // Background image
          Image.network(
            vehicle.image,
            width: cardWidth,
            height: cardHeight,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) => progress == null
                ? child
                : SizedBox(
                    width: cardWidth,
                    height: cardHeight,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
            errorBuilder: (context, error, stackTrace) => SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: const Center(child: Icon(Icons.broken_image, size: 50)),
            ),
          ),
          // Gradient overlay
          Container(
            width: cardWidth,
            height: cardHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.cardColor.withValues(alpha: 0.6),
                  Colors.transparent,
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          // Text info
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: vehicle.status == 'Đang bảo dưỡng'
                        ? Colors.orangeAccent
                        : Colors.greenAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    vehicle.status,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
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

// Booking model & card
class _Booking {
  final String code;
  final String service;
  final String vehicle;
  final String status;
  _Booking({
    required this.code,
    required this.service,
    required this.vehicle,
    required this.status,
  });
}

class _BookingCard extends StatelessWidget {
  final _Booking booking;
  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final backgroundColor = theme.cardColor;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: primaryColor.withValues(alpha: 0.3),
      color: backgroundColor,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pending_actions, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Booking In Progress',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              booking.code,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${booking.vehicle} - ${booking.service}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  LinearProgressIndicator(
                    value: 0.6,
                    minHeight: 16,
                    backgroundColor: theme.dividerColor,
                    color: primaryColor,
                  ),
                  Positioned.fill(
                    child: Center(
                      child: Text(
                        booking.status,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
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
