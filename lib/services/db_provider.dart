import 'dart:async';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import '../constants/helper.dart';

/// DBProvider is a singleton access layer to the SQLite database.
/// Use DBProvider.instance for all DB operations.
class DBProvider {
  DBProvider._();

  static final DBProvider instance = DBProvider._();

  /// Cached Database instance.
  Database? _db;

  /// Get or open the database connection.
  /// @return Future<Database> opened database handle
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  /// Force initialization of DB (open connection).
  /// @return Future<Database>
  Future<Database> initDb() async {
    _db = await _initDB();
    return _db!;
  }

  /// Internal initializer for the DB file and platform-specific setup.
  /// @return Future<Database>
  Future<Database> _initDB() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'tekken_cheat_sheet.db');

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
    );
  }

  /// Create DB schema on first run.
  /// @param db Database handle
  /// @param version schema version
  FutureOr<void> _onCreate(Database db, int version) async {
    // create my_characters table
    await db.execute('''
      CREATE TABLE my_characters(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        createdAt INTEGER
      )
    ''');
    // key_moves includes optional metadata columns
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

  /// Delete DB file from device (used for testing / reset).
  /// @param characterName name of character to remove (not used)
  /// @return Future<void>
  Future<void> deleteDatabaseFile() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'tekken_cheat_sheet.db');
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Insert a character row if needed.
  /// @param name character name
  /// @return Future<int> inserted row id
  Future<int> insertMyCharacter(String name) async {
    final db = await database;
    Map<String, dynamic> character = {
      'name': name,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };
    return await db.insert(
      'my_characters',
      character,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Return all saved characters ordered by creation.
  /// @return Future<List<Map<String,dynamic>>> list of rows
  Future<List<Map<String, dynamic>>> getAllMyCharacters() async {
    final db = await database;
    return await db.query('my_characters', orderBy: 'createdAt DESC');
  }

  /// Delete all data related to a character (characters, moves, combos, launchers).
  /// @param characterName
  /// @return Future<void>
  Future<void> deleteAllCharacterData(String characterName) async {
    final db = await database;
    await db.execute('DELETE FROM my_characters WHERE name = ?', [
      characterName,
    ]);
    await db.execute('DELETE FROM key_moves WHERE characterName = ?', [
      characterName,
    ]);
    await db.execute('DELETE FROM punishes WHERE characterName = ?', [
      characterName,
    ]);
    await db.execute('DELETE FROM launchers WHERE characterName = ?', [
      characterName,
    ]);
    await db.execute('DELETE FROM combos WHERE characterName = ?', [
      characterName,
    ]);
    await db.execute('DELETE FROM stance_moves WHERE characterName = ?', [
      characterName,
    ]);
  }

  /// Close DB connection.
  /// @return Future<void>
  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }

  /// Insert a key move with optional metadata; prevents duplicates.
  /// @param characterName
  /// @param input slash-separated inputs
  /// @param frames optional frames
  /// @param onHit optional onHit
  /// @param onBlock optional onBlock
  /// @param remark optional remark
  /// @return Future<int> row id or -1 if duplicate
  Future<int> insertKeyMove(
    String characterName,
    String input, {
    int? frames,
    int? onHit,
    int? onBlock,
    String? remark,
  }) async {
    final db = await database;
    // ensure character exists to keep referential consistency for later queries
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
    // Prevent duplicates based on character + inputs
    final List<Map<String, dynamic>> existingMove = await db.query(
      'key_moves',
      where: 'characterName = ? AND inputs = ?',
      whereArgs: [characterName, input],
    );
    if (existingMove.isNotEmpty) {
      return -1;
    } else {
      return await db.insert(
        'key_moves',
        move,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  /// Fetch key moves for a character.
  /// @param characterName
  /// @return Future<List<Map<String,dynamic>>> each map contains inputs/frames/onHit/onBlock/remark
  Future<List<Map<String, dynamic>>> getKeyMovesForCharacter(
    String characterName,
  ) async {
    final db = await database;
    final res = await db.query(
      'key_moves',
      where: 'characterName = ?',
      whereArgs: [characterName],
      orderBy: 'createdAt ASC',
    );
    return res
        .map(
          (row) => {
            'inputs': row['inputs'],
            'frames': row['frames'],
            'onHit': row['onHit'],
            'onBlock': row['onBlock'],
            'remark': row['remark'],
          },
        )
        .toList();
  }

  /// Delete a key move row.
  /// @param characterName
  /// @param string inputs string
  /// @return Future<bool> true if deleted
  Future<bool> deleteKeyMove(String characterName, String string) async {
    final db = await database;
    var res = await db.delete(
      'key_moves',
      where: 'characterName = ? AND inputs = ?',
      whereArgs: [characterName, string],
    );
    return res > 0;
  }

  /// Insert or update a punish (unique by character + frames).
  /// @param characterName
  /// @param input inputs string
  /// @param frames frames value
  /// @return Future<void>
  Future<void> insertPunish(
    String characterName,
    String input,
    int frames,
  ) async {
    final db = await database;
    List<Map<String, dynamic>> existingChars = await getAllMyCharacters();
    if (!existingChars.any((c) => c['name'] == characterName)) {
      await insertMyCharacter(characterName);
    }
    Map<String, dynamic> punish = {
      'characterName': characterName,
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
    } else {
      await db.insert(
        'punishes',
        punish,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  /// Get punish rows for a character sorted by frames.
  /// @param characterName
  /// @return Future<List<Map<String,dynamic>>> each map contains inputs and frames
  Future<List<Map<String, dynamic>>> getPunishesForCharacter(
    String characterName,
  ) async {
    final db = await database;
    final res = await db.query(
      'punishes',
      where: 'characterName = ?',
      whereArgs: [characterName],
      orderBy: 'frames DESC',
    );
    List<Map<String, dynamic>> formattedRes = res
        .map((row) => {'inputs': row['inputs'], 'frames': row['frames']})
        .toList();
    formattedRes.sort(
      (a, b) => (a['frames'] as int).compareTo(b['frames'] as int),
    );
    return formattedRes;
  }

  /// Delete a punish row.
  /// @param characterName
  /// @param string inputs string
  /// @param frames frames value
  /// @return Future<bool>
  Future<bool> deletePunish(
    String characterName,
    String string,
    int frames,
  ) async {
    final db = await database;
    var res = await db.delete(
      'punishes',
      where: 'characterName = ? AND inputs = ? AND frames = ?',
      whereArgs: [characterName, string, frames],
    );
    return res > 0;
  }

  /// Insert a combo row.
  /// @param characterName
  /// @param input inputs string
  /// @return Future<int> inserted row id
  Future<int> insertCombo(String characterName, String input) async {
    final db = await database;
    List<Map<String, dynamic>> existingChars = await getAllMyCharacters();
    if (!existingChars.any((c) => c['name'] == characterName)) {
      await insertMyCharacter(characterName);
    }
    Map<String, dynamic> combo = {
      'characterName': characterName,
      'inputs': input,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };
    return await db.insert(
      'combos',
      combo,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Insert a launcher tied to a combo (foreign key comboId).
  /// @param characterName
  /// @param input inputs string
  /// @param comboId parent combo id
  /// @return Future<int> inserted row id
  Future<int> insertLauncher(
    String characterName,
    String input,
    int comboId,
  ) async {
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
    return await db.insert(
      'launchers',
      launcher,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get a combo with its launchers.
  /// @param characterName
  /// @param comboId
  /// @return Future<Map<String,dynamic>?> combo data with 'launchers' list
  Future<Map<String, dynamic>?> getComboWithLaunchers(
    String characterName,
    int comboId,
  ) async {
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
    combo['launchers'] = launchersRes
        .map((l) => {'id': l['id'], 'inputs': l['inputs']})
        .toList();
    return combo;
  }

  /// Get all combos for a character together with their launchers.
  /// @param characterName
  /// @return Future<List<Map<String,dynamic>>> each entry contains id, inputs, launchers
  Future<List<Map<String, dynamic>>> getCombosForCharacter(
    String characterName,
  ) async {
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
        'launchers': launchersRes
            .map((l) => {'id': l['id'], 'inputs': l['inputs']})
            .toList(),
      });
    }
    return formattedRes;
  }

  /// Delete a combo row (launchers cascade if FK enforced).
  /// @param characterName
  /// @param inputs string
  /// @return Future<bool>
  Future<bool> deleteCombo(String characterName, String inputs) async {
    final db = await database;
    final res = await db.delete(
      'combos',
      where: 'characterName = ? AND inputs = ?',
      whereArgs: [characterName, inputs],
    );
    return res > 0;
  }

  /// Delete a launcher by id for a character.
  /// @param characterName
  /// @param launcherId
  /// @return Future<bool>
  Future<bool> deleteLauncher(String characterName, int launcherId) async {
    final db = await database;
    final res = await db.delete(
      'launchers',
      where: 'id = ? AND characterName = ?',
      whereArgs: [launcherId, characterName],
    );
    return res > 0;
  }

  /// Insert a stance move with stance metadata.
  /// @param characterName
  /// @param input inputs string
  /// @param stance stance name
  /// @param remark optional remark
  /// @param frames optional frames
  /// @param onHit optional onHit
  /// @param onBlock optional onBlock
  /// @return Future<int> row id or -1 if duplicate
  Future<int> insertStanceMove(
    String characterName,
    String input,
    String stance, {
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
      return -1;
    } else {
      return await db.insert(
        'stance_moves',
        move,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  /// Get stance moves for a character.
  /// @param characterName
  /// @return Future<List<Map<String,dynamic>>> each map contains inputs, stance and optional metadata
  Future<List<Map<String, dynamic>>> getStanceMovesForCharacter(
    String characterName,
  ) async {
    final db = await database;
    final res = await db.query(
      'stance_moves',
      where: 'characterName = ?',
      whereArgs: [characterName],
      orderBy: 'createdAt ASC',
    );
    return res
        .map(
          (row) => {
            'inputs': row['inputs'],
            'stance': row['stance'],
            'frames': row['frames'],
            'onHit': row['onHit'],
            'onBlock': row['onBlock'],
            'remark': row['remark'],
          },
        )
        .toList();
  }

  /// Delete a stance move by inputs + stance.
  /// @param characterName
  /// @param string inputs string
  /// @param stance stance name
  /// @return Future<bool>
  Future<bool> deleteStanceMove(
    String characterName,
    String string,
    String stance,
  ) async {
    final db = await database;
    var res = await db.delete(
      'stance_moves',
      where: 'characterName = ? AND inputs = ? AND stance = ?',
      whereArgs: [characterName, string, stance],
    );
    return res > 0;
  }

  /// Parse JSON and import all tables (delegates to importAllTablesFromMap).
  /// @param jsonString JSON string matching export format
  /// @param clearFirst whether to clear DB tables before inserting
  Future<void> importAllTablesFromJson(
    String jsonString, {
    bool clearFirst = true,
  }) async {
    final Map<String, dynamic> data =
        jsonDecode(jsonString) as Map<String, dynamic>;
    await importAllTablesFromMap(data, clearFirst: clearFirst);
  }

  /// Import data from a Map into DB within a transaction.
  /// @param all map keyed by table name pointing to list of rows
  /// @param clearFirst whether to clear tables before inserting
  Future<void> importAllTablesFromMap(
    Map<String, dynamic> all, {
    bool clearFirst = true,
  }) async {
    final db = await database;

    await db.transaction((txn) async {
      if (clearFirst) {
        await txn.delete('launchers');
        await txn.delete('combos');
        await txn.delete('key_moves');
        await txn.delete('punishes');
        await txn.delete('my_characters');
        await txn.delete('stance_moves');
      }

      Future<void> insertList(String table, dynamic listObj) async {
        if (listObj == null) return;
        if (listObj is! List) return;
        for (var raw in listObj) {
          if (raw is Map) {
            final Map<String, dynamic> row = Map<String, dynamic>.from(raw);
            // conflictAlgorithm.replace lets us insert rows with explicit ids safely
            await txn.insert(
              table,
              row,
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }
      }

      await insertList('my_characters', all['my_characters']);
      await insertList('combos', all['combos']);
      await insertList('key_moves', all['key_moves']);
      await insertList('punishes', all['punishes']);
      await insertList('launchers', all['launchers']);
      await insertList('stance_moves', all['stance_moves']);

      // update sqlite_sequence to keep AUTOINCREMENT values coherent with inserted ids
      for (final table in [
        'my_characters',
        'key_moves',
        'punishes',
        'combos',
        'launchers',
        'stance_moves',
      ]) {
        final maxRes = await txn.rawQuery(
          'SELECT MAX(id) as maxId FROM $table',
        );
        final maxId = (maxRes.isNotEmpty && maxRes.first['maxId'] != null)
            ? (maxRes.first['maxId'] as int)
            : 0;
        await txn.rawUpdate(
          'UPDATE sqlite_sequence SET seq = ? WHERE name = ?',
          [maxId, table],
        );
      }
    });
  }

  /// Import the embedded default DB stored in Helper().defaultDB.
  /// @param clearFirst whether to clear tables before inserting
  Future<void> importDefaultDB({bool clearFirst = true}) async {
    final helper = Helper();
    final dynamic raw = helper.defaultDB;
    if (raw == null || raw is! Map<String, dynamic>) {
      if (raw is Map) {
        await importAllTablesFromMap(
          Map<String, dynamic>.from(raw),
          clearFirst: clearFirst,
        );
      }
      return;
    }
    await importAllTablesFromMap(raw, clearFirst: clearFirst);
  }

  /// Export all tables into a Map.
  /// @return Future<Map<String,dynamic>> map ready to be json-encoded and re-imported
  Future<Map<String, dynamic>> exportAllTablesAsMap() async {
    final db = await database;
    final Map<String, dynamic> res = {};

    final myChars = await db.query('my_characters', orderBy: 'id ASC');
    final keyMoves = await db.query('key_moves', orderBy: 'id ASC');
    final punishes = await db.query('punishes', orderBy: 'id ASC');
    final combos = await db.query('combos', orderBy: 'id ASC');
    final launchers = await db.query('launchers', orderBy: 'id ASC');
    final stanceMoves = await db.query('stance_moves', orderBy: 'id ASC');

    res['my_characters'] = myChars.map((r) {
      return {'id': r['id'], 'name': r['name'], 'createdAt': r['createdAt']};
    }).toList();

    res['key_moves'] = keyMoves.map((r) {
      return {
        'id': r['id'],
        'characterName': r['characterName'],
        'inputs': r['inputs'],
        'frames': r['frames'],
        'onHit': r['onHit'],
        'onBlock': r['onBlock'],
        'remark': r['remark'],
        'createdAt': r['createdAt'],
      };
    }).toList();

    res['punishes'] = punishes.map((r) {
      return {
        'id': r['id'],
        'characterName': r['characterName'],
        'inputs': r['inputs'],
        'frames': r['frames'],
        'createdAt': r['createdAt'],
      };
    }).toList();

    res['combos'] = combos.map((r) {
      return {
        'id': r['id'],
        'characterName': r['characterName'],
        'inputs': r['inputs'],
        'createdAt': r['createdAt'],
      };
    }).toList();

    res['launchers'] = launchers.map((r) {
      return {
        'id': r['id'],
        'characterName': r['characterName'],
        'inputs': r['inputs'],
        'comboId': r['comboId'],
        'createdAt': r['createdAt'],
      };
    }).toList();

    // Helper.defaultDB uses "stanceName" key; map DB column 'stance' to that name
    res['stance_moves'] = stanceMoves.map((r) {
      return {
        'id': r['id'],
        'characterName': r['characterName'],
        'stance': r['stance'],
        'inputs': r['inputs'],
        'createdAt': r['createdAt'],
      };
    }).toList();

    return res;
  }

  /// Export all tables as a pretty JSON string ready to be copy/pasted.
  /// @return Future<String> pretty-printed JSON
  Future<String> exportAllTablesAsJsonString() async {
    final map = await exportAllTablesAsMap();
    return const JsonEncoder.withIndent('  ').convert(map);
  }
}
