import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../gen/app_localizations.dart';
import '../../state/add_edit_purchase_controller.dart';

class AddEditPurchaseNotesStep extends StatelessWidget {
  const AddEditPurchaseNotesStep({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = context.read<AddEditPurchaseController>();

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Text(l10n.notesLabel, style: Theme.of(context).textTheme.titleSmall),
        Padding(
          padding: const EdgeInsets.only(top: 8),
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
