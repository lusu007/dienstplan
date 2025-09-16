import 'package:flutter/material.dart';
import 'package:dienstplan/domain/entities/german_state.dart';

class GermanStateDialog extends StatelessWidget {
  final String? selectedStateCode;

  const GermanStateDialog({super.key, this.selectedStateCode});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Bundesland auswählen'),
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
          child: const Text('Abbrechen'),
        ),
      ],
    );
  }
}
