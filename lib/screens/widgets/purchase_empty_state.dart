import 'package:flutter/material.dart';

import '../../gen/app_localizations.dart';

class PurchaseEmptyState extends StatelessWidget {
  const PurchaseEmptyState({
    super.key,
    required this.localizations,
    required this.accountLabelInSentence,
  });

  final AppLocalizations localizations;
  final String accountLabelInSentence;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Icon(
                Icons.receipt_long,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Text(
              localizations.emptyStateTitle,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            Text(
              localizations.emptyStateSubtitle(accountLabelInSentence),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
