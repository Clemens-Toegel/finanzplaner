import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../gen/app_localizations.dart';
import '../../state/add_edit_expense_controller.dart';

class AddEditExpenseNotesStep extends StatelessWidget {
  const AddEditExpenseNotesStep({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = context.read<AddEditExpenseController>();

    return ListView(
      padding: const EdgeInsets.only(top: 4),
      children: [
        Text(l10n.notesLabel, style: Theme.of(context).textTheme.titleSmall),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: TextFormField(
            controller: controller.notesController,
            decoration: InputDecoration(labelText: l10n.notesLabel),
            minLines: 6,
            maxLines: 10,
            textInputAction: TextInputAction.done,
          ),
        ),
      ],
    );
  }
}
