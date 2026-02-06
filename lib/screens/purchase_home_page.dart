import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../gen/app_localizations.dart';
import '../localization/app_localizations_ext.dart';
import '../models/expense_account_type.dart';
import '../models/purchase_item.dart';
import '../state/purchase_home_controller.dart';
import 'purchase_detail_page.dart';
import 'widgets/account_settings_sheet.dart';
import 'widgets/add_edit_purchase_sheet.dart';
import 'widgets/purchase_account_switcher.dart';
import 'widgets/purchase_dashboard_tab.dart';
import 'widgets/purchase_empty_state.dart';
import 'widgets/purchase_expense_card.dart';
import 'widgets/purchase_expenses_tab.dart';

class PurchaseHomePage extends StatelessWidget {
  const PurchaseHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PurchaseHomeController()..initialize(),
      child: const _PurchaseHomeView(),
    );
  }
}

class _PurchaseHomeView extends StatelessWidget {
  const _PurchaseHomeView();

  Color _accountColor(ExpenseAccountType selectedAccount) {
    return selectedAccount == ExpenseAccountType.business
        ? Colors.blue
        : Colors.orange;
  }

  Future<void> _openAccountSettingsSheet(
    BuildContext context,
    PurchaseHomeController controller,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    final wasSaved = await showModalBottomSheet<bool>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return AccountSettingsSheet(
          initialSettings: controller.accountSettings,
          selectedAccount: controller.selectedAccount,
          onSave: controller.saveAccountSettings,
          onExportExcel: (sharePositionOrigin) async {
            final success = await controller.exportExcelForTaxConsultant(
              l10n,
              sharePositionOrigin: sharePositionOrigin,
            );
            if (!context.mounted) {
              return;
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  success
                      ? l10n.exportExcelSuccessMessage
                      : l10n.addBeforeExport,
                ),
              ),
            );
          },
        );
      },
    );

    if (wasSaved == true && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.accountSettingsSavedMessage)));
    }
  }

  Future<void> _openAddItemSheet(
    BuildContext context,
    PurchaseHomeController controller, {
    PurchaseItem? item,
  }) async {
    final draft = await showModalBottomSheet<PurchaseItem>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      isDismissible: false,
      enableDrag: false,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 8,
      builder: (context) {
        return AddEditPurchaseSheet(
          selectedAccount: controller.selectedAccount,
          item: item,
          ocrService: controller.offlineBillOcrService,
          dateFormat: controller.dateFormat,
          currencyFormat: controller.currencyFormat,
        );
      },
    );

    if (draft != null) {
      await controller.savePurchaseDraft(draft);
    }
  }

  Future<void> _exportPdf(
    BuildContext context,
    AppLocalizations l10n,
    PurchaseHomeController controller,
    List<PurchaseItem> items,
  ) async {
    if (items.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.addBeforeExport)));
      return;
    }

    await controller.exportPdf(l10n);
  }

  Widget _buildExpenseCard(
    BuildContext context,
    PurchaseHomeController controller,
    PurchaseItem item,
    AppLocalizations l10n,
  ) {
    return PurchaseExpenseCard(
      item: item,
      localizations: l10n,
      dateFormat: controller.dateFormat,
      currencyFormat: controller.currencyFormat,
      onTap: () async {
        final action = await Navigator.push<PurchaseDetailAction>(
          context,
          MaterialPageRoute(
            builder: (context) => PurchaseDetailPage(item: item),
          ),
        );
        if (!context.mounted) {
          return;
        }
        if (action == PurchaseDetailAction.edit) {
          await _openAddItemSheet(context, controller, item: item);
        }
        if (action == PurchaseDetailAction.delete && item.id != null) {
          await controller.deletePurchase(item.id!);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = context.read<PurchaseHomeController>();

    final selectedAccount = context
        .select<PurchaseHomeController, ExpenseAccountType>(
          (c) => c.selectedAccount,
        );
    final selectedTabIndex = context.select<PurchaseHomeController, int>(
      (c) => c.selectedTabIndex,
    );
    final isLoading = context.select<PurchaseHomeController, bool>(
      (c) => c.isLoading,
    );
    final items = context.select<PurchaseHomeController, List<PurchaseItem>>(
      (c) => c.items,
    );

    final accountColor = _accountColor(selectedAccount);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.taxRefundPurchasesTitle),
        actions: [
          IconButton(
            tooltip: l10n.accountSettingsTitle,
            onPressed: () => _openAccountSettingsSheet(context, controller),
            icon: const Icon(Icons.settings_outlined),
          ),
          IconButton(
            tooltip: l10n.exportPdfTooltip,
            onPressed: () => _exportPdf(context, l10n, controller, items),
            icon: const Icon(Icons.picture_as_pdf),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(88),
          child: PurchaseAccountSwitcher(
            localizations: l10n,
            selectedAccount: selectedAccount,
            accountColor: accountColor,
            onChanged: controller.changeAccount,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : items.isEmpty
              ? PurchaseEmptyState(
                  localizations: l10n,
                  accountLabelInSentence: l10n.accountLabelInSentence(
                    selectedAccount,
                  ),
                )
              : selectedTabIndex == 0
              ? PurchaseExpensesTab(
                  localizations: l10n,
                  items: items,
                  summaryDeductibleAmount: controller.currencyFormat.format(
                    controller.deductibleAmount,
                  ),
                  onBuildItem: (item) =>
                      _buildExpenseCard(context, controller, item, l10n),
                )
              : PurchaseDashboardTab(
                  localizations: l10n,
                  formattedTotalAmount: controller.currencyFormat.format(
                    controller.totalAmount,
                  ),
                  formattedDeductibleAmount: controller.currencyFormat.format(
                    controller.deductibleAmount,
                  ),
                  formattedNonDeductibleAmount: controller.currencyFormat
                      .format(controller.nonDeductibleAmount),
                  formattedAverageAmount: controller.currencyFormat.format(
                    controller.totalAmount / items.length,
                  ),
                  formattedTopCategories:
                      (controller.categoryTotals.entries.toList()
                            ..sort((a, b) => b.value.compareTo(a.value)))
                          .take(5)
                          .map(
                            (entry) => (
                              category: entry.key,
                              amount: controller.currencyFormat.format(
                                entry.value,
                              ),
                            ),
                          )
                          .toList(),
                ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedTabIndex,
        onDestinationSelected: controller.changeTab,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long),
            label: l10n.expensesTabLabel,
          ),
          NavigationDestination(
            icon: const Icon(Icons.analytics_outlined),
            selectedIcon: const Icon(Icons.analytics),
            label: l10n.dashboardTabLabel,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddItemSheet(context, controller),
        backgroundColor: accountColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(l10n.addPurchase),
      ),
    );
  }
}
