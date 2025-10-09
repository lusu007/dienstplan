/// Computes the effective duty group for the current user using fallback order.
/// Priority:
/// 1) preferredGroup
/// 2) selectedGroup
/// 3) myDutyGroup
String? computeEffectiveMyGroup({
  required String? preferredGroup,
  required String? selectedGroup,
  required String? myDutyGroup,
}) {
  final String? preferred = _nonNullNonEmpty(preferredGroup);
  if (preferred != null) return preferred;
  final String? selected = _nonNullNonEmpty(selectedGroup);
  if (selected != null) return selected;
  final String? mine = _nonNullNonEmpty(myDutyGroup);
  return mine;
}

/// Returns the input value if non-null and non-empty; otherwise returns null.
String? _nonNullNonEmpty(String? value) =>
    value?.isNotEmpty == true ? value : null;
