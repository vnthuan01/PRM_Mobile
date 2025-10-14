import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/auth_api.dart';
import 'repositories/auth_repository.dart';
import 'providers/auth_provider.dart';
import 'theme_notifier.dart';
import 'app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
	WidgetsFlutterBinding.ensureInitialized();
	await dotenv.load();
	runApp(
		ChangeNotifierProvider(
			create: (_) => ThemeNotifier(),
			child: const MyApp(),
		)
	);
}

class MyApp extends StatelessWidget {
	const MyApp({super.key});

	Future<bool> _checkLoggedIn() async {
		final prefs = await SharedPreferences.getInstance();
		final token = prefs.getString('authToken');
		return token != null && token.isNotEmpty;
	}

	@override
	Widget build(BuildContext context) {
		final apiBaseUrl = dotenv.env['API_BASE_URL'] ?? '';
		if (apiBaseUrl.isEmpty) {
			return const MaterialApp(
				home: Scaffold(
					body: Center(
						child: Text('Missing API_BASE_URL in .env', style: TextStyle(fontSize: 18)),
					),
				),
			);
		}
		final themeNotifier = Provider.of<ThemeNotifier>(context);
		final dio = Dio(BaseOptions(
			baseUrl: apiBaseUrl,
			headers: const {
				'Content-Type': 'application/json',
				'Accept': 'application/json',
			},
			connectTimeout: const Duration(seconds: 10),
			receiveTimeout: const Duration(seconds: 10),
		));
		final api = AuthApi(dio);
		final repo = AuthRepository(api);
		return MultiProvider(
			providers: [
				ChangeNotifierProvider(create: (_) => AuthProvider(repo)),
			],
			child: MaterialApp(
				title: 'Flutter Login Demo',
				theme: AppTheme.themeFrom(themeNotifier.primaryColor, brightness: Brightness.light),
				darkTheme: AppTheme.themeFrom(themeNotifier.primaryColor, brightness: Brightness.dark),
				themeMode: themeNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,
				home: FutureBuilder<bool>(
					future: _checkLoggedIn(),
					builder: (context, snapshot) {
						if (!snapshot.hasData) {
							return const Scaffold(body: Center(child: CircularProgressIndicator()));
						}
						if (snapshot.data == true) {
							return const HomeScreen();
						} else {
							return const LoginScreen();
						}
					},
				),
			),
		);
	}
}
