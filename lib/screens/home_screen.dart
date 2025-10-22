// HomeScreen.dart
import 'package:flutter/material.dart';
import 'package:prm_project/providers/vehicle_provider.dart';
import 'package:prm_project/screens/vehicle/vehicle_create.dart';
import 'package:prm_project/widgets/booking_card.dart';
import 'package:prm_project/widgets/feature_card.dart';
import 'package:prm_project/widgets/service_card.dart';
import 'package:prm_project/widgets/vehicle_card.dart';
import 'package:provider/provider.dart';
import 'package:prm_project/screens/appointment/appointment_create_screen.dart';
import 'package:prm_project/screens/appointment/appointment_list_screen.dart';
import 'package:prm_project/screens/maintenance/maintenance_list_screen.dart';
import 'package:prm_project/providers/auth_provider.dart';
import 'package:prm_project/providers/maintence_provider.dart';
import 'package:prm_project/services/maintenace_service.dart';
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
      _HomeTab(userData: widget.userData),
      AppointmentListScreen(),
      ChangeNotifierProvider(
        create: (_) => MaintenanceProvider(MaintenanceService()),
        child: MaintenanceListScreen(),
      ),
      ProfileScreen(userData: widget.userData),
      Container(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final surfaceColor = theme.colorScheme.surface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: IndexedStack(index: _currentIndex, children: _pages),

      // --- Floating Action Button ở giữa ---
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 25),
        child: FloatingActionButton(
          elevation: 4,
          backgroundColor: Theme.of(context).colorScheme.primary,
          onPressed: () async {
            final authProvider = Provider.of<AuthProvider>(
              context,
              listen: false,
            );
            final customerId = authProvider.customerId ?? '';

            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VehicleCreateScreen(customerId: customerId),
              ),
            );

            if (result == true) {
              final vehicleProvider = Provider.of<VehicleProvider>(
                context,
                listen: false,
              );
              vehicleProvider.fetchVehicles(customerId);
            }
          },
          child: const Icon(Icons.add, size: 22, color: Colors.white),
        ),
      ),

      // --- Bottom Navigation ---
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 76,
          color: Colors.transparent,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                height: 60,
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: theme.brightness == Brightness.dark
                          ? Colors.black.withOpacity(0.5)
                          : Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _BottomNavItem(
                      icon: Icons.home_filled,
                      label: 'Trang chủ',
                      index: 0,
                      currentIndex: _currentIndex,
                      activeColor: primaryColor,
                      onTap: _onItemTapped,
                    ),
                    _BottomNavItem(
                      icon: Icons.list_alt,
                      label: 'Đặt lịch',
                      index: 1,
                      currentIndex: _currentIndex,
                      activeColor: primaryColor,
                      onTap: _onItemTapped,
                    ),
                    const SizedBox(width: 56), // chừa chỗ cho nút +
                    _BottomNavItem(
                      icon: Icons.build_circle,
                      label: 'Bảo dưỡng',
                      index: 2,
                      currentIndex: _currentIndex,
                      activeColor: primaryColor,
                      onTap: _onItemTapped,
                    ),
                    _BottomNavItem(
                      icon: Icons.person,
                      label: 'Tài khoản',
                      index: 3,
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
    final theme = Theme.of(context);
    final bool isActive = index == currentIndex;
    final inactiveColor = theme.brightness == Brightness.dark
        ? Colors.grey[300]
        : Colors.grey[600];

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
                Icon(icon, size: 28, color: inactiveColor),
            ],
          ),
        ),
      ),
    );
  }
}

// HomeTab
class _HomeTab extends StatefulWidget {
  final User userData;
  const _HomeTab({required this.userData});

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final String bannerImage =
      "https://www.electricbee.co/content/images/size/w1200/2024/05/charge-23.jpg";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vehicleProvider = Provider.of<VehicleProvider>(
        context,
        listen: false,
      );
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final customerId = authProvider.customerId ?? '';
      if (customerId.isNotEmpty) {
        vehicleProvider.fetchVehicles(customerId);
      }
    });
  }

  static final List<Service> services = [
    Service(name: 'Bảo dưỡng định kỳ', icon: Icons.build),
    Service(name: 'Kiểm tra pin', icon: Icons.battery_charging_full),
    Service(name: 'Bảo dưỡng phanh', icon: Icons.precision_manufacturing),
    Service(name: 'Thay lốp', icon: Icons.tire_repair),
    Service(name: 'Lịch sử bảo dưỡng', icon: Icons.history),
    Service(name: 'Quản lý bảo dưỡng', icon: Icons.engineering),
  ];

  static final List<Feature> specialForYou = [
    Feature(
      icon: Icons.electric_bike,
      title: 'Ưu đãi pin',
      subtitle: 'Giảm giá 20% khi thay pin',
    ),
    Feature(
      icon: Icons.build_circle,
      title: 'Dịch vụ định kỳ',
      subtitle: 'Bảo dưỡng toàn diện xe của bạn',
    ),
  ];

  final Booking? inProgressBooking = Booking(
    code: 'REQ251017001',
    service: 'Bảo dưỡng định kỳ',
    vehicle: 'VF e34',
    status: 'In Progress',
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final surfaceColor = theme.colorScheme.surface;
    final textColor = theme.colorScheme.onSurface;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: false,
            snap: false,
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            toolbarHeight: 80,
            flexibleSpace: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProfileScreen(userData: widget.userData),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: primaryColor,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark
                            ? Colors.grey[800]
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm',
                          hintStyle: TextStyle(
                            color: theme.brightness == Brightness.dark
                                ? Colors.grey[400]
                                : Colors.grey[500],
                          ),
                          border: InputBorder.none,
                          prefixIcon: Icon(
                            Icons.search,
                            color: textColor.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Banner
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            sliver: SliverToBoxAdapter(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Image.network(
                      bannerImage,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) =>
                          progress == null
                          ? child
                          : const SizedBox(
                              height: 160,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                      errorBuilder: (context, error, stackTrace) => SizedBox(
                        height: 160,
                        child: Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 160,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.3),
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Text(
                        'Chào mừng ${widget.userData.fullName}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // #SpecialForYou
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#SpecialForYou',
                    style: theme.textTheme.titleMedium?.copyWith(
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
                          child: FeatureCard(
                            feature: item,
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
          // Dịch vụ
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor.withOpacity(0.08),
                    surfaceColor.withOpacity(0.9),
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
                  return ServiceCard(
                    service: s,
                    onTap: () {
                      final authProvider = Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      );

                      // Navigate based on service type
                      if (s.name == 'Lịch sử bảo dưỡng') {
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
                      } else if (s.name == 'Quản lý bảo dưỡng') {
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
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AppointmentListScreen(),
                          ),
                        );
                      }
                    },
                  );
                }).toList(),
              ),
            ),
          ),
          // Xe của khách
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Xe của bạn',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 220,
                    child: Consumer<VehicleProvider>(
                      builder: (context, vehicleProvider, _) {
                        final vehicles = vehicleProvider.vehicles;
                        if (vehicles.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.electric_bike,
                                  size: 60,
                                  color: theme.brightness == Brightness.dark
                                      ? Colors.grey[400]
                                      : Colors.grey[400],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Chưa có xe nào',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: theme.brightness == Brightness.dark
                                        ? Colors.grey[300]
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const ClampingScrollPhysics(),
                          itemCount: vehicles.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 16),
                          itemBuilder: (context, index) {
                            final vehicle = vehicles[index];
                            return VehicleCard(
                              vehicle: Vehicle(
                                name: vehicle.model,
                                status: vehicle.status,
                              ),
                            );
                          },
                        );
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
                child: BookingCard(booking: inProgressBooking!),
              ),
            ),
        ],
      ),
    );
  }
}
