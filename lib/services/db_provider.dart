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
        frames INTEGER,
        onHit INTEGER,
        onBlock INTEGER,
        remark TEXT,
        createdAt INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE punishes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        characterName TEXT NOT NULL,
        inputs TEXT NOT NULL,
        frames INTEGER NOT NULL,
        createdAt INTEGER
      )
    ''');
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

  Future<int> insertMyCharacter(String name) async {
    final db = await database;
    Map<String, dynamic> character = {
      'name': name,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };
    return await db.insert('my_characters', character, conflictAlgorithm: ConflictAlgorithm.replace);
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

  // modifié : accepte champs optionnels et retourne id inséré
  Future<int> insertKeyMove(
    String characterName,
    String input, {
    int? frames,
    int? onHit,
    int? onBlock,
    String? remark,
  }) async {
    final db = await database;
    List<Map<String, dynamic>> existingChars = await getAllMyCharacters();
    if (!existingChars.any((c) => c['name'] == characterName)) {
      await insertMyCharacter(characterName);
    }
    Map<String, dynamic> move = {
      'characterName': characterName,
      'inputs': input,
      'frames': frames,
      'onHit': onHit,
      'onBlock': onBlock,
      'remark': remark,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };
    final List<Map<String, dynamic>> existingMove = await db.query(
      'key_moves',
      where: 'characterName = ? AND inputs = ?',
      whereArgs: [characterName, input],
    );
    if (existingMove.isNotEmpty) {
      return -1; // Indique que le move existe déjà, pas d'insertion
    }
    else {
      return await db.insert('key_moves', move, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  // modifié : retourne les colonnes utiles (inputs + métadonnées)
  Future<List<Map<String, dynamic>>> getKeyMovesForCharacter(String characterName) async {
    final db = await database;
    final res = await db.query(
      'key_moves',
      where: 'characterName = ?',
      whereArgs: [characterName],
      orderBy: 'createdAt ASC',
    );
    // renvoyer maps structurés pour faciliter le parsing côté UI
    return res.map((row) => {
      'inputs': row['inputs'],
      'frames': row['frames'],
      'onHit': row['onHit'],
      'onBlock': row['onBlock'],
      'remark': row['remark'],
    }).toList();
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

  Future<void> insertPunish(String characterName, String input, int frames) async {
    final db = await database;
    List<Map<String, dynamic>> existingChars = await getAllMyCharacters();
    if (!existingChars.any((c) => c['name'] == characterName)) {
      await insertMyCharacter(characterName);
    }
    Map<String, dynamic> punish = {
      'characterName': characterName ,
      'inputs': input,
      'frames': frames,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };
    final List<Map<String, dynamic>> existingPunishes = await db.query(
      'punishes',
      where: 'characterName = ? AND frames = ?',
      whereArgs: [characterName, frames],
    );
    if (existingPunishes.isNotEmpty) {
      await db.update(
        'punishes',
        punish,
        where: 'characterName = ? AND frames = ?',
        whereArgs: [characterName, frames],
      );
    }
    else {
      await db.insert('punishes', punish, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<List<Map<String, dynamic>>> getPunishesForCharacter(String characterName) async {
    final db = await database;
    final res = await db.query(
      'punishes',
      where: 'characterName = ?',
      whereArgs: [characterName],
      orderBy: 'frames DESC',
    );
    List<Map<String, dynamic>> formattedRes = res.map((row) => {
      'inputs': row['inputs'],
      'frames': row['frames'],
    }).toList();
    return formattedRes;
  }
}