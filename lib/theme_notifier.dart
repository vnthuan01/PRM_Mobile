import 'package:flutter/material.dart';

class ThemeNotifier extends ChangeNotifier {
  Color _primaryColor;
  bool _isDarkMode;

  ThemeNotifier({Color initialColor = const Color(0xFF00BFA6), bool dark = false})
      : _primaryColor = initialColor,
        _isDarkMode = dark;

  Color get primaryColor => _primaryColor;
  bool get isDarkMode => _isDarkMode;

  void setPrimaryColor(Color color) {
    _primaryColor = color;
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
