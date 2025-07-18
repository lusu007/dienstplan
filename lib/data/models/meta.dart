class Meta {
  final String name;
  final String createdBy;
  final String description;
  final String startWeekDay;
  final String startDate;
  final List<String> days;

  Meta({
    required this.name,
    required this.createdBy,
    required this.description,
    required this.startWeekDay,
    required this.startDate,
    required this.days,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'created_by': createdBy,
      'description': description,
      'start_week_day': startWeekDay,
      'start_date': startDate,
      'days': days,
    };
  }

  factory Meta.fromMap(Map<String, dynamic> map) {
    return Meta(
      name: map['name'] as String,
      createdBy: map['created_by'] as String,
      description: map['description'] as String,
      startWeekDay: map['start_week_day'] as String,
      startDate: map['start_date'] as String,
      days: (map['days'] as List<dynamic>).map((day) => day as String).toList(),
    );
  }

  @override
  String toString() {
    return 'Meta(name: $name, createdBy: $createdBy, description: $description, startWeekDay: $startWeekDay, startDate: $startDate, days: $days)';
  }
}
