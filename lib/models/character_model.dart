/// Represents a saved character row in my_characters table.
class Character {
  /// Character unique display name (used as key in this app).
  final String name;

  /// Optional path to portrait image.
  final String? imagePath;

  /// Optional user notes.
  final String? notes;

  /// Creation timestamp.
  final DateTime createdAt;

  Character({
    required this.name,
    this.imagePath,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert to Map for DB insertion.
  /// @return Map<String,dynamic>
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imagePath': imagePath,
      'notes': notes,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  /// Factory to build a Character from a DB map.
  /// @param map DB row map
  /// @return Character
  factory Character.fromMap(Map<String, dynamic> map) {
    return Character(
      name: map['name'] as String? ?? '',
      imagePath: map['imagePath'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['createdAt'] as int? ?? 0,
      ),
    );
  }

  /// Return a copy with optional field overrides.
  /// @return Character
  Character copyWith({
    int? id,
    String? name,
    String? imagePath,
    String? notes,
    DateTime? createdAt,
  }) {
    return Character(
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
