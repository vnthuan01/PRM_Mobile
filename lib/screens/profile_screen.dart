import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import 'setting_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: "Nguyễn Văn A");
  final _phoneController = TextEditingController(text: "0987654321");

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân'),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: primaryColor.withOpacity(0.15),
                child: Icon(Icons.person, size: 44, color: primaryColor),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Không được để trống'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty
                    ? 'Không được để trống'
                    : null,
              ),
              const SizedBox(height: 24),
              CustomButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Đã lưu thông tin cá nhân")),
                    );
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.save, size: 20),
                    SizedBox(width: 8),
                    Text("Lưu thay đổi"),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Divider(height: 1, color: Colors.grey[300]),
              const SizedBox(height: 32),
              CustomButton(
                onPressed: _showChangePasswordModal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.lock, size: 20),
                    SizedBox(width: 8),
                    Text("Thay đổi mật khẩu"),
                  ],
                ),
              ),
              const SizedBox(height: 44),
              OutlinedButton.icon(
                icon: const Icon(Icons.settings, size: 26),
                label: const Text("Cài đặt ứng dụng"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePasswordModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _ChangePasswordSheet(),
    );
  }
}

// ==================== Change Password Modal ====================
class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet();

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _currentPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  double _passwordStrength = 0;
  String _passwordLabel = "Weak";
  Color _passwordColor = Colors.red;

  void _checkPasswordStrength(String value) {
    final theme = Theme.of(context);
    double strength = 0;

    if (value.isEmpty) {
      strength = 0;
    } else if (value.length < 6) {
      strength = 0.25;
    } else if (value.contains(RegExp(r'[A-Z]')) &&
        value.contains(RegExp(r'[0-9]')) &&
        value.contains(RegExp(r'[!@#\$&*~]'))) {
      strength = 1;
    } else if (value.contains(RegExp(r'[A-Z0-9]'))) {
      strength = 0.75;
    } else {
      strength = 0.5;
    }

    setState(() {
      _passwordStrength = strength;
      if (strength <= 0.25) {
        _passwordLabel = "Weak";
        _passwordColor = theme.colorScheme.error;
      } else if (strength <= 0.5) {
        _passwordLabel = "Medium";
        _passwordColor = Colors.orangeAccent;
      } else if (strength <= 0.75) {
        _passwordLabel = "Strong";
        _passwordColor = Colors.lightGreen;
      } else {
        _passwordLabel = "Too Strong";
        _passwordColor = Colors.green;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, bottomPadding + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Text(
              "Thay đổi mật khẩu",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 44),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _currentPassController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu hiện tại',
                      border: const OutlineInputBorder(),
                      labelStyle: theme.textTheme.bodyMedium,
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Vui lòng nhập mật khẩu hiện tại'
                        : null,
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _newPassController,
                    obscureText: true,
                    onChanged: _checkPasswordStrength,
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu mới',
                      border: const OutlineInputBorder(),
                      labelStyle: theme.textTheme.bodyMedium,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Vui lòng nhập mật khẩu mới';
                      if (value.length < 6)
                        return 'Mật khẩu phải có ít nhất 6 ký tự';
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _confirmPassController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Xác nhận mật khẩu mới',
                      border: const OutlineInputBorder(),
                      labelStyle: theme.textTheme.bodyMedium,
                    ),
                    validator: (value) {
                      if (value != _newPassController.text)
                        return 'Mật khẩu xác nhận không khớp';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Mật khẩu phải có ít nhất 6 ký tự, bao gồm chữ cái, số và ký tự đặc biệt",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // --- Strength Bar ---
                  Row(
                    children: [
                      Text(
                        "Độ mạnh mật khẩu",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: _passwordStrength,
                          color: _passwordColor,
                          backgroundColor: theme.dividerColor,
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _passwordLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _passwordColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: "Xác nhận",
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Đổi mật khẩu thành công"),
                          ),
                        );
                      }
                    },
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
