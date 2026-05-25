import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DBProvider {
  DBProvider._();
  static final DBProvider instance = DBProvider._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'tekken_cheat_sheet.db');

    // Initialize sqflite FFI on desktop platforms so databaseFactory is set.
    // This prevents the "databaseFactory not initialized" error when running on Windows/Linux/MacOS.
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }


  FutureOr<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE my_characters(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        createdAt INTEGER
      )
    ''');
  }

    Future<void> checkIfTableExists(Database db, String tableName) async {
      final result = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
        [tableName],
      );
      if (result.isEmpty) {
        await db.execute('''
          CREATE TABLE $tableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            createdAt INTEGER
          )
        ''');
      }
    }
  // ---- CRUD basiques sur la table characters ----
  Future<int> insertMyCharacter(String name) async {
    final db = await database;
    checkIfTableExists(db, 'my_characters');
    Map<String, dynamic> character = {
      'name': name,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };
    return await db.insert('my_characters', character, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getAllMyCharacters() async {
    final db = await database;
    checkIfTableExists(db, 'my_characters');
    return await db.query('my_characters', orderBy: 'createdAt DESC');
  }

  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}