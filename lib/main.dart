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

  @override
  void initState() {
    super.initState();

    // 🎬 Tạo animation controller
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

    _controller.forward(); // Bắt đầu animation
    _initApp();
  }

  Future<void> _initApp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Cho animation chạy hết + delay nhẹ cho cảm giác loading
    await Future.delayed(const Duration(milliseconds: 3500));

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

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final primaryColor = themeNotifier.primaryColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: FadeTransition(
          opacity: _fadeLogo,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🔹 Logo
              FadeTransition(
                opacity: _fadeLogo,
                child: Icon(Icons.electric_car, size: 96, color: primaryColor),
              ),
              const SizedBox(height: 24),

              // 🔹 Tên app
              FadeTransition(
                opacity: _fadeText,
                child: Text(
                  "EV Service Center",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // 🔹 Mô tả
              FadeTransition(
                opacity: _fadeText,
                child: Text(
                  "Quản lý & bảo dưỡng xe điện thông minh",
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // 🔹 Loading indicator
              FadeTransition(
                opacity: _fadeText,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
