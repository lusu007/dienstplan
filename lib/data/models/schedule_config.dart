class ScheduleConfig {
  final Meta meta;
  final List<Service> services;
  final String version;

  ScheduleConfig({
    required this.meta,
    required this.services,
    required this.version,
  });

  factory ScheduleConfig.fromJson(Map<String, dynamic> json) {
    return ScheduleConfig(
      meta: Meta.fromJson(json['meta'] as Map<String, dynamic>),
      services: (json['services'] as List)
          .map((service) => Service.fromJson(service as Map<String, dynamic>))
          .toList(),
      version: json['version'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meta': meta.toJson(),
      'services': services.map((service) => service.toJson()).toList(),
      'version': version,
    };
  }
}

class Meta {
  final String name;
  final String description;

  Meta({required this.name, required this.description});

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'description': description};
  }
}

class Service {
  final String name;
  final List<String> persons;

  Service({required this.name, required this.persons});

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      name: json['name'] as String,
      persons: (json['persons'] as List)
          .map((person) => person as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'persons': persons};
  }
}
