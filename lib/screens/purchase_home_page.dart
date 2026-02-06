import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/purchase_repository.dart';
import '../gen/app_localizations.dart';
import '../localization/app_localizations_ext.dart';
import '../models/account_settings.dart';
import '../models/expense_account_type.dart';
import '../models/purchase_item.dart';
import '../screens/purchase_detail_page.dart';
import '../services/offline_bill_ocr_service.dart';
import '../services/pdf_exporter.dart';
import 'widgets/account_settings_sheet.dart';
import 'widgets/add_edit_purchase_sheet.dart';
import 'widgets/dashboard_metric_card.dart';
import 'widgets/month_header_delegate.dart';
import 'widgets/purchase_expense_card.dart';

class PurchaseHomePage extends StatefulWidget {
  const PurchaseHomePage({super.key});

  @override
  State<PurchaseHomePage> createState() => _PurchaseHomePageState();
}

class _PurchaseHomePageState extends State<PurchaseHomePage> {
  final PurchaseRepository _repository = PurchaseRepository();
  final PdfExporter _pdfExporter = PdfExporter();
  final OfflineBillOcrService _offlineBillOcrService = OfflineBillOcrService();
  final DateFormat _dateFormat = DateFormat('dd.MM.yyyy');
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'de_AT',
    symbol: '€',
  );

  ExpenseAccountType _selectedAccount = ExpenseAccountType.business;
  List<PurchaseItem> _items = [];
  bool _isLoading = true;
  Map<ExpenseAccountType, AccountSettings> _accountSettings = {
    ExpenseAccountType.personal: const AccountSettings(
      accountType: ExpenseAccountType.personal,
    ),
    ExpenseAccountType.business: const AccountSettings(
      accountType: ExpenseAccountType.business,
    ),
  };

  double get _totalAmount =>
      _items.fold(0, (total, item) => total + item.amount);

  double get _deductibleAmount => _items
      .where((item) => item.isDeductible)
      .fold(0, (total, item) => total + item.amount);

  double get _nonDeductibleAmount => _totalAmount - _deductibleAmount;

  Map<String, double> get _categoryTotals {
    final totals = <String, double>{};
    for (final item in _items) {
      totals.update(
        item.category,
        (value) => value + item.amount,
        ifAbsent: () => item.amount,
      );
    }
    return totals;
  }

  int _selectedTabIndex = 0;

  Color _accountColor(BuildContext context) {
    return _selectedAccount == ExpenseAccountType.business
        ? Colors.blue
        : Colors.orange;
  }

  @override
  void initState() {
    super.initState();
    _loadAccountSettings();
    _loadItems();
  }

  @override
  void dispose() {
    _offlineBillOcrService.dispose();
    super.dispose();
  }

  List<PurchaseItem> _sortItemsByDate(List<PurchaseItem> items) {
    final sorted = List<PurchaseItem>.from(items)
      ..sort((a, b) {
        final byDate = b.date.compareTo(a.date);
        if (byDate != 0) {
          return byDate;
        }
        return (b.id ?? 0).compareTo(a.id ?? 0);
      });
    return sorted;
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
    });
    final items = await _repository.fetchPurchases(_selectedAccount);
    if (!mounted) {
      return;
    }
    setState(() {
      _items = _sortItemsByDate(items);
      _isLoading = false;
    });
  }

  Future<void> _loadAccountSettings() async {
    final settings = await _repository.fetchAccountSettings();
    if (!mounted) {
      return;
    }
    setState(() {
      _accountSettings = settings;
    });
  }

  Future<void> _exportPdf() async {
    final l10n = AppLocalizations.of(context)!;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.addBeforeExport)));
      return;
    }

    await _pdfExporter.exportPurchases(
      account: _selectedAccount,
      items: _items,
      localizations: l10n,
      accountSettings: _accountSettings[_selectedAccount],
    );
  }

  Future<void> _openAccountSettingsSheet() async {
    final l10n = AppLocalizations.of(context)!;

    final wasSaved = await showModalBottomSheet<bool>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return AccountSettingsSheet(
          initialSettings: _accountSettings,
          selectedAccount: _selectedAccount,
          onSave: _saveAccountSettings,
        );
      },
    );

    if (wasSaved == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.accountSettingsSavedMessage)));
    }
  }

  Future<void> _saveAccountSettings(
    Map<ExpenseAccountType, AccountSettings> settings,
  ) async {
    await _repository.saveAccountSettings(
      settings[ExpenseAccountType.personal]!,
    );
    await _repository.saveAccountSettings(
      settings[ExpenseAccountType.business]!,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _accountSettings = settings;
    });
  }

  Future<void> _openAddItemSheet({PurchaseItem? item}) async {
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
          selectedAccount: _selectedAccount,
          item: item,
          ocrService: _offlineBillOcrService,
          dateFormat: _dateFormat,
          currencyFormat: _currencyFormat,
        );
      },
    );

    if (draft == null) {
      return;
    }

    if (item == null) {
      final savedItem = await _repository.insertPurchase(draft);
      if (!mounted) {
        return;
      }
      setState(() {
        _items = _sortItemsByDate([savedItem, ..._items]);
      });
      return;
    }

    await _repository.updatePurchase(draft);
    if (!mounted) {
      return;
    }
    setState(() {
      final index = _items.indexWhere((existing) => existing.id == draft.id);
      if (index != -1) {
        _items = _sortItemsByDate(List.from(_items)..[index] = draft);
      }
    });
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
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
              l10n.emptyStateTitle,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            Text(
              l10n.emptyStateSubtitle(
                l10n.accountLabelInSentence(_selectedAccount),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: ListTile(
          leading: const Icon(Icons.summarize),
          title: Text(l10n.deductibleTotalLabel),
          subtitle: Text(l10n.itemsTracked(_items.length)),
          trailing: Text(
            _currencyFormat.format(_deductibleAmount),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
    );
  }

  List<_MonthSection> _groupItemsByMonth() {
    final sections = <_MonthSection>[];
    for (final item in _items) {
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

  Widget _buildExpenseCard(PurchaseItem item, AppLocalizations l10n) {
    return PurchaseExpenseCard(
      item: item,
      localizations: l10n,
      dateFormat: _dateFormat,
      currencyFormat: _currencyFormat,
      onTap: () async {
        final action = await Navigator.push<PurchaseDetailAction>(
          context,
          MaterialPageRoute(
            builder: (context) => PurchaseDetailPage(item: item),
          ),
        );
        if (!mounted) {
          return;
        }
        if (action == PurchaseDetailAction.edit) {
          _openAddItemSheet(item: item);
        }
        if (action == PurchaseDetailAction.delete && item.id != null) {
          await _repository.deletePurchase(item.id!);
          if (!mounted) {
            return;
          }
          setState(() {
            _items = _items
                .where((existing) => existing.id != item.id)
                .toList();
          });
        }
      },
    );
  }

  Widget _buildDashboard(AppLocalizations l10n) {
    if (_items.isEmpty) {
      return _buildEmptyState(l10n);
    }

    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    final categoryTotals = _categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCategories = categoryTotals.take(5).toList();

    return ListView(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 96 + bottomInset),
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            DashboardMetricCard(
              title: l10n.totalAmountLabel,
              value: _currencyFormat.format(_totalAmount),
              icon: Icons.account_balance_wallet,
            ),
            DashboardMetricCard(
              title: l10n.deductibleTotalLabel,
              value: _currencyFormat.format(_deductibleAmount),
              icon: Icons.check_circle,
            ),
            DashboardMetricCard(
              title: l10n.nonDeductibleTotalLabel,
              value: _currencyFormat.format(_nonDeductibleAmount),
              icon: Icons.remove_circle_outline,
            ),
            DashboardMetricCard(
              title: l10n.averageExpenseLabel,
              value: _currencyFormat.format(_totalAmount / _items.length),
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
                    l10n.topCategoriesLabel,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  ...topCategories.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        spacing: 8,
                        children: [
                          Expanded(child: Text(entry.key)),
                          Text(_currencyFormat.format(entry.value)),
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
    );
  }

  Widget _buildExpensesTab(AppLocalizations l10n) {
    if (_items.isEmpty) {
      return _buildEmptyState(l10n);
    }

    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    final monthFormat = DateFormat.yMMMM(
      Localizations.localeOf(context).toString(),
    );
    final sections = _groupItemsByMonth();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildSummary(l10n)),
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
                      child: _buildExpenseCard(item, l10n),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.taxRefundPurchasesTitle),
        actions: [
          IconButton(
            tooltip: l10n.accountSettingsTitle,
            onPressed: _openAccountSettingsSheet,
            icon: const Icon(Icons.settings_outlined),
          ),
          IconButton(
            tooltip: l10n.exportPdfTooltip,
            onPressed: _exportPdf,
            icon: const Icon(Icons.picture_as_pdf),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(88),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _accountColor(context).withValues(alpha: 0.18),
                    _accountColor(context).withValues(alpha: 0.06),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _accountColor(context).withValues(alpha: 0.35),
                ),
              ),
              child: DropdownButtonFormField<ExpenseAccountType>(
                initialValue: _selectedAccount,
                decoration: InputDecoration(
                  labelText: l10n.expenseAccountLabel,
                  prefixIcon: Icon(
                    _selectedAccount == ExpenseAccountType.business
                        ? Icons.business
                        : Icons.person,
                    color: _accountColor(context),
                  ),
                ),
                items: ExpenseAccountType.values
                    .map(
                      (account) => DropdownMenuItem(
                        value: account,
                        child: Text(l10n.accountLabel(account)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _selectedAccount = value;
                  });
                  _loadItems();
                },
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _selectedTabIndex == 0
              ? _buildExpensesTab(l10n)
              : _buildDashboard(l10n),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTabIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedTabIndex = index;
          });
        },
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
        onPressed: () => _openAddItemSheet(),
        backgroundColor: _accountColor(context),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(l10n.addPurchase),
      ),
    );
  }
}

class _MonthSection {
  _MonthSection({required this.month, required this.items});

  final DateTime month;
  final List<PurchaseItem> items;
}
