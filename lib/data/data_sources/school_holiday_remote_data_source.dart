import 'package:dio/dio.dart';

import '../models/school_holiday.dart';

/// Remote data source for fetching school holidays from the API
abstract interface class SchoolHolidayRemoteDataSource {
  /// Fetch school holidays for a specific state and year
  Future<List<SchoolHoliday>> getSchoolHolidays({
    required String stateCode,
    required int year,
  });
}

/// Implementation of SchoolHolidayRemoteDataSource using mehr-schulferien.de API
class SchoolHolidayRemoteDataSourceImpl implements SchoolHolidayRemoteDataSource {
  final Dio _dio;
  
  // Note: This is a placeholder URL. The actual API structure might be different
  // You might need to adapt this based on the actual API documentation
  static const _baseUrl = 'https://www.mehr-schulferien.de/api/v2';
  
  SchoolHolidayRemoteDataSourceImpl({Dio? dio}) 
      : _dio = dio ?? Dio()..options = BaseOptions(
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
      // The actual API endpoint structure might be different
      // This is a placeholder implementation
      final response = await _dio.get(
        '/holidays',
        queryParameters: {
          'state': stateCode.toLowerCase(),
          'year': year,
          'type': 'school',
        },
      );

      if (response.statusCode == 200) {
        // Parse the response based on the actual API structure
        final data = response.data;
        
        if (data is Map<String, dynamic> && data['data'] is List) {
          return (data['data'] as List)
              .map((holiday) => SchoolHoliday.fromJson(holiday))
              .toList();
        } else if (data is List) {
          return data
              .map((holiday) => SchoolHoliday.fromJson(holiday))
              .toList();
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to fetch holidays: ${response.statusCode}');
      }
    } on DioException catch (e) {
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
      
      final response = await _dio.get(
        '/states/$stateName/holidays/$year',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return _parseHolidayResponse(data, stateCode, stateName);
      } else {
        throw Exception('Failed to fetch holidays: ${response.statusCode}');
      }
    } on DioException catch (e) {
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
    // Adapt field names based on actual API response
    return SchoolHoliday(
      id: data['id']?.toString() ?? '',
      name: data['name'] ?? data['title'] ?? 'Unknown Holiday',
      startDate: _parseDate(data['start_date'] ?? data['start'] ?? data['from']),
      endDate: _parseDate(data['end_date'] ?? data['end'] ?? data['to']),
      stateCode: stateCode,
      stateName: stateName,
      description: data['description'],
      type: data['type'] ?? 'regular',
    );
  }

  DateTime _parseDate(dynamic date) {
    if (date is String) {
      return DateTime.parse(date);
    } else if (date is int) {
      // Unix timestamp
      return DateTime.fromMillisecondsSinceEpoch(date * 1000);
    } else {
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