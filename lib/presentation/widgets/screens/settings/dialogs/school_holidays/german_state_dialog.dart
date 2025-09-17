import 'package:flutter/material.dart';
import 'package:dienstplan/domain/entities/german_state.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';

class GermanStateDialog extends StatelessWidget {
  final String? selectedStateCode;

  const GermanStateDialog({super.key, this.selectedStateCode});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.selectFederalState),
      content: SizedBox(
        width: double.maxFinite,
        child: RadioGroup<String>(
          groupValue: selectedStateCode,
          onChanged: (String? value) {
            if (value != null) {
              Navigator.of(context).pop(value);
            }
          },
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: GermanState.allStates.length,
            itemBuilder: (context, index) {
              final state = GermanState.allStates[index];
              final isSelected = state.code == selectedStateCode;

              return ListTile(
                title: Text(state.name),
                subtitle: state.fullName != state.name
                    ? Text(state.fullName)
                    : null,
                leading: Radio<String>(value: state.code),
                selected: isSelected,
                onTap: () {
                  Navigator.of(context).pop(state.code);
                },
              );
            },
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(l10n.cancel),
        ),
      ],
    );
  }
}
