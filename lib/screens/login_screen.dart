import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/dto/request/login_request.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import 'technician_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);

    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade700;
    final inputFill = isDark ? Colors.grey.shade900 : Colors.grey[100];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // --- Upper background với gradient ---
              Stack(
                children: [
                  Container(
                    height: 240,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [Colors.blueGrey.shade800, Colors.black87]
                            : [
                                theme.colorScheme.primary,
                                theme.colorScheme.primary,
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(36),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Icon(Icons.electric_car, size: 80, color: Colors.white),
                        const SizedBox(height: 16),
                        const Text(
                          'EV Maintenance',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Quản lý bảo dưỡng xe điện',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // --- Email ---
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: subTextColor),
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: subTextColor,
                          ),
                          filled: true,
                          fillColor: inputFill,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: subTextColor.withOpacity(0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.colorScheme.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập email';
                          }
                          if (!value.contains('@')) {
                            return 'Email không hợp lệ';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // --- Password ---
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu',
                          labelStyle: TextStyle(color: subTextColor),
                          prefixIcon: Icon(
                            Icons.lock_outlined,
                            color: subTextColor,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: subTextColor,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: inputFill,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: subTextColor.withOpacity(0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.colorScheme.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mật khẩu';
                          }
                          if (value.length < 2) {
                            return 'Mật khẩu phải có ít nhất 6 ký tự';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // --- Nút đăng nhập ---
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: authProvider.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: isDark ? 0 : 2,
                                ),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    final success = await authProvider.login(
                                      LoginRequest(
                                        email: _emailController.text.trim(),
                                        password: _passwordController.text,
                                      ),
                                    );

                                    if (!success &&
                                        authProvider.error != null) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(authProvider.error!),
                                            backgroundColor:
                                                Colors.red.shade700,
                                          ),
                                        );
                                      }
                                      authProvider.clearError();
                                      return;
                                    }

                                    if (authProvider.auth != null &&
                                        authProvider
                                            .auth!
                                            .data
                                            .token
                                            .isNotEmpty &&
                                        authProvider.error == null) {
                                      if (mounted) {
                                        final user =
                                            authProvider.auth!.data.user;
                                        if (user.role == 2 ||
                                            user.role.toString() == '2') {
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  TechnicianHomeScreen(
                                                    userData: user,
                                                  ),
                                            ),
                                            (_) => false,
                                          );
                                        } else {
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  HomeScreen(userData: user),
                                            ),
                                            (_) => false,
                                          );
                                        }
                                      }
                                    }
                                  }
                                },
                                child: const Text(
                                  'Đăng nhập',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      ),

                      // --- Hộp lỗi inline ---
                      if (authProvider.error != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.red.withOpacity(0.15)
                                : Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark
                                  ? Colors.red.shade700
                                  : Colors.red[200]!,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red[700]),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  authProvider.error!,
                                  style: TextStyle(color: Colors.red[700]),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: Colors.red[700]),
                                onPressed: () {
                                  authProvider.clearError();
                                },
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // --- Link đăng ký ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Chưa có tài khoản? ',
                            style: TextStyle(color: subTextColor),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Đăng ký ngay',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
