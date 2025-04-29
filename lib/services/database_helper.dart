import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/draft_entry_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static SharedPreferences? _prefs;

  DatabaseHelper._init();

  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<Database> get database async {
    if (_database != null) return _database!;

    if (kIsWeb) {
      throw UnsupportedError('SQLite is not supported on web platform');
    }

    _database = await _initDB('drafts.db');
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
      CREATE TABLE drafts(
        id TEXT PRIMARY KEY,
        content TEXT NOT NULL,
        topicId TEXT NOT NULL,
        createdBy TEXT NOT NULL,
        createdAt TEXT,
        updatedAt TEXT
      )
    ''');
  }

  Future<String> createDraft(DraftEntryModel draft) async {
    if (kIsWeb) {
      await _initPrefs();
      final drafts = await _getWebDrafts();
      drafts.add(draft);
      await _saveWebDrafts(drafts);
      return draft.id!;
    } else {
      final db = await instance.database;
      await db.insert('drafts', draft.toMap());
      return draft.id!;
    }
  }

  Future<List<DraftEntryModel>> getAllDrafts() async {
    if (kIsWeb) {
      final drafts = await _getWebDrafts();
      drafts.sort((a, b) => (b.createdAt ?? DateTime.now())
          .compareTo(a.createdAt ?? DateTime.now()));
      return drafts;
    } else {
      final db = await instance.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'drafts',
        orderBy: 'createdAt DESC',
      );
      return List.generate(maps.length, (i) {
        return DraftEntryModel.fromMap(maps[i], maps[i]['id']);
      });
    }
  }

  Future<List<DraftEntryModel>> getDraftsByTopic(String topicId) async {
    if (kIsWeb) {
      final drafts = await _getWebDrafts();
      return drafts.where((draft) => draft.topicId == topicId).toList();
    } else {
      final db = await instance.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'drafts',
        where: 'topicId = ?',
        whereArgs: [topicId],
      );
      return List.generate(maps.length, (i) {
        return DraftEntryModel.fromMap(maps[i], maps[i]['id']);
      });
    }
  }

  Future<DraftEntryModel?> getDraft(String id) async {
    if (kIsWeb) {
      final drafts = await _getWebDrafts();
      try {
        return drafts.firstWhere((draft) => draft.id == id);
      } catch (e) {
        return null;
      }
    } else {
      final db = await instance.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'drafts',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return DraftEntryModel.fromMap(maps.first, maps.first['id']);
      }
      return null;
    }
  }

  Future<void> updateDraft(DraftEntryModel draft) async {
    if (kIsWeb) {
      final drafts = await _getWebDrafts();
      final index = drafts.indexWhere((d) => d.id == draft.id);
      if (index != -1) {
        drafts[index] = draft;
        await _saveWebDrafts(drafts);
      }
    } else {
      final db = await instance.database;
      await db.update(
        'drafts',
        draft.toMap(),
        where: 'id = ?',
        whereArgs: [draft.id],
      );
    }
  }

  Future<void> deleteDraft(String id) async {
    if (kIsWeb) {
      final drafts = await _getWebDrafts();
      drafts.removeWhere((draft) => draft.id == id);
      await _saveWebDrafts(drafts);
    } else {
      final db = await instance.database;
      await db.delete(
        'drafts',
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<void> deleteDraftsByTopic(String topicId) async {
    if (kIsWeb) {
      final drafts = await _getWebDrafts();
      drafts.removeWhere((draft) => draft.topicId == topicId);
      await _saveWebDrafts(drafts);
    } else {
      final db = await instance.database;
      await db.delete(
        'drafts',
        where: 'topicId = ?',
        whereArgs: [topicId],
      );
    }
  }

  Future<void> close() async {
    if (!kIsWeb) {
      final db = await instance.database;
      db.close();
    }
  }

  // Web storage helpers
  Future<List<DraftEntryModel>> _getWebDrafts() async {
    await _initPrefs();
    final String? draftsJson = _prefs!.getString('drafts');
    if (draftsJson == null) return [];

    try {
      final List<dynamic> draftsData = json.decode(draftsJson);
      return draftsData.map((data) {
        final map = Map<String, dynamic>.from(data);
        return DraftEntryModel.fromMap(map, map['id']);
      }).toList();
    } catch (e) {
      print('Error parsing drafts: $e');
      return [];
    }
  }

  Future<void> _saveWebDrafts(List<DraftEntryModel> drafts) async {
    await _initPrefs();
    try {
      final draftsData = drafts.map((draft) {
        final map = draft.toMap();
        map['id'] = draft.id;
        return map;
      }).toList();
      await _prefs!.setString('drafts', json.encode(draftsData));
    } catch (e) {
      print('Error saving drafts: $e');
    }
  }
}
