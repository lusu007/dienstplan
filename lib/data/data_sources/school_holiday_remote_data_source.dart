import 'package:dio/dio.dart';
import 'package:dienstplan/core/utils/logger.dart';

import '../models/school_holiday.dart';

/// Remote data source for fetching school holidays from the API
abstract interface class SchoolHolidayRemoteDataSource {
  /// Fetch school holidays for a specific state and year
  Future<List<SchoolHoliday>> getSchoolHolidays({
    required String stateCode,
    required int year,
  });
}

/// Implementation of SchoolHolidayRemoteDataSource using Mehr-Schulferien API v2.1
class SchoolHolidayRemoteDataSourceImpl
    implements SchoolHolidayRemoteDataSource {
  final Dio _dio;

  // Base URL for Mehr-Schulferien API v2.1
  static const _baseUrl = 'https://www.mehr-schulferien.de/api/v2.1';

  SchoolHolidayRemoteDataSourceImpl({Dio? dio})
    : _dio = dio ?? Dio()
        ..options = BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        );

  @override
  Future<List<SchoolHoliday>> getSchoolHolidays({
    required String stateCode,
    required int year,
  }) async {
    try {
      // MSC v2.1 endpoint: /federal-states/{slug}/periods?start_date&end_date&type=vacation
      final String slug = _getStateNameFromCode(stateCode);
      final String start = '$year-01-01';
      final String end = '$year-12-31';
      await AppLogger.i(
        'SchoolHolidayRemote: Request GET /federal-states/$slug/periods?start_date=$start&end_date=$end&type=vacation',
      );
      final response = await _dio.get(
        '/federal-states/$slug/periods',
        queryParameters: {
          'start_date': start,
          'end_date': end,
          'type': 'vacation',
        },
      );
      if (response.statusCode == 200) {
        await AppLogger.d(
          'SchoolHolidayRemote: Response 200 with type=${response.data.runtimeType}',
        );
        final data = response.data;
        final String normalizedStateCode = stateCode.toUpperCase();
        final String stateName = slug;
        await AppLogger.d('SchoolHolidayRemote: Response data: $data');
        await AppLogger.d(
          'SchoolHolidayRemote: Data type: ${data.runtimeType}',
        );
        if (data is Map<String, dynamic> && data['data'] is List) {
          await AppLogger.d(
            'SchoolHolidayRemote: Found data array with ${(data['data'] as List).length} items',
          );
          return (data['data'] as List)
              .whereType<Map<String, dynamic>>()
              .map(
                (item) => _createHolidayFromApiData(
                  item,
                  normalizedStateCode,
                  stateName,
                ),
              )
              .toList();
        } else if (data is List) {
          await AppLogger.d(
            'SchoolHolidayRemote: Found direct list with ${data.length} items',
          );
          return data
              .whereType<Map<String, dynamic>>()
              .map(
                (item) => _createHolidayFromApiData(
                  item,
                  normalizedStateCode,
                  stateName,
                ),
              )
              .toList();
        }
        const String msg = 'Unexpected response format';
        await AppLogger.w('SchoolHolidayRemote: $msg');
        throw Exception(msg);
      }
      final String msg =
          'Failed to fetch holidays: HTTP ${response.statusCode} ${response.statusMessage}';
      await AppLogger.w('SchoolHolidayRemote: $msg');
      throw Exception(msg);
    } on DioException catch (e, stack) {
      await AppLogger.e('SchoolHolidayRemote: Network error', e, stack);
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Alternative implementation if the API uses a different structure
  /// This could be adapted based on the actual API documentation
  Future<List<SchoolHoliday>> getSchoolHolidaysAlternative({
    required String stateCode,
    required int year,
  }) async {
    try {
      // Some APIs might use state names or IDs instead of codes
      final stateName = _getStateNameFromCode(stateCode);
      await AppLogger.i(
        'SchoolHolidayRemote: Request GET /states/$stateName/holidays/$year',
      );
      final response = await _dio.get('/states/$stateName/holidays/$year');

      if (response.statusCode == 200) {
        final data = response.data;
        return _parseHolidayResponse(data, stateCode, stateName);
      } else {
        final String msg =
            'Failed to fetch holidays (alt): HTTP ${response.statusCode} ${response.statusMessage}';
        await AppLogger.w('SchoolHolidayRemote: $msg');
        throw Exception(msg);
      }
    } on DioException catch (e, stack) {
      await AppLogger.e('SchoolHolidayRemote (alt): Network error', e, stack);
      throw Exception('Network error: ${e.message}');
    }
  }

  List<SchoolHoliday> _parseHolidayResponse(
    dynamic data,
    String stateCode,
    String stateName,
  ) {
    final holidays = <SchoolHoliday>[];

    if (data is List) {
      for (final item in data) {
        holidays.add(_createHolidayFromApiData(item, stateCode, stateName));
      }
    } else if (data is Map<String, dynamic>) {
      final holidayList = data['holidays'] ?? data['data'] ?? [];
      for (final item in holidayList) {
        holidays.add(_createHolidayFromApiData(item, stateCode, stateName));
      }
    }

    return holidays;
  }

  SchoolHoliday _createHolidayFromApiData(
    Map<String, dynamic> data,
    String stateCode,
    String stateName,
  ) {
    AppLogger.d('SchoolHolidayRemote: Creating holiday from data: $data');
    // Adapt field names based on actual API response
    final DateTime start = _parseDate(
      data['starts_on'] ?? data['start_date'] ?? data['start'] ?? data['from'],
    );
    final DateTime end = _parseDate(
      data['ends_on'] ?? data['end_date'] ?? data['end'] ?? data['to'],
    );
    final String id = (data['id']?.toString() ?? '').isNotEmpty
        ? data['id'].toString()
        : '${stateCode}_${start.toIso8601String()}_${end.toIso8601String()}';
    final holiday = SchoolHoliday(
      id: id,
      name: data['name'] ?? data['title'] ?? 'Unknown Holiday',
      startDate: start,
      endDate: end,
      stateCode: stateCode,
      stateName: stateName,
      year: start.year,
      description: data['description'] as String?,
      type: data['type'] as String?,
    );
    AppLogger.d(
      'SchoolHolidayRemote: Created holiday: ${holiday.name} (${holiday.startDate} - ${holiday.endDate})',
    );
    return holiday;
  }

  DateTime _parseDate(dynamic date) {
    AppLogger.d(
      'SchoolHolidayRemote: Parsing date: $date (type: ${date.runtimeType})',
    );
    if (date is String) {
      final parsed = DateTime.parse(date);
      AppLogger.d('SchoolHolidayRemote: Parsed string date: $parsed');
      return parsed;
    } else if (date is int) {
      // Unix timestamp
      final parsed = DateTime.fromMillisecondsSinceEpoch(date * 1000);
      AppLogger.d('SchoolHolidayRemote: Parsed int date: $parsed');
      return parsed;
    } else {
      AppLogger.e('SchoolHolidayRemote: Invalid date format: $date');
      throw Exception('Invalid date format');
    }
  }

  String _getStateNameFromCode(String code) {
    // Map state codes to names used by the API
    final stateMap = {
      'BW': 'baden-wuerttemberg',
      'BY': 'bayern',
      'BE': 'berlin',
      'BB': 'brandenburg',
      'HB': 'bremen',
      'HH': 'hamburg',
      'HE': 'hessen',
      'MV': 'mecklenburg-vorpommern',
      'NI': 'niedersachsen',
      'NW': 'nordrhein-westfalen',
      'RP': 'rheinland-pfalz',
      'SL': 'saarland',
      'SN': 'sachsen',
      'ST': 'sachsen-anhalt',
      'SH': 'schleswig-holstein',
      'TH': 'thueringen',
    };

    return stateMap[code.toUpperCase()] ?? code.toLowerCase();
  }
}
