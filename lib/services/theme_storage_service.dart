import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ThemeStorageService {
  static final ThemeStorageService instance = ThemeStorageService._init();
  static Database? _database;
  static SharedPreferences? _prefs;

  ThemeStorageService._init();

  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<Database> get database async {
    if (_database != null) return _database!;

    if (kIsWeb) {
      throw UnsupportedError('SQLite is not supported on web platform');
    }

    _database = await _initDB('theme.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE theme_settings(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        isDarkMode INTEGER NOT NULL
      )
    ''');
  }

  Future<bool> getThemeMode() async {
    if (kIsWeb) {
      await _initPrefs();
      return _prefs!.getBool('isDarkMode') ?? false;
    } else {
      final db = await instance.database;
      final List<Map<String, dynamic>> maps = await db.query('theme_settings');
      if (maps.isEmpty) {
        // Initialize with default value
        await db.insert('theme_settings', {'isDarkMode': 0});
        return false;
      }
      return maps.first['isDarkMode'] == 1;
    }
  }

  Future<void> setThemeMode(bool isDarkMode) async {
    if (kIsWeb) {
      await _initPrefs();
      await _prefs!.setBool('isDarkMode', isDarkMode);
    } else {
      final db = await instance.database;
      await db.update(
        'theme_settings',
        {'isDarkMode': isDarkMode ? 1 : 0},
        where: 'id = 1',
      );
    }
  }

  Future<void> close() async {
    if (!kIsWeb) {
      final db = await instance.database;
      db.close();
    }
  }
}
