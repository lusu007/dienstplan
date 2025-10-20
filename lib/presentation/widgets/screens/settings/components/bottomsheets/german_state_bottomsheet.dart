import 'package:flutter/material.dart';
import 'package:dienstplan/domain/entities/german_state.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/selection_bottomsheet.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/generic_bottomsheet.dart';

class GermanStateBottomsheet {
  static Future<String?> show(BuildContext context, String? selectedStateCode) {
    final l10n = AppLocalizations.of(context);

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) => SelectionBottomsheet(
        title: l10n.selectFederalState,
        items: GermanState.allStates
            .map(
              (state) => SelectionItem(
                title: state.name,
                subtitle: state.fullName != state.name ? state.fullName : null,
                value: state.code,
              ),
            )
            .toList(),
        selectedValue: selectedStateCode,
        onItemSelected: (stateCode) {
          Navigator.of(dialogContext).pop(stateCode);
        },
      ),
    );
  }
}
