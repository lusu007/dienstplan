class ScheduleKeyParts {
  final String dateYmd;
  final String configName;
  final String dutyGroupId;
  final String dutyTypeId;
  final String service;

  const ScheduleKeyParts({
    required this.dateYmd,
    required this.configName,
    required this.dutyGroupId,
    required this.dutyTypeId,
    required this.service,
  });
}

class ScheduleKeyHelper {
  static const String _separator = '_';
  
  // Cache for date formatting to avoid repeated conversions
  static final Map<String, String> _dateFormatCache = <String, String>{};
  static const int _maxCacheSize = 1000; // Limit cache size to prevent memory issues

  static String formatDateYmd(DateTime date) {
    final DateTime utc = date.toUtc();
    // Create a cache key from date components
    final String cacheKey = '${utc.year}-${utc.month}-${utc.day}';
    
    // Check cache first
    final String? cached = _dateFormatCache[cacheKey];
    if (cached != null) {
      return cached;
    }
    
    // Format the date
    final String y = utc.year.toString().padLeft(4, '0');
    final String m = utc.month.toString().padLeft(2, '0');
    final String d = utc.day.toString().padLeft(2, '0');
    final String formatted = '$y-$m-$d';
    
    // Add to cache if not too large
    if (_dateFormatCache.length < _maxCacheSize) {
      _dateFormatCache[cacheKey] = formatted;
    } else {
      // Clear cache when it gets too large (simple eviction strategy)
      _dateFormatCache.clear();
      _dateFormatCache[cacheKey] = formatted;
    }
    
    return formatted;
  }
  
  /// Clears the date format cache (useful for testing or memory management)
  static void clearCache() {
    _dateFormatCache.clear();
  }

  static String buildScheduleId({
    required DateTime date,
    required String configName,
    required String dutyGroupId,
    required String dutyTypeId,
    required String service,
  }) {
    final String ymd = formatDateYmd(date);
    return [ymd, configName, dutyGroupId, dutyTypeId, service].join(_separator);
  }

  static ScheduleKeyParts parseScheduleId(String id) {
    final List<String> parts = id.split(_separator);
    if (parts.length < 5) {
      throw ArgumentError('Invalid schedule id format: $id');
    }
    return ScheduleKeyParts(
      dateYmd: parts[0],
      configName: parts[1],
      dutyGroupId: parts[2],
      dutyTypeId: parts[3],
      service: parts.sublist(4).join(_separator),
    );
  }
}
