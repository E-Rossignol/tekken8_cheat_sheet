import 'dart:async';
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

  Future<Database> initDb() async {
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
    await db.execute('''
      CREATE TABLE key_moves(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        characterName TEXT NOT NULL,
        inputs TEXT NOT NULL,
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
    Map<String, dynamic> character = {
      'name': name,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };
    return await db.insert('my_characters', character, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> insertKeyMove(String characterName, String input) async {
    final db = await database;
    List<Map<String, dynamic>> existingChars = await getAllMyCharacters();
    if (!existingChars.any((c) => c['name'] == characterName)) {
      await insertMyCharacter(characterName);
    }
    Map<String, dynamic> move = {
      'characterName': characterName ,
      'inputs': input,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };
    return await db.insert('key_moves', move, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<String>> getKeyMovesForCharacter(String characterName) async {
    final db = await database;
    final res = await db.query(
      'key_moves',
      where: 'characterName = ?',
      whereArgs: [characterName],
      orderBy: 'createdAt DESC',
    );
    return res.map((row) => row['inputs'] as String).toList();
  }

  Future<bool> deleteKeyMove(String characterName, String string) async {
    final db = await database;
    var res = await db.delete(
      'key_moves',
      where: 'characterName = ? AND inputs = ?',
      whereArgs: [characterName, string],
    );
    return res > 0;
  }

  Future<List<Map<String, dynamic>>> getAllMyCharacters() async {
    final db = await database;
    return await db.query('my_characters', orderBy: 'createdAt DESC');
  }

  /// Supprime un personnage de la table my_characters par son id.
  Future<bool> deleteMyCharacter(int id) async {
    final db = await database;
    final res = await db.delete(
      'my_characters',
      where: 'id = ?',
      whereArgs: [id],
    );
    return res > 0;
  }

  Future<void> deleteAllCharacterData(String characterName) async {
    final db = await database;
    await db.execute('DELETE FROM my_characters WHERE name = ?', [characterName]);
    await db.execute('DELETE FROM key_moves WHERE characterName = ?', [characterName]);
  }

  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }

  /// Ferme la base si ouverte puis supprime le fichier de base de données.
  /// Utile pour forcer la recréation complète (onCreate) lors du prochain initDb().
  Future<void> deleteDatabaseFile() async {
    // Assure la fermeture de la connexion en mémoire
    if (_db != null) {
      await _db!.close();
      _db = null;
    }

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'tekken_cheat_sheet.db');
    final file = File(path);
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // ignore / log si besoin
    }
  }
}