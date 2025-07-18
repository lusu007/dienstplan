enum AppTheme {
  light,
  dark,
  system,
}

enum AppLanguage {
  german('de', 'Deutsch'),
  english('en', 'English');

  const AppLanguage(this.code, this.displayName);
  final String code;
  final String displayName;
}

enum CalendarViewMode {
  month,
  twoWeeks,
  week,
}

enum DutyGroupFilter {
  all,
  selected,
  preferred,
}

enum AnimationType {
  slide,
  fade,
  scale,
  none,
}

enum ErrorType {
  network,
  database,
  validation,
  unknown,
}

enum LoadingState {
  idle,
  loading,
  success,
  error,
}

enum SortOrder {
  ascending,
  descending,
}

enum FilterType {
  date,
  dutyGroup,
  dutyType,
  allDay,
}
