import '../services/db_provider.dart';
import '../models/character_model.dart';

class CharacterRepository {
  final _db = DBProvider.instance;

  Future<int> addCharacter(Character c) => _db.insertMyCharacter(c.name);

  Future<List<Character>> fetchAllCharacters() async {
    final rows = await _db.getAllMyCharacters();
    return rows.map((r) => Character.fromMap(r)).toList();
  }

}

