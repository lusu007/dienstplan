import 'package:dienstplan/presentation/widgets/common/app_glass_button.dart';
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

    if (availableAuthorities.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<String> authorities = availableAuthorities.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.filterByPoliceAuthority,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 8),
            AppGlassButton(
              compact: true,
              fontSize: 14,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              onPressed: selectedAuthorities.isNotEmpty ? onClearAll : null,
              child: Text(l10n.clearAll),
            ),
          ],
        ),
        const SizedBox(height: kGlassChipWrapSpacing),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (int i = 0; i < authorities.length; i++) ...<Widget>[
                if (i > 0) const SizedBox(width: kGlassChipWrapSpacing),
                _buildFilterChip(
                  context,
                  authorities[i],
                  selectedAuthorities.contains(authorities[i]),
                ),
              ],
            ],
          ),
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
      showCheckmark: true,
      onTap: () => onAuthorityToggled(authority),
    );
  }
}
