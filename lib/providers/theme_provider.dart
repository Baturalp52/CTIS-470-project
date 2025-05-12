import 'package:flutter/material.dart';
import '../services/theme_storage_service.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  final ThemeStorageService _themeStorage = ThemeStorageService.instance;

  ThemeProvider() {
    _loadThemeMode();
  }

  bool get isDarkMode => _isDarkMode;

  Future<void> _loadThemeMode() async {
    _isDarkMode = await _themeStorage.getThemeMode();
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _themeStorage.setThemeMode(_isDarkMode);
    notifyListeners();
  }

  ThemeData get themeData {
    final baseTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF8E272A),
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        primary: const Color(0xFF8E272A),
        onPrimary: Colors.white,
        secondary: const Color(0xFF8E272A),
        onSecondary: Colors.white,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF8E272A),
        iconTheme: IconThemeData(color: Colors.white),
        actionsIconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF8E272A),
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF8E272A),
          foregroundColor: Colors.white,
        ),
      ),
    );

    return baseTheme;
  }
}
