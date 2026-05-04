import 'package:dienstplan/domain/entities/schedule.dart';

class CalendarDayScheduleLookup {
  final Map<int, Map<String, Map<String, List<Schedule>>>> _officialByDay;
  final Map<int, List<Schedule>> _personalByDay;
  final Map<int, int> _monthSignatures;
  final int _scheduleCount;

  CalendarDayScheduleLookup(List<Schedule> schedules)
    : _officialByDay = <int, Map<String, Map<String, List<Schedule>>>>{},
      _personalByDay = <int, List<Schedule>>{},
      _monthSignatures = <int, int>{},
      _scheduleCount = schedules.length {
    for (final Schedule schedule in schedules) {
      final int dayKey = _dayKey(schedule.date);
      final int monthKey = _monthKey(schedule.date);
      _monthSignatures[monthKey] =
          (_monthSignatures[monthKey] ?? 0) ^
          Object.hash(
            schedule.date.day,
            schedule.dutyTypeId,
            schedule.dutyGroupName,
            schedule.configName,
            schedule.service,
            schedule.isUserDefined,
            schedule.personalEntryId,
            schedule.isUserDefined ? schedule.startMinutesFromMidnight : null,
            schedule.isUserDefined ? schedule.endMinutesFromMidnight : null,
            schedule.isUserDefined ? schedule.isAllDay : null,
          );

      if (schedule.isUserDefined) {
        _personalByDay.putIfAbsent(dayKey, () => <Schedule>[]).add(schedule);
        continue;
      }

      _officialByDay
          .putIfAbsent(dayKey, () => <String, Map<String, List<Schedule>>>{})
          .putIfAbsent(schedule.configName, () => <String, List<Schedule>>{})
          .putIfAbsent(schedule.dutyGroupName, () => <Schedule>[])
          .add(schedule);
    }

    for (final List<Schedule> personalSchedules in _personalByDay.values) {
      personalSchedules.sort((Schedule a, Schedule b) {
        final int aStart = a.startMinutesFromMidnight ?? -1;
        final int bStart = b.startMinutesFromMidnight ?? -1;
        final int byTime = aStart.compareTo(bStart);
        if (byTime != 0) {
          return byTime;
        }
        return a.service.compareTo(b.service);
      });
    }
  }

  Schedule? firstOfficialSchedule({
    required DateTime day,
    required String configName,
    required String dutyGroupName,
    bool requireDutyType = false,
  }) {
    final List<Schedule>? schedules =
        _officialByDay[_dayKey(day)]?[configName]?[dutyGroupName];
    if (schedules == null || schedules.isEmpty) {
      return null;
    }

    if (!requireDutyType) {
      return schedules.first;
    }

    for (final Schedule schedule in schedules) {
      if (schedule.dutyTypeId.isNotEmpty && schedule.dutyTypeId != '-') {
        return schedule;
      }
    }
    return null;
  }

  List<Schedule> personalSchedulesForDay(DateTime day) {
    final List<Schedule>? schedules = _personalByDay[_dayKey(day)];
    if (schedules == null) {
      return const <Schedule>[];
    }
    return List<Schedule>.unmodifiable(schedules);
  }

  int signatureForMonth(DateTime day) {
    return Object.hash(
      _monthKey(day),
      _scheduleCount,
      _monthSignatures[_monthKey(day)] ?? 0,
    );
  }

  static int _dayKey(DateTime date) {
    return date.year * 10000 + date.month * 100 + date.day;
  }

  static int _monthKey(DateTime date) {
    return date.year * 100 + date.month;
  }
}
