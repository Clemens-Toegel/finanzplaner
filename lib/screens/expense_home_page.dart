import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../gen/app_localizations.dart';
import '../localization/app_localizations_ext.dart';
import '../models/expense_account_type.dart';
import '../models/expense_item.dart';
import '../services/offline_bill_ocr_service.dart';
import '../state/pilo_home_controller.dart';
import '../widgets/pilo_logo.dart';
import 'expense_detail_page.dart';
import 'widgets/account_settings_sheet.dart';
import 'widgets/add_edit_expense_sheet.dart';
import 'widgets/expense_account_switcher.dart';
import 'widgets/expense_dashboard_tab.dart';
import 'widgets/expense_empty_state.dart';
import 'widgets/expense_expense_card.dart';
import 'widgets/expense_expenses_tab.dart';

class PiloHomePage extends StatelessWidget {
  const PiloHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PiloHomeController()..initialize(),
      child: const _PiloHomeView(),
    );
  }
}

class _PiloHomeView extends StatelessWidget {
  const _PiloHomeView();

  Color _accountColor(ExpenseAccountType selectedAccount) {
    return selectedAccount == ExpenseAccountType.business
        ? Colors.blue
        : Colors.orange;
  }

  Future<void> _openAccountSettingsSheet(
    BuildContext context,
    PiloHomeController controller,
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
          onExportExcel: (dateRange) async {
            final success = await controller.exportExcelForTaxConsultant(
              l10n,
              dateRange: dateRange,
            );
            if (!context.mounted) {
              return;
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  success
                      ? l10n.exportExcelSuccessMessage
                      : l10n.noItemsInDateRangeMessage,
                ),
              ),
            );
          },
          onExportPdf: (dateRange) async {
            await _exportPdf(
              context,
              l10n,
              controller,
              controller.items,
              dateRange: dateRange,
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
    PiloHomeController controller, {
    ExpenseItem? item,
    BillScanMode? initialScanMode,
    BillImageSource initialScanSource = BillImageSource.camera,
  }) async {
    final draft = await showModalBottomSheet<ExpenseItem>(
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
        return AddEditExpenseSheet(
          selectedAccount: controller.selectedAccount,
          item: item,
          ocrService: controller.offlineBillOcrService,
          dateFormat: controller.dateFormat,
          currencyFormat: controller.currencyFormat,
          initialScanMode: initialScanMode,
          initialScanSource: initialScanSource,
        );
      },
    );

    if (draft != null) {
      await controller.saveExpenseDraft(draft);
    }
  }

  Future<void> _exportPdf(
    BuildContext context,
    AppLocalizations l10n,
    PiloHomeController controller,
    List<ExpenseItem> items, {
    required DateTimeRange dateRange,
  }) async {
    if (items.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.addBeforeExport)));
      return;
    }

    final success = await controller.exportPdf(l10n, dateRange: dateRange);
    if (!context.mounted || success) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.noItemsInDateRangeMessage)));
  }

  Future<void> _confirmDeleteSelected(
    BuildContext context,
    PiloHomeController controller,
  ) async {
    final selectedCount = controller.selectedExpenseIds.length;
    if (selectedCount == 0) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteSelectedExpensesTitle),
        content: Text(l10n.deleteSelectedExpensesMessage(selectedCount)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.confirmDeleteAction),
          ),
        ],
      ),
    );

    if (shouldDelete == true && context.mounted) {
      await controller.deleteSelectedExpenses();
    }
  }

  Widget _buildExpenseCard(
    BuildContext context,
    PiloHomeController controller,
    ExpenseItem item,
    AppLocalizations l10n,
    bool isSelectionMode,
  ) {
    final isSelected = controller.isExpenseSelected(item);

    return ExpenseExpenseCard(
      item: item,
      localizations: l10n,
      dateFormat: controller.dateFormat,
      currencyFormat: controller.currencyFormat,
      isSelectionMode: isSelectionMode,
      isSelected: isSelected,
      onLongPress: () => controller.toggleExpenseSelection(item),
      onTap: () async {
        if (isSelectionMode) {
          controller.toggleExpenseSelection(item);
          return;
        }

        final action = await Navigator.push<ExpenseDetailAction>(
          context,
          MaterialPageRoute(
            builder: (context) => ExpenseDetailPage(item: item),
          ),
        );
        if (!context.mounted) {
          return;
        }
        if (action == ExpenseDetailAction.edit) {
          await _openAddItemSheet(context, controller, item: item);
        }
        if (action == ExpenseDetailAction.delete && item.id != null) {
          await controller.deleteExpense(item);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = context.read<PiloHomeController>();

    final selectedAccount = context
        .select<PiloHomeController, ExpenseAccountType>(
          (c) => c.selectedAccount,
        );
    final selectedTabIndex = context.select<PiloHomeController, int>(
      (c) => c.selectedTabIndex,
    );
    final isLoading = context.select<PiloHomeController, bool>(
      (c) => c.isLoading,
    );
    final isExporting = context.select<PiloHomeController, bool>(
      (c) => c.isExporting,
    );
    final items = context.select<PiloHomeController, List<ExpenseItem>>(
      (c) => c.items,
    );
    final isSelectionMode = context.select<PiloHomeController, bool>(
      (c) => c.isSelectionMode,
    );
    final selectedCount = context.select<PiloHomeController, int>(
      (c) => c.selectedExpenseIds.length,
    );

    final accountColor = _accountColor(selectedAccount);

    return Scaffold(
      appBar: AppBar(
        title: isSelectionMode
            ? Text(l10n.selectionCountLabel(selectedCount))
            : Row(
                children: [
                  const PiloLogo(size: 24, showWordmark: false),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        l10n.taxRefundExpensesTitle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
        actions: isSelectionMode
            ? [
                IconButton(
                  tooltip: l10n.deleteSelectionTooltip,
                  onPressed: selectedCount == 0
                      ? null
                      : () => _confirmDeleteSelected(context, controller),
                  icon: const Icon(Icons.delete_outline),
                ),
                IconButton(
                  tooltip: l10n.clearSelectionTooltip,
                  onPressed: controller.clearSelection,
                  icon: const Icon(Icons.close),
                ),
              ]
            : [
                IconButton(
                  tooltip: l10n.accountSettingsTitle,
                  onPressed: isExporting
                      ? null
                      : () => _openAccountSettingsSheet(context, controller),
                  icon: const Icon(Icons.settings_outlined),
                ),
              ],
        bottom: isSelectionMode
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(88),
                child: ExpenseAccountSwitcher(
                  localizations: l10n,
                  selectedAccount: selectedAccount,
                  accountColor: accountColor,
                  onChanged: controller.changeAccount,
                ),
              ),
      ),
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              behavior: HitTestBehavior.translucent,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : items.isEmpty
                  ? ExpenseEmptyState(
                      localizations: l10n,
                      accountLabelInSentence: l10n.accountLabelInSentence(
                        selectedAccount,
                      ),
                    )
                  : selectedTabIndex == 0
                  ? ExpenseExpensesTab(
                      localizations: l10n,
                      items: items,
                      summaryDeductibleAmount: controller.currencyFormat.format(
                        controller.deductibleAmount,
                      ),
                      onBuildItem: (item) => _buildExpenseCard(
                        context,
                        controller,
                        item,
                        l10n,
                        isSelectionMode,
                      ),
                    )
                  : ExpenseDashboardTab(
                      localizations: l10n,
                      formattedTotalAmount: controller.currencyFormat.format(
                        controller.totalAmount,
                      ),
                      formattedDeductibleAmount: controller.currencyFormat
                          .format(controller.deductibleAmount),
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
            if (isExporting)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black26,
                  child: Center(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(),
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(l10n.exportInProgressMessage),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: accountColor.withValues(alpha: 0.2),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return IconThemeData(color: accountColor);
            }
            return null;
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return TextStyle(
                color: accountColor,
                fontWeight: FontWeight.w600,
              );
            }
            return null;
          }),
        ),
        child: NavigationBar(
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
      ),
      floatingActionButton: isSelectionMode
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'quick_scan_receipt',
                  tooltip: l10n.scanReceiptAction,
                  onPressed: isExporting
                      ? null
                      : () => _openAddItemSheet(
                          context,
                          controller,
                          initialScanMode: BillScanMode.shopReceipt,
                        ),
                  backgroundColor: accountColor,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.camera_alt_outlined),
                ),
                const SizedBox(height: 12),
                FloatingActionButton.extended(
                  heroTag: 'add_expense',
                  onPressed: isExporting
                      ? null
                      : () => _openAddItemSheet(context, controller),
                  backgroundColor: accountColor,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addExpense),
                ),
              ],
            ),
    );
  }
}
