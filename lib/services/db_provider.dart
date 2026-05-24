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
      CREATE TABLE characters(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        imagePath TEXT,
        notes TEXT,
        createdAt INTEGER
      )
    ''');
  }

  // ---- CRUD basiques sur la table characters ----
  Future<int> insertCharacter(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('characters', row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getAllCharacters() async {
    final db = await database;
    return await db.query('characters', orderBy: 'createdAt DESC');
  }

  Future<int> updateCharacter(Map<String, dynamic> row) async {
    final db = await database;
    return await db.update('characters', row, where: 'id = ?', whereArgs: [row['id']]);
  }

  Future<int> deleteCharacter(int id) async {
    final db = await database;
    return await db.delete('characters', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
