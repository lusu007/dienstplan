class Rhythm {
  final int lengthWeeks;
  final List<List<String>> pattern;

  Rhythm({required this.lengthWeeks, required this.pattern});

  Map<String, dynamic> toMap() {
    return {'length_weeks': lengthWeeks, 'pattern': pattern};
  }

  factory Rhythm.fromMap(Map<String, dynamic> map) {
    return Rhythm(
      lengthWeeks: map['length_weeks'] as int,
      pattern: (map['pattern'] as List<dynamic>)
          .map(
            (week) =>
                (week as List<dynamic>).map((day) => day as String).toList(),
          )
          .toList(),
    );
  }

  @override
  String toString() {
    return 'Rhythm(lengthWeeks: $lengthWeeks, pattern: $pattern)';
  }
}
