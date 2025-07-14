import 'package:dienstplan/data/repositories/schedule_repository.dart';
import 'package:dienstplan/core/utils/logger.dart';

class GetDutyAbbreviationUseCase {
  final ScheduleRepository _scheduleRepository;

  // Caching strategy: In-memory cache for duty type abbreviations
  final Map<String, String> _abbreviationCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiration = Duration(hours: 1);

  GetDutyAbbreviationUseCase(this._scheduleRepository);

  Future<String> execute({
    required String dutyTypeId,
    required String configName,
  }) async {
    try {
      AppLogger.d(
          'GetDutyAbbreviationUseCase: Getting abbreviation for duty type: $dutyTypeId');

      // Check cache first
      final cacheKey = '${configName}_$dutyTypeId';
      if (_isCacheValid(cacheKey)) {
        final cachedAbbreviation = _abbreviationCache[cacheKey];
        if (cachedAbbreviation != null) {
          AppLogger.d(
              'GetDutyAbbreviationUseCase: Returning cached abbreviation: $cachedAbbreviation');
          return cachedAbbreviation;
        }
      }

      // Get duty types from repository
      final dutyTypes =
          await _scheduleRepository.getDutyTypes(configName: configName);

      // Find the duty type by index (assuming dutyTypeId is an index)
      final dutyTypeIndex = int.tryParse(dutyTypeId);
      if (dutyTypeIndex == null ||
          dutyTypeIndex < 0 ||
          dutyTypeIndex >= dutyTypes.length) {
        throw ArgumentError('Invalid duty type ID: $dutyTypeId');
      }

      final dutyType = dutyTypes[dutyTypeIndex];

      // Business logic: Generate abbreviation from label
      final abbreviation = _generateAbbreviation(dutyType.label);

      // Cache the result
      _abbreviationCache[cacheKey] = abbreviation;
      _cacheTimestamps[cacheKey] = DateTime.now();

      AppLogger.d(
          'GetDutyAbbreviationUseCase: Generated and cached abbreviation: $abbreviation');
      return abbreviation;
    } catch (e, stackTrace) {
      AppLogger.e('GetDutyAbbreviationUseCase: Error getting duty abbreviation',
          e, stackTrace);
      rethrow;
    }
  }

  String _generateAbbreviation(String label) {
    // Business logic: Generate abbreviation from duty type label
    // This is a simplified implementation - you may need more complex logic

    if (label.isEmpty) return '';

    // Remove common words and take first letters
    final words = label
        .split(' ')
        .where((word) => word.isNotEmpty)
        .where((word) => !_isCommonWord(word.toLowerCase()))
        .toList();

    if (words.isEmpty) {
      // If no meaningful words, take first 3 characters
      return label.length > 3
          ? label.substring(0, 3).toUpperCase()
          : label.toUpperCase();
    }

    // Take first letter of each word, max 3 letters
    final abbreviation = words
        .take(3)
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .join('');

    return abbreviation.isNotEmpty
        ? abbreviation
        : label.substring(0, 1).toUpperCase();
  }

  bool _isCommonWord(String word) {
    const commonWords = {
      'der',
      'die',
      'das',
      'und',
      'oder',
      'mit',
      'von',
      'zu',
      'für',
      'bei',
      'the',
      'and',
      'or',
      'with',
      'from',
      'to',
      'for',
      'at',
      'in',
      'on'
    };
    return commonWords.contains(word);
  }

  bool _isCacheValid(String cacheKey) {
    final timestamp = _cacheTimestamps[cacheKey];
    if (timestamp == null) return false;

    return DateTime.now().difference(timestamp) < _cacheExpiration;
  }

  void clearCache() {
    AppLogger.i('GetDutyAbbreviationUseCase: Clearing abbreviation cache');
    _abbreviationCache.clear();
    _cacheTimestamps.clear();
  }
}
