import 'package:flutter/material.dart';

import '../../gen/app_localizations.dart';

class ExpenseSummaryCard extends StatelessWidget {
  const ExpenseSummaryCard({
    super.key,
    required this.localizations,
    required this.itemCount,
    required this.formattedDeductibleAmount,
  });

  final AppLocalizations localizations;
  final int itemCount;
  final String formattedDeductibleAmount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: ListTile(
          leading: const Icon(Icons.summarize),
          title: Text(localizations.deductibleTotalLabel),
          subtitle: Text(localizations.itemsTracked(itemCount)),
          trailing: Text(
            formattedDeductibleAmount,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
}
