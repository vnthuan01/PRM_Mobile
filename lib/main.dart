import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/auth_service.dart';
import 'providers/auth_provider.dart';
import 'theme_notifier.dart';
import 'app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

// ------------------- MAIN -------------------
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  final repo = AuthService();
  final authProvider = AuthProvider(repo);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => authProvider),
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
      home: const SplashScreen(), // 👈 Thêm SplashScreen làm màn đầu
    );
  }
}

// ------------------- SPLASH SCREEN -------------------
// ------------------- SPLASH / INTRO SCREEN -------------------
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeLogo;
  late Animation<double> _fadeText;

  bool _showIntro = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeLogo = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _fadeText = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
    );

    _controller.forward();

    _checkFirstRun();
  }

  Future<void> _checkFirstRun() async {
    await Future.delayed(const Duration(milliseconds: 2800));
    // Chỉ hiển thị intro một lần (ở đây bạn có thể lưu SharedPreferences)
    setState(() => _showIntro = true);
  }

  Future<void> _navigateNext() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.restoreSession();

    if (!mounted) return;

    if (authProvider.isLoggedIn && authProvider.currentUser != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(userData: authProvider.currentUser!),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ------------------- BUILD -------------------
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

  // ------------------- INTRO UI -------------------
  Widget _buildIntro(Color primaryColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FadeTransition(
          opacity: _fadeLogo,
          child: Icon(Icons.electric_car, size: 110, color: Colors.white),
        ),
        const SizedBox(height: 28),
        FadeTransition(
          opacity: _fadeText,
          child: const Text(
            "EV Service Center",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        FadeTransition(
          opacity: _fadeText,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              "Ứng dụng quản lý & bảo dưỡng xe điện thông minh — hiện đại, tiện lợi và thân thiện với môi trường.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
        ),
        const SizedBox(height: 60),

        // Nút bắt đầu
        FadeTransition(
          opacity: _fadeText,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 26),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 8,
            ),
            onPressed: _navigateNext,
            child: const Text(
              "Bắt đầu ngay",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
          ),
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
