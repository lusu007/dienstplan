import 'package:flutter/material.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/core/constants/app_colors.dart';

class PoliceAuthorityFilterChips extends StatelessWidget {
  final Set<String> availableAuthorities;
  final Set<String> selectedAuthorities;
  final Function(String) onAuthorityToggled;
  final VoidCallback onClearAll;

  const PoliceAuthorityFilterChips({
    super.key,
    required this.availableAuthorities,
    required this.selectedAuthorities,
    required this.onAuthorityToggled,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (availableAuthorities.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.filterByPoliceAuthority,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            TextButton(
              onPressed: selectedAuthorities.isNotEmpty ? onClearAll : null,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                l10n.clearAll,
                style: TextStyle(
                  fontSize: 12,
                  color: selectedAuthorities.isNotEmpty
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            ...availableAuthorities.map(
              (authority) => _buildFilterChip(
                context,
                authority,
                selectedAuthorities.contains(authority),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String authority,
    bool isSelected,
  ) {
    return FilterChip(
      label: Text(
        authority,
        style: TextStyle(
          fontSize: 12,
          height: 1.0,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? Colors.white : AppColors.primary,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onAuthorityToggled(authority),
      backgroundColor: Colors.transparent,
      selectedColor: AppColors.primary,
      checkmarkColor: Colors.white,
      side: const BorderSide(color: AppColors.primary, width: 1.5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
    );
  }
}
