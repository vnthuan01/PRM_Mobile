import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_notifier.dart';
import 'app_info.dart';
import 'privacy_screen.dart';
import 'term_screen.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Giao diện',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.color_lens, color: themeNotifier.primaryColor),
            title: const Text('Đổi chủ đề màu sắc'),
            subtitle: const Text('Tùy chỉnh màu sắc ứng dụng'),
            trailing: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: themeNotifier.primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[300]!, width: 2),
              ),
            ),
            onTap: () {
              _showColorPicker(context, themeNotifier);
            },
          ),
          const Divider(height: 1, indent: 72),
          ListTile(
            leading: Icon(
              themeNotifier.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Chế độ tối'),
            subtitle: Text(
              themeNotifier.isDarkMode ? 'Đang bật' : 'Đang tắt',
            ),
            trailing: Switch(
              value: themeNotifier.isDarkMode,
              onChanged: (_) => themeNotifier.toggleTheme(),
            ),
          ),
          const Divider(height: 1, indent: 72),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'Thông tin',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
            title: const Text('Thông tin ứng dụng'),
            subtitle: const Text('Phiên bản & chi tiết'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AppInfoScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1, indent: 72),
          ListTile(
            leading: Icon(Icons.privacy_tip_outlined, color: Theme.of(context).colorScheme.primary),
            title: const Text('Chính sách bảo mật'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PrivacyScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1, indent: 72),
          ListTile(
            leading: Icon(Icons.description_outlined, color: Theme.of(context).colorScheme.primary),
            title: const Text('Điều khoản sử dụng'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TermsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showColorPicker(BuildContext context, ThemeNotifier themeNotifier) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.cyan,
      Colors.amber,
      const Color(0xFF00BFA6) // Cyan brand
    ];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn màu chủ đề'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: colors.length,
            itemBuilder: (context, index) {
              final color = colors[index];
              final isSelected = color.value == themeNotifier.primaryColor.value;
              return GestureDetector(
                onTap: () {
                  themeNotifier.setPrimaryColor(color);
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.black : Colors.grey[300]!,
                      width: isSelected ? 3 : 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 24,
                        )
                      : null,
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}
