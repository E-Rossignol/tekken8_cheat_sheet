class Character {
  final String name;
  final String? imagePath;
  final String? notes;
  final DateTime createdAt;

  Character({
    required this.name,
    this.imagePath,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imagePath': imagePath,
      'notes': notes,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Character.fromMap(Map<String, dynamic> map) {
    return Character(
      name: map['name'] as String? ?? '',
      imagePath: map['imagePath'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int? ?? 0),
    );
  }

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

