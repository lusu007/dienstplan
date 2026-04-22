import 'package:freezed_annotation/freezed_annotation.dart';

part 'calendar_ui_state.freezed.dart';

@freezed
abstract class CalendarUiState with _$CalendarUiState {
  const factory CalendarUiState({
    required bool isLoading,
    String? error,
    DateTime? selectedDay,
    DateTime? focusedDay,
  }) = _CalendarUiState;

  const CalendarUiState._();

  factory CalendarUiState.initial() => CalendarUiState(
    isLoading: false,
    selectedDay: DateTime.now(),
    focusedDay: DateTime.now(),
  );
}
