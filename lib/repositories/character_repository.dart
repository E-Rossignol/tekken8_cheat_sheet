import '../services/db_provider.dart';
import '../models/character_model.dart';

class CharacterRepository {
  final _db = DBProvider.instance;

  Future<int> addCharacter(Character c) => _db.insertCharacter(c.toMap());

  Future<List<Character>> fetchAllCharacters() async {
    final rows = await _db.getAllCharacters();
    return rows.map((r) => Character.fromMap(r)).toList();
  }

  Future<int> updateCharacter(Character c) async {
    return _db.updateCharacter(c.toMap());
  }

  Future<int> deleteCharacter(int id) async {
    return _db.deleteCharacter(id);
  }
}

