class DutyGroup {
  final String id;
  final String name;
  final String rhythm;
  final int offsetWeeks;

  DutyGroup({
    required this.id,
    required this.name,
    required this.rhythm,
    required this.offsetWeeks,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'rhythm': rhythm,
      'offset_weeks': offsetWeeks,
    };
  }

  factory DutyGroup.fromMap(Map<String, dynamic> map) {
    return DutyGroup(
      id: map['id'] as String,
      name: map['name'] as String,
      rhythm: map['rhythm'] as String,
      offsetWeeks: map['offset_weeks'] as int,
    );
  }

  @override
  String toString() {
    return 'DutyGroup(id: $id, name: $name, rhythm: $rhythm, offsetWeeks: $offsetWeeks)';
  }
}
