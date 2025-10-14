import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/login_request.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart';
import 'home_screen.dart';


// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//   bool _obscurePassword = true;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authProvider = Provider.of<AuthProvider>(context);
    
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 const SizedBox(height: 60),
//                 Icon(
//                   Icons.electric_car,
//                   size: 80,
//                   color: Theme.of(context).colorScheme.primary,
//                 ),
//                 const SizedBox(height: 24),
//                 Text(
//                   'EV Maintenance',
//                   textAlign: TextAlign.center,
//                   style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Quản lý bảo dưỡng xe điện',
//                   textAlign: TextAlign.center,
//                   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                         color: Colors.grey[600],
//                       ),
//                 ),
//                 const SizedBox(height: 48),
//                 TextFormField(
//                   controller: _emailController,
//                   keyboardType: TextInputType.emailAddress,
//                   decoration: InputDecoration(
//                     labelText: 'Email',
//                     prefixIcon: const Icon(Icons.email_outlined),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Vui lòng nhập email';
//                     }
//                     if (!value.contains('@')) {
//                       return 'Email không hợp lệ';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _passwordController,
//                   obscureText: _obscurePassword,
//                   decoration: InputDecoration(
//                     labelText: 'Mật khẩu',
//                     prefixIcon: const Icon(Icons.lock_outlined),
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _obscurePassword
//                             ? Icons.visibility_outlined
//                             : Icons.visibility_off_outlined,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           _obscurePassword = !_obscurePassword;
//                         });
//                       },
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Vui lòng nhập mật khẩu';
//                     }
//                     if (value.length < 6) {
//                       return 'Mật khẩu phải có ít nhất 6 ký tự';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 24),
//                 SizedBox(
//                   height: 50,
//                   child: authProvider.isLoading
//                       ? const Center(child: CircularProgressIndicator())
//                       : ElevatedButton(
//                           onPressed: () async {
//                             if (_formKey.currentState!.validate()) {
//                               await authProvider.login(
//                                 LoginRequest(
//                                   email: _emailController.text.trim(),
//                                   password: _passwordController.text,
//                                 ),
//                               );
//                               if (authProvider.auth != null &&
//                                   authProvider.error == null) {
//                                 if (mounted) {
//                                   Navigator.pushAndRemoveUntil(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (_) => const HomeScreen(),
//                                     ),
//                                     (_) => false,
//                                   );
//                                 }
//                               }
//                             }
//                           },
//                           style: ElevatedButton.styleFrom(
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           child: const Text(
//                             'Đăng nhập',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                 ),
//                 if (authProvider.error != null) ...[
//                   const SizedBox(height: 16),
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.red[50],
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.red[200]!),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(Icons.error_outline, color: Colors.red[700]),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: Text(
//                             authProvider.error!,
//                             style: TextStyle(color: Colors.red[700]),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//                 const SizedBox(height: 24),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       'Chưa có tài khoản? ',
//                       style: TextStyle(color: Colors.grey[600]),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => const RegisterScreen(),
//                           ),
//                         );
//                       },
//                       child: const Text(
//                         'Đăng ký ngay',
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

//Fake login
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Không cần lấy authProvider để fake login
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Đăng nhập'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SizedBox(
            width: 360,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Chào mừng bạn', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 32),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Mật khẩu'),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      // Fake login thành công, direct sang HomeScreen
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (_) => false,
                      );
                    },
                    child: const Text('Đăng nhập', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    // Nếu muốn cũng fake đăng ký thì sửa hết RegisterScreen tương tự
                  },
                  child: const Text('Chưa có tài khoản? Đăng ký ngay', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}