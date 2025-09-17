import 'package:dartz/dartz.dart';

import '../../domain/entities/school_holiday.dart' as domain;
import '../../domain/failures/failure.dart';
import '../../domain/repositories/school_holiday_repository.dart';
import '../data_sources/school_holiday_local_data_source.dart';
import '../data_sources/school_holiday_remote_data_source.dart';
import '../models/mappers/school_holiday_mapper.dart';

/// Implementation of SchoolHolidayRepository
class SchoolHolidayRepositoryImpl implements SchoolHolidayRepository {
  final SchoolHolidayRemoteDataSource _remoteDataSource;
  final SchoolHolidayLocalDataSource _localDataSource;
  final SchoolHolidayMapper _mapper;

  // Cache validity duration (e.g., 7 days)
  static const _cacheValidityDuration = Duration(days: 7);

  SchoolHolidayRepositoryImpl({
    required SchoolHolidayRemoteDataSource remoteDataSource,
    required SchoolHolidayLocalDataSource localDataSource,
    SchoolHolidayMapper? mapper,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _mapper = mapper ?? const SchoolHolidayMapper();

  @override
  Future<Either<Failure, List<domain.SchoolHoliday>>> getSchoolHolidays({
    required String stateCode,
    required int year,
  }) async {
    try {
      // First, check if we have valid cached data
      final cachedHolidays = await _localDataSource.getCachedHolidays(
        stateCode: stateCode,
        year: year,
      );

      if (cachedHolidays != null) {
        // Check if cache is still valid
        final lastUpdate = await _localDataSource.getLastUpdateTime(
          stateCode: stateCode,
          year: year,
        );

        if (lastUpdate != null &&
            DateTime.now().difference(lastUpdate) < _cacheValidityDuration) {
          // Return cached data
          return Right(_mapper.toDomainList(cachedHolidays));
        }
      }

      // If no valid cache, fetch from remote
      final remoteHolidays = await _remoteDataSource.getSchoolHolidays(
        stateCode: stateCode,
        year: year,
      );

      // Cache the fetched data
      await _localDataSource.cacheHolidays(
        stateCode: stateCode,
        year: year,
        holidays: remoteHolidays,
      );

      return Right(_mapper.toDomainList(remoteHolidays));
    } catch (e) {
      // If remote fetch fails but we have cached data, return it
      final cachedHolidays = await _localDataSource.getCachedHolidays(
        stateCode: stateCode,
        year: year,
      );

      if (cachedHolidays != null) {
        return Right(_mapper.toDomainList(cachedHolidays));
      }

      return Left(
        NetworkFailure(
          technicalMessage: 'Failed to fetch school holidays: ${e.toString()}',
          stackTrace: StackTrace.current,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<domain.SchoolHoliday>>>
  getSchoolHolidaysForRange({
    required String stateCode,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final holidays = <domain.SchoolHoliday>[];
      final years = <int>{};

      // Determine which years we need to fetch
      for (var year = startDate.year; year <= endDate.year; year++) {
        years.add(year);
      }

      // Fetch holidays for each year
      for (final year in years) {
        final result = await getSchoolHolidays(
          stateCode: stateCode,
          year: year,
        );

        result.fold((failure) => throw failure, (yearHolidays) {
          // Filter holidays that fall within the date range
          holidays.addAll(
            yearHolidays.where((holiday) {
              return !holiday.endDate.isBefore(startDate) &&
                  !holiday.startDate.isAfter(endDate);
            }),
          );
        });
      }

      return Right(holidays);
    } catch (e) {
      return Left(
        NetworkFailure(
          technicalMessage:
              'Failed to fetch holidays for range: ${e.toString()}',
          stackTrace: StackTrace.current,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<domain.SchoolHoliday>>> getCachedHolidays({
    required String stateCode,
    required int year,
  }) async {
    try {
      final cachedHolidays = await _localDataSource.getCachedHolidays(
        stateCode: stateCode,
        year: year,
      );

      if (cachedHolidays == null) {
        return const Right([]);
      }

      return Right(_mapper.toDomainList(cachedHolidays));
    } catch (e) {
      return Left(
        StorageFailure(
          technicalMessage: 'Failed to get cached holidays: ${e.toString()}',
          stackTrace: StackTrace.current,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> clearCache() async {
    try {
      await _localDataSource.clearCache();
      return const Right(unit);
    } catch (e) {
      return Left(
        StorageFailure(
          technicalMessage: 'Failed to clear cache: ${e.toString()}',
          stackTrace: StackTrace.current,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<domain.SchoolHoliday>>> refreshHolidays({
    required String stateCode,
    required int year,
  }) async {
    try {
      // Force fetch from remote
      final remoteHolidays = await _remoteDataSource.getSchoolHolidays(
        stateCode: stateCode,
        year: year,
      );

      // Cache the fetched data
      await _localDataSource.cacheHolidays(
        stateCode: stateCode,
        year: year,
        holidays: remoteHolidays,
      );

      return Right(_mapper.toDomainList(remoteHolidays));
    } catch (e) {
      return Left(
        NetworkFailure(
          technicalMessage: 'Failed to refresh holidays: ${e.toString()}',
          stackTrace: StackTrace.current,
        ),
      );
    }
  }
}
