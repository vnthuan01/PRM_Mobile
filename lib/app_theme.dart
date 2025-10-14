import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData themeFrom(Color seedColor, {Brightness brightness = Brightness.light}) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: brightness,
      ),
      scaffoldBackgroundColor: brightness == Brightness.light ? const Color(0xFFF5F5F5) : const Color(0xFF121212),
      useMaterial3: true,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: seedColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: const OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: seedColor),
        ),
        labelStyle: TextStyle(color: brightness == Brightness.light ? Color(0xFF757575) : Colors.white70),
        hintStyle: TextStyle(color: brightness == Brightness.light ? Color(0xFF757575) : Colors.white38),
      ),
    );
  }
}
