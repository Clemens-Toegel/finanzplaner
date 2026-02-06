import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../gen/app_localizations.dart';
import '../../models/purchase_item.dart';
import 'month_header_delegate.dart';
import 'purchase_summary_card.dart';

class PurchaseExpensesTab extends StatelessWidget {
  const PurchaseExpensesTab({
    super.key,
    required this.localizations,
    required this.items,
    required this.summaryDeductibleAmount,
    required this.onBuildItem,
  });

  final AppLocalizations localizations;
  final List<PurchaseItem> items;
  final String summaryDeductibleAmount;
  final Widget Function(PurchaseItem item) onBuildItem;

  List<_MonthSection> _groupItemsByMonth(List<PurchaseItem> items) {
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
          child: PurchaseSummaryCard(
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
        SliverToBoxAdapter(child: SizedBox(height: 96 + bottomInset)),
      ],
    );
  }
}

class _MonthSection {
  _MonthSection({required this.month, required this.items});

  final DateTime month;
  final List<PurchaseItem> items;
}
