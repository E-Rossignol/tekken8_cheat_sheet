import 'dart:async';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert'; // ajouté pour sérialisation JSON
import '../constants/helper.dart'; // ajouté pour utiliser defaultDB

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
      onConfigure: (db) async {
        // Activer les contraintes de clé étrangère pour respecter les relations
        await db.execute('PRAGMA foreign_keys = ON');
      },
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
    await db.execute('''
      CREATE TABLE combos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        characterName TEXT NOT NULL,
        inputs TEXT NOT NULL,
        createdAt INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE launchers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        characterName TEXT NOT NULL,
        inputs TEXT NOT NULL,
        comboId INTEGER NOT NULL,
        createdAt INTEGER,
        FOREIGN KEY (comboId) REFERENCES combos(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE stance_moves(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        characterName TEXT NOT NULL,
        inputs TEXT NOT NULL,
        stance TEXT NOT NULL,
        frames INTEGER,
        onHit INTEGER,
        onBlock INTEGER,
        remark TEXT,
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

  Future<void> deleteAllCharacterData(String characterName) async {
    final db = await database;
    await db.execute('DELETE FROM my_characters WHERE name = ?', [characterName]);
    await db.execute('DELETE FROM key_moves WHERE characterName = ?', [characterName]);
    await db.execute('DELETE FROM punishes WHERE characterName = ?', [characterName]);
    await db.execute('DELETE FROM launchers WHERE characterName = ?', [characterName]);
    await db.execute('DELETE FROM combos WHERE characterName = ?', [characterName]);
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
    formattedRes.sort((a, b) => (a['frames'] as int).compareTo(b['frames'] as int));
    return formattedRes;
  }

  Future<bool> deletePunish(String characterName, String string, int frames) async {
    final db = await database;
    var res = await db.delete(
      'punishes',
      where: 'characterName = ? AND inputs = ? AND frames = ?',
      whereArgs: [characterName, string, frames],
    );
    return res > 0;
  }


  Future<int> insertCombo(String characterName, String input) async {
    final db = await database;
    List<Map<String, dynamic>> existingChars = await getAllMyCharacters();
    if (!existingChars.any((c) => c['name'] == characterName)) {
      await insertMyCharacter(characterName);
    }
    Map<String, dynamic> combo = {
      'characterName': characterName ,
      'inputs': input,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };
    return await db.insert('combos', combo, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> insertLauncher(String characterName, String input, int comboId) async {
    final db = await database;
    List<Map<String, dynamic>> existingChars = await getAllMyCharacters();
    if (!existingChars.any((c) => c['name'] == characterName)) {
      await insertMyCharacter(characterName);
    }
    Map<String, dynamic> launcher = {
      'characterName': characterName,
      'inputs': input,
      'comboId': comboId,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };
    return await db.insert('launchers', launcher, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getComboWithLaunchers(String characterName, int comboId) async {
    final db = await database;
    final comboRes = await db.query(
      'combos',
      where: 'characterName = ? AND id = ?',
      whereArgs: [characterName, comboId],
    );
    if (comboRes.isEmpty) return null;

    final combo = Map<String, dynamic>.from(comboRes.first);
    final launchersRes = await db.query(
      'launchers',
      where: 'comboId = ?',
      whereArgs: [comboId],
      orderBy: 'createdAt ASC',
    );
    combo['launchers'] = launchersRes.map((l) => {
      'id': l['id'],
      'inputs': l['inputs'],
    }).toList();
    return combo;
  }

  Future<List<Map<String, dynamic>>> getCombosForCharacter(String characterName) async {
    final db = await database;
    final res = await db.query(
      'combos',
      where: 'characterName = ?',
      whereArgs: [characterName],
      orderBy: 'createdAt ASC',
    );
    List<Map<String, dynamic>> formattedRes = [];
    for (var row in res) {
      final int comboId = row['id'] as int;
      final launchersRes = await db.query(
        'launchers',
        where: 'comboId = ?',
        whereArgs: [comboId],
        orderBy: 'createdAt ASC',
      );
      formattedRes.add({
        'id': comboId,
        'inputs': row['inputs'],
        'launchers': launchersRes.map((l) => {
          'id': l['id'],
          'inputs': l['inputs'],
        }).toList(),
      });
    }
    return formattedRes;
  }

  Future<bool> deleteCombo(String characterName, String inputs) async {
    final db = await database;
    final res = await db.delete(
      'combos',
      where: 'characterName = ? AND inputs = ?',
      whereArgs: [characterName, inputs],
    );
    // foreign key ON DELETE CASCADE supprimera les launchers liés
    return res > 0;
  }

  Future<bool> deleteLauncher(String characterName, int launcherId) async {
    final db = await database;
    final res = await db.delete(
      'launchers',
      where: 'id = ? AND characterName = ?',
      whereArgs: [launcherId, characterName],
    );
    return res > 0;
  }

  // modifié : accepte champs optionnels et retourne id inséré
  Future<int> insertStanceMove(
      String characterName,
      String input,
      String stance,{
        String? remark,
        int? frames,
        int? onHit,
        int? onBlock,
      }) async {
    final db = await database;
    List<Map<String, dynamic>> existingChars = await getAllMyCharacters();
    if (!existingChars.any((c) => c['name'] == characterName)) {
      await insertMyCharacter(characterName);
    }
    Map<String, dynamic> move = {
      'characterName': characterName,
      'inputs': input,
      'stance': stance,
      'frames': frames,
      'onHit': onHit,
      'onBlock': onBlock,
      'remark': remark,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };
    final List<Map<String, dynamic>> existingMove = await db.query(
      'stance_moves',
      where: 'characterName = ? AND inputs = ? AND stance = ?',
      whereArgs: [characterName, input, stance],
    );
    if (existingMove.isNotEmpty) {
      return -1; // Indique que le move existe déjà, pas d'insertion
    }
    else {
      return await db.insert('stance_moves', move, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  // modifié : retourne les colonnes utiles (inputs + métadonnées)
  Future<List<Map<String, dynamic>>> getStanceMovesForCharacter(String characterName) async {
    final db = await database;
    final res = await db.query(
      'stance_moves',
      where: 'characterName = ?',
      whereArgs: [characterName],
      orderBy: 'createdAt ASC',
    );
    // renvoyer maps structurés pour faciliter le parsing côté UI
    return res.map((row) => {
      'inputs': row['inputs'],
      'stance': row['stance'],
      'frames': row['frames'],
      'onHit': row['onHit'],
      'onBlock': row['onBlock'],
      'remark': row['remark'],
    }).toList();
  }

  Future<bool> deleteStanceMove(String characterName, String string, String stance) async {
    final db = await database;
    var res = await db.delete(
      'stance_moves',
      where: 'characterName = ? AND inputs = ? AND stance = ?',
      whereArgs: [characterName, string, stance],
    );
    return res > 0;
  }

  // --- Début des nouvelles méthodes pour réinsérer toutes les données depuis un JSON / Map ---

  /// Parse un JSON (format produit par exportAllTablesToConsole) et l'insère en base.
  /// Si clearFirst=true, vide d'abord les tables (ordre respectant les contraintes FK).
  Future<void> importAllTablesFromJson(String jsonString, {bool clearFirst = true}) async {
    final Map<String, dynamic> data = jsonDecode(jsonString) as Map<String, dynamic>;
    await importAllTablesFromMap(data, clearFirst: clearFirst);
  }

  /// Insère en base le contenu de la Map contenant les listes pour chaque table.
  /// La Map attend les clés : my_characters, key_moves, punishes, combos, launchers
  Future<void> importAllTablesFromMap(Map<String, dynamic> all, {bool clearFirst = true}) async {
    final db = await database;

    await db.transaction((txn) async {
      // Vider les tables dans l'ordre sécurisé (launchers -> combos -> key_moves -> punishes -> my_characters)
      if (clearFirst) {
        try {
          await txn.delete('launchers');
          await txn.delete('combos');
          await txn.delete('key_moves');
          await txn.delete('punishes');
          await txn.delete('my_characters');
        } catch (e) {
          // Ignore / log si besoin
          print('Warning while clearing tables: $e');
        }
      }

      // Helper pour insérer une liste d'items (si absente, saute)
      Future<void> insertList(String table, dynamic listObj) async {
        if (listObj == null) return;
        if (listObj is! List) return;
        for (var raw in listObj) {
          if (raw is Map) {
            final Map<String, dynamic> row = Map<String, dynamic>.from(raw);
            try {
              await txn.insert(table, row, conflictAlgorithm: ConflictAlgorithm.replace);
            } catch (e) {
              print('Error inserting into $table: $e');
            }
          }
        }
      }

      // Insérer dans l'ordre : my_characters, combos, key_moves, punishes, launchers
      await insertList('my_characters', all['my_characters']);
      await insertList('combos', all['combos']);
      await insertList('key_moves', all['key_moves']);
      await insertList('punishes', all['punishes']);
      await insertList('launchers', all['launchers']);

      // Tenter de mettre à jour sqlite_sequence pour conserver des autoincrement cohérents
      try {
        for (final table in ['my_characters', 'key_moves', 'punishes', 'combos', 'launchers']) {
          final maxRes = await txn.rawQuery('SELECT MAX(id) as maxId FROM $table');
          final maxId = (maxRes.isNotEmpty && maxRes.first['maxId'] != null) ? (maxRes.first['maxId'] as int) : 0;
          // sqlite_sequence n'existe pas forcément (par ex. si DB vide dans certains contextes)
          await txn.rawUpdate('UPDATE sqlite_sequence SET seq = ? WHERE name = ?', [maxId, table]);
        }
      } catch (e) {
        // Pas critique : si sqlite_sequence absent ou requête échoue, on ignore
        // utile à debug :
        // print('Could not update sqlite_sequence: $e');
      }
    });
  }

  /// Insère en base le dump présent dans Helper().defaultDB.
  /// Appeler DBProvider.instance.importDefaultDB() sans argument.
  Future<void> importDefaultDB({bool clearFirst = true}) async {
    final helper = Helper();
    final dynamic raw = helper.defaultDB;
    if (raw == null || raw is! Map<String, dynamic>) {
      // tente de normaliser si c'est Map<dynamic,dynamic>
      if (raw is Map) {
        await importAllTablesFromMap(Map<String, dynamic>.from(raw), clearFirst: clearFirst);
      } else {
        print('importDefaultDB: defaultDB vide ou malformé');
      }
      return;
    }
    await importAllTablesFromMap(raw, clearFirst: clearFirst);
  }

  // --- Fin des nouvelles méthodes ---

}