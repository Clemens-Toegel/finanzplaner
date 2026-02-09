import 'package:flutter/material.dart';

import '../../gen/app_localizations.dart';
import '../../widgets/pilo_logo.dart';
import 'dashboard_metric_card.dart';

class ExpenseDashboardTab extends StatelessWidget {
  const ExpenseDashboardTab({
    super.key,
    required this.localizations,
    required this.formattedTotalAmount,
    required this.formattedDeductibleAmount,
    required this.formattedNonDeductibleAmount,
    required this.formattedAverageAmount,
    required this.formattedTopCategories,
  });

  final AppLocalizations localizations;
  final String formattedTotalAmount;
  final String formattedDeductibleAmount;
  final String formattedNonDeductibleAmount;
  final String formattedAverageAmount;
  final List<({String category, String amount})> formattedTopCategories;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return Stack(
      children: [
        IgnorePointer(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 24, right: 12),
              child: Opacity(
                opacity: 0.09,
                child: PiloLogo(size: 120, showWordmark: false),
              ),
            ),
          ),
        ),
        ListView(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 96 + bottomInset),
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                DashboardMetricCard(
                  title: localizations.totalAmountLabel,
                  value: formattedTotalAmount,
                  icon: Icons.account_balance_wallet,
                ),
                DashboardMetricCard(
                  title: localizations.deductibleTotalLabel,
                  value: formattedDeductibleAmount,
                  icon: Icons.check_circle,
                ),
                DashboardMetricCard(
                  title: localizations.nonDeductibleTotalLabel,
                  value: formattedNonDeductibleAmount,
                  icon: Icons.remove_circle_outline,
                ),
                DashboardMetricCard(
                  title: localizations.averageExpenseLabel,
                  value: formattedAverageAmount,
                  icon: Icons.analytics,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 12,
                    children: [
                      Text(
                        localizations.topCategoriesLabel,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      ...formattedTopCategories.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            spacing: 8,
                            children: [
                              Expanded(child: Text(entry.category)),
                              Text(entry.amount),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
