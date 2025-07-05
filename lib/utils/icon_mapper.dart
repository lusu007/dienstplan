import 'package:flutter/material.dart';

class IconMapper {
  static final Map<String, IconData> _iconMap = {
    // Police and security related icons
    'shield': Icons.shield,
    'security': Icons.security,
    'police': Icons.local_police,
    'badge': Icons.badge,

    // Vehicle related icons
    'car': Icons.directions_car,
    'directions_car': Icons.directions_car,
    'vehicle': Icons.directions_car,
    'motorcycle': Icons.motorcycle,
    'bike': Icons.pedal_bike,

    // Emergency and medical icons
    'emergency': Icons.emergency,
    'medical': Icons.medical_services,
    'ambulance': Icons.medical_services,
    'fire': Icons.local_fire_department,

    // Communication icons
    'phone': Icons.phone,
    'radio': Icons.radio,
    'message': Icons.message,

    // Time and schedule icons
    'schedule': Icons.schedule,
    'time': Icons.access_time,
    'calendar': Icons.calendar_today,
    'clock': Icons.access_time,

    // Location and navigation icons
    'location': Icons.location_on,
    'map': Icons.map,
    'navigation': Icons.navigation,
    'gps': Icons.gps_fixed,

    // General icons
    'star': Icons.star,
    'favorite': Icons.favorite,
    'check': Icons.check_circle,
    'warning': Icons.warning,
    'info': Icons.info,
    'settings': Icons.settings,
    'group': Icons.group,
    'person': Icons.person,
    'people': Icons.people,
    'team': Icons.groups,

    // Direction and movement icons
    'directions': Icons.directions,
    'route': Icons.route,
    'traffic': Icons.traffic,

    // Equipment and tools icons
    'tool': Icons.build,
    'equipment': Icons.build,
    'gear': Icons.settings,
    'device': Icons.devices,

    // Weather and environment icons
    'weather': Icons.wb_sunny,
    'sun': Icons.wb_sunny,
    'rain': Icons.grain,
    'storm': Icons.thunderstorm,

    // Activity and action icons
    'patrol': Icons.directions_walk,
    'walk': Icons.directions_walk,
    'run': Icons.directions_run,
    'exercise': Icons.fitness_center,
  };

  /// Maps an icon name string to a Flutter IconData
  /// Returns a default icon if the name is not found
  static IconData getIcon(String? iconName,
      {IconData defaultIcon = Icons.schedule}) {
    if (iconName == null || iconName.isEmpty) {
      return defaultIcon;
    }

    // Try exact match first
    final icon = _iconMap[iconName.toLowerCase()];
    if (icon != null) {
      return icon;
    }

    // Try partial match for common variations
    for (final entry in _iconMap.entries) {
      if (iconName.toLowerCase().contains(entry.key) ||
          entry.key.contains(iconName.toLowerCase())) {
        return entry.value;
      }
    }

    // Return default if no match found
    return defaultIcon;
  }

  /// Returns a list of all available icon names
  static List<String> getAvailableIcons() {
    return _iconMap.keys.toList();
  }

  /// Checks if an icon name is valid
  static bool isValidIcon(String iconName) {
    return _iconMap.containsKey(iconName.toLowerCase());
  }
}
