import 'package:dienstplan/domain/entities/duty_type.dart';

/// Short label for calendar cells; [dutyTypeId] stays the stable config key.
String resolveDutyTypeAbbreviation(
  String dutyTypeId,
  Map<String, DutyType>? dutyTypes,
) {
  if (dutyTypeId.isEmpty || dutyTypeId == '-') {
    return dutyTypeId;
  }
  final DutyType? dt = dutyTypes?[dutyTypeId];
  final String? trimmed = dt?.abbr?.trim();
  if (trimmed != null && trimmed.isNotEmpty) {
    return trimmed;
  }
  return dutyTypeId;
}

/// Invalidates memoized calendar duty strings when [abbr] values change without schedule rows changing.
int hashDutyTypesAbbreviationSignature(Map<String, DutyType>? dutyTypes) {
  if (dutyTypes == null || dutyTypes.isEmpty) {
    return 0;
  }
  final List<String> keys = dutyTypes.keys.toList()..sort();
  int hash = 0;
  for (final String k in keys) {
    final DutyType dt = dutyTypes[k]!;
    hash = Object.hash(hash, k, dt.abbr ?? '');
  }
  return hash;
}
