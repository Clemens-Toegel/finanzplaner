import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../gen/app_localizations.dart';
import '../../models/expense_item.dart';
import 'month_header_delegate.dart';
import 'expense_summary_card.dart';

class ExpenseExpensesTab extends StatelessWidget {
  const ExpenseExpensesTab({
    super.key,
    required this.localizations,
    required this.items,
    required this.summaryDeductibleAmount,
    required this.onBuildItem,
  });

  final AppLocalizations localizations;
  final List<ExpenseItem> items;
  final String summaryDeductibleAmount;
  final Widget Function(ExpenseItem item) onBuildItem;

  List<_MonthSection> _groupItemsByMonth(List<ExpenseItem> items) {
    final sections = <_MonthSection>[];
    for (final item in items) {
      if (sections.isEmpty ||
          sections.last.month.year != item.date.year ||
          sections.last.month.month != item.date.month) {
        sections.add(
          _MonthSection(
            month: DateTime(item.date.year, item.date.month),
            items: [item],
          ),
        );
      } else {
        sections.last.items.add(item);
      }
    }
    return sections;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    final monthFormat = DateFormat.yMMMM(
      Localizations.localeOf(context).toString(),
    );
    final sections = _groupItemsByMonth(items);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: ExpenseSummaryCard(
            localizations: localizations,
            itemCount: items.length,
            formattedDeductibleAmount: summaryDeductibleAmount,
          ),
        ),
        for (
          var sectionIndex = 0;
          sectionIndex < sections.length;
          sectionIndex++
        )
          SliverMainAxisGroup(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: MonthHeaderDelegate(
                  title: monthFormat.format(sections[sectionIndex].month),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList.builder(
                  itemCount: sections[sectionIndex].items.length,
                  itemBuilder: (context, itemIndex) {
                    final item = sections[sectionIndex].items[itemIndex];
                    final isLastInSection =
                        itemIndex == sections[sectionIndex].items.length - 1;
                    final isLastSection = sectionIndex == sections.length - 1;
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: isLastInSection && isLastSection ? 0 : 12,
                      ),
                      child: onBuildItem(item),
                    );
                  },
                ),
              ),
            ],
          ),
        SliverPadding(
          padding: EdgeInsets.only(bottom: 96 + bottomInset),
          sliver: const SliverToBoxAdapter(
            child: ColoredBox(color: Colors.transparent),
          ),
        ),
      ],
    );
  }
}

class _MonthSection {
  _MonthSection({required this.month, required this.items});

  final DateTime month;
  final List<ExpenseItem> items;
}
