import 'package:flutter/material.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/core/constants/glass_chip_tokens.dart';
import 'package:dienstplan/presentation/widgets/common/glass_filter_chip.dart';

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
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

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
                padding: const EdgeInsets.symmetric(
                  horizontal: kGlassChipWrapSpacing,
                  vertical: 4,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                l10n.clearAll,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selectedAuthorities.isNotEmpty
                      ? colorScheme.primary
                      : colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: kGlassChipWrapSpacing),
        Wrap(
          spacing: kGlassChipWrapSpacing,
          runSpacing: kGlassChipWrapRunSpacing,
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
    return GlassFilterChip(
      label: authority,
      isSelected: isSelected,
      onTap: () => onAuthorityToggled(authority),
    );
  }
}
