import 'package:freezed_annotation/freezed_annotation.dart';

part 'german_state.freezed.dart';

/// Represents a German federal state (Bundesland)
@freezed
abstract class GermanState with _$GermanState {
  const factory GermanState({
    required String code,
    required String name,
    required String fullName,
    String? apiId, // ID used by the API if different from code
  }) = _GermanState;

  const GermanState._();

  /// List of all German federal states
  static const List<GermanState> allStates = [
    GermanState(
      code: 'BW',
      name: 'Baden-Württemberg',
      fullName: 'Baden-Württemberg',
    ),
    GermanState(code: 'BY', name: 'Bayern', fullName: 'Freistaat Bayern'),
    GermanState(code: 'BE', name: 'Berlin', fullName: 'Berlin'),
    GermanState(code: 'BB', name: 'Brandenburg', fullName: 'Brandenburg'),
    GermanState(
      code: 'HB',
      name: 'Bremen',
      fullName: 'Freie Hansestadt Bremen',
    ),
    GermanState(
      code: 'HH',
      name: 'Hamburg',
      fullName: 'Freie und Hansestadt Hamburg',
    ),
    GermanState(code: 'HE', name: 'Hessen', fullName: 'Hessen'),
    GermanState(
      code: 'MV',
      name: 'Mecklenburg-Vorpommern',
      fullName: 'Mecklenburg-Vorpommern',
    ),
    GermanState(code: 'NI', name: 'Niedersachsen', fullName: 'Niedersachsen'),
    GermanState(
      code: 'NW',
      name: 'Nordrhein-Westfalen',
      fullName: 'Nordrhein-Westfalen',
    ),
    GermanState(
      code: 'RP',
      name: 'Rheinland-Pfalz',
      fullName: 'Rheinland-Pfalz',
    ),
    GermanState(code: 'SL', name: 'Saarland', fullName: 'Saarland'),
    GermanState(code: 'SN', name: 'Sachsen', fullName: 'Freistaat Sachsen'),
    GermanState(code: 'ST', name: 'Sachsen-Anhalt', fullName: 'Sachsen-Anhalt'),
    GermanState(
      code: 'SH',
      name: 'Schleswig-Holstein',
      fullName: 'Schleswig-Holstein',
    ),
    GermanState(code: 'TH', name: 'Thüringen', fullName: 'Freistaat Thüringen'),
  ];

  /// Find a state by its code
  static GermanState? findByCode(String code) {
    try {
      return allStates.firstWhere(
        (state) => state.code.toUpperCase() == code.toUpperCase(),
      );
    } catch (_) {
      return null;
    }
  }
}
