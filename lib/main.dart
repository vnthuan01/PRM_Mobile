import 'package:flutter/material.dart';
import 'package:prm_project/model/maintenance.dart';
import 'package:prm_project/providers/booking_provider.dart';
import 'package:prm_project/providers/maintence_provider.dart';
import 'package:prm_project/providers/vehicle_provider.dart';
import 'package:prm_project/services/booking_service.dart';
import 'package:prm_project/services/maintenace_service.dart';
import 'package:prm_project/services/vehicle_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'services/auth_service.dart';
import 'providers/auth_provider.dart';
import 'theme_notifier.dart';
import 'app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/technician_home_screen.dart';

// ------------------- MAIN -------------------
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  // Initialize Vietnamese locale data for date formatting
  await initializeDateFormatting('vi_VN', null);

  final repo = AuthService();
  final booking = BookingService();
  final vehicle = VehicleService();
  final maintenance = MaintenanceService();
  final authProvider = AuthProvider(repo);
  final bookingProvider = BookingProvider(booking);
  final vehicleProvider = VehicleProvider(vehicleService: vehicle);
  final maintenanceProvider = MaintenanceProvider(maintenance);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => authProvider),
        ChangeNotifierProvider(create: (_) => bookingProvider),
        ChangeNotifierProvider(create: (_) => vehicleProvider),
        ChangeNotifierProvider(create: (_) => maintenanceProvider),
      ],
      child: const MyApp(),
    ),
  );
}

// ------------------- APP -------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final apiBaseUrl = dotenv.env['API_BASE_URL'] ?? '';

    if (apiBaseUrl.isEmpty) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Missing API_BASE_URL in .env')),
        ),
      );
    }

    return MaterialApp(
      title: 'EV Service Center',
      theme: AppTheme.themeFrom(
        themeNotifier.primaryColor,
        brightness: Brightness.light,
      ),
      darkTheme: AppTheme.themeFrom(
        themeNotifier.primaryColor,
        brightness: Brightness.dark,
      ),
      themeMode: themeNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {'/login': (context) => LoginScreen()},
      home: const SplashScreen(), //Thêm SplashScreen làm màn đầu
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeLogo;
  late Animation<double> _fadeText;

  late AnimationController _carController;
  late Animation<Offset> _moveCar;
  late Animation<double> _scaleCar;

  bool _showIntro = true;

  @override
  void initState() {
    super.initState();

    // Fade animation cho logo & text
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeLogo = CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _fadeText = CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
    );
    _fadeController.forward();

    // Xe chạy animation
    _carController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    // Giai đoạn 1: xe chạy từ ngoài màn hình vào giữa
    _moveCar =
        Tween<Offset>(
          begin: const Offset(-1.5, 0),
          end: const Offset(0.0, 0),
        ).animate(
          CurvedAnimation(
            parent: _carController,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
          ),
        );

    // Giai đoạn 2: xe phóng to ra toàn màn hình rồi nhỏ lại
    _scaleCar = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.6,
          end: 2.5,
        ).chain(CurveTween(curve: Curves.easeOutExpo)),
        weight: 60,
      ), // zoom to
      TweenSequenceItem(
        tween: Tween(
          begin: 2.5,
          end: 0.9,
        ).chain(CurveTween(curve: Curves.easeInOutBack)),
        weight: 40,
      ), // zoom back
    ]).animate(_carController);

    _carController.forward();

    _checkFirstRun();
  }

  Future<void> _checkFirstRun() async {
    await Future.delayed(const Duration(milliseconds: 2800));
    // Ở đây có thể kiểm tra SharedPreferences nếu muốn chỉ intro lần đầu
    setState(() => _showIntro = true);
  }

  Future<void> _navigateNext() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.restoreSession();
    final user = authProvider.currentUser;

    if (!mounted) return;
    if (authProvider.isLoggedIn && user != null) {
      if (user.role == 2) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => TechnicianHomeScreen(userData: user),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen(userData: user)),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _carController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final primaryColor = themeNotifier.primaryColor;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(seconds: 1),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeLogo,
            child: _showIntro
                ? _buildIntro(primaryColor)
                : _buildLoading(primaryColor),
          ),
        ),
      ),
    );
  }

  Widget _buildIntro(Color primaryColor) {
    return Stack(
      children: [
        // Text
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Xe ở dưới text
            Positioned(
              bottom: 40, // căn từ dưới
              left: 0,
              right: 0,
              child: SlideTransition(
                position: _moveCar,
                child: ScaleTransition(
                  scale: _scaleCar,
                  child: Opacity(
                    opacity: 0.9,
                    child: Image.asset('assets/car_background.png', width: 220),
                  ),
                ),
              ),
            ),
            FadeTransition(
              opacity: _fadeText,
              child: const Text(
                "EV Service Center",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            FadeTransition(
              opacity: _fadeText,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  "Ứng dụng quản lý & bảo dưỡng xe điện thông minh...",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 60),
            FadeTransition(
              opacity: _fadeText,
              child: ElevatedButton(
                onPressed: _navigateNext,
                child: const Text("Bắt đầu ngay"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ------------------- LOADING UI -------------------
  Widget _buildLoading(Color primaryColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.electric_car, size: 96, color: primaryColor),
        const SizedBox(height: 20),
        const CircularProgressIndicator(color: Colors.white),
      ],
    );
  }
}
