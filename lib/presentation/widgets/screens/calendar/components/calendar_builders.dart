import 'package:table_calendar/table_calendar.dart' as tc;
import 'package:dienstplan/presentation/widgets/screens/calendar/components/calendar_day.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/date_selector/animated_calendar_day.dart';
import 'package:dienstplan/core/constants/calendar_config.dart';

/// Optimized calendar builders with const constructors and RepaintBoundary
class CustomCalendarBuilders {
  static tc.CalendarBuilders create() {
    return tc.CalendarBuilders(
      defaultBuilder: (context, day, focusedDay) => CalendarDay(
        day: day,
        dayType: CalendarDayType.default_,
        width: CalendarConfig.kCalendarDayWidth,
        height: CalendarConfig.kCalendarDayHeight,
      ),
      outsideBuilder: (context, day, focusedDay) => CalendarDay(
        day: day,
        dayType: CalendarDayType.outside,
        width: CalendarConfig.kCalendarDayWidth,
        height: CalendarConfig.kCalendarDayHeight,
      ),
      selectedBuilder: (context, day, focusedDay) => CalendarDay(
        day: day,
        dayType: CalendarDayType.selected,
        width: CalendarConfig.kCalendarDayWidth,
        height: CalendarConfig.kCalendarDayHeight,
      ),
      todayBuilder: (context, day, focusedDay) => CalendarDay(
        day: day,
        dayType: CalendarDayType.today,
        width: CalendarConfig.kCalendarDayWidth,
        height: CalendarConfig.kCalendarDayHeight,
      ),
    );
  }
}
