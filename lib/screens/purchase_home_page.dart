import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/purchase_repository.dart';
import '../gen/app_localizations.dart';
import '../localization/app_localizations_ext.dart';
import '../models/expense_account_type.dart';
import '../models/purchase_item.dart';
import '../screens/purchase_detail_page.dart';
import '../services/pdf_exporter.dart';
import '../widgets/info_chip.dart';

class PurchaseHomePage extends StatefulWidget {
  const PurchaseHomePage({super.key});

  @override
  State<PurchaseHomePage> createState() => _PurchaseHomePageState();
}

class _PurchaseHomePageState extends State<PurchaseHomePage> {
  final PurchaseRepository _repository = PurchaseRepository();
  final PdfExporter _pdfExporter = PdfExporter();
  final DateFormat _dateFormat = DateFormat('dd.MM.yyyy');
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'de_AT',
    symbol: '€',
  );

  ExpenseAccountType _selectedAccount = ExpenseAccountType.business;
  List<PurchaseItem> _items = [];
  bool _isLoading = true;

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
    _loadItems();
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
      _items = items;
      _isLoading = false;
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
    );
  }

  void _openAddItemSheet({PurchaseItem? item}) {
    final l10n = AppLocalizations.of(context)!;
    final formKey = GlobalKey<FormState>();
    final descriptionController = TextEditingController(
      text: item?.description ?? '',
    );
    final vendorController = TextEditingController(text: item?.vendor ?? '');
    final amountController = TextEditingController(
      text: item != null ? item.amount.toStringAsFixed(2) : '',
    );
    final notesController = TextEditingController(text: item?.notes ?? '');
    final categories = l10n.categoriesForAccount(_selectedAccount);

    DateTime selectedDate = item?.date ?? DateTime.now();
    String selectedCategory = item?.category ?? categories.first;
    if (!categories.contains(selectedCategory)) {
      selectedCategory = categories.first;
    }
    bool isDeductible = item?.isDeductible ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 8,
      builder: (context) {
        Future<void> submitForm() async {
          final navigator = Navigator.of(context);
          if (!formKey.currentState!.validate()) {
            return;
          }
          final parsedAmount = double.parse(
            amountController.text.replaceAll(',', '.'),
          );
          final updatedItem = PurchaseItem(
            id: item?.id,
            accountType: _selectedAccount,
            description: descriptionController.text.trim(),
            vendor: vendorController.text.trim(),
            category: selectedCategory,
            amount: parsedAmount,
            date: selectedDate,
            isDeductible: isDeductible,
            notes: notesController.text.trim(),
          );
          if (item == null) {
            final savedItem = await _repository.insertPurchase(updatedItem);
            if (!mounted) {
              return;
            }
            setState(() {
              _items = [savedItem, ..._items];
            });
          } else {
            await _repository.updatePurchase(updatedItem);
            if (!mounted) {
              return;
            }
            setState(() {
              final index = _items.indexWhere(
                (existing) => existing.id == updatedItem.id,
              );
              if (index != -1) {
                _items = List.from(_items)..[index] = updatedItem;
              }
            });
          }
          navigator.pop();
        }

        return SafeArea(
          child: AnimatedPadding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              left: 16,
              right: 16,
              top: 16,
            ),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: StatefulBuilder(
              builder: (context, setModalState) {
                return Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 12,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(l10n.cancelAction),
                            ),
                            FilledButton.icon(
                              onPressed: submitForm,
                              icon: Icon(item == null ? Icons.add : Icons.save),
                              label: Text(
                                item == null
                                    ? l10n.addPurchase
                                    : l10n.savePurchaseAction,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _accountColor(
                              context,
                            ).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _accountColor(
                                context,
                              ).withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 8,
                            children: [
                              Icon(
                                _selectedAccount == ExpenseAccountType.business
                                    ? Icons.business
                                    : Icons.person,
                                color: _accountColor(context),
                              ),
                              Text(
                                l10n.accountLabel(_selectedAccount),
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      color: _accountColor(context),
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            item == null
                                ? l10n.addPurchaseTitle
                                : l10n.editPurchaseTitle,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                        TextFormField(
                          controller: descriptionController,
                          decoration: InputDecoration(
                            labelText: l10n.descriptionLabel,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.descriptionValidation;
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: vendorController,
                          decoration: InputDecoration(
                            labelText: l10n.vendorLabel,
                          ),
                        ),
                        TextFormField(
                          controller: amountController,
                          decoration: InputDecoration(
                            labelText: l10n.amountLabel,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.amountValidation;
                            }
                            final parsed = double.tryParse(
                              value.replaceAll(',', '.'),
                            );
                            if (parsed == null || parsed <= 0) {
                              return l10n.amountInvalidValidation;
                            }
                            return null;
                          },
                        ),
                        DropdownButtonFormField<String>(
                          initialValue: selectedCategory,
                          decoration: InputDecoration(
                            labelText: l10n.categoryLabel,
                          ),
                          items: categories
                              .map(
                                (category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }
                            setModalState(() {
                              selectedCategory = value;
                            });
                          },
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(l10n.dateOfPurchaseLabel),
                          subtitle: Text(_dateFormat.format(selectedDate)),
                          trailing: TextButton.icon(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime(2015),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setModalState(() {
                                  selectedDate = picked;
                                });
                              }
                            },
                            icon: const Icon(Icons.calendar_today),
                            label: Text(l10n.pickDate),
                          ),
                        ),
                        SwitchListTile(
                          title: Text(l10n.vatDeductibleLabel),
                          value: isDeductible,
                          onChanged: (value) {
                            setModalState(() {
                              isDeductible = value;
                            });
                          },
                        ),
                        TextFormField(
                          controller: notesController,
                          decoration: InputDecoration(
                            labelText: l10n.notesLabel,
                          ),
                          maxLines: 3,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 12),
                          child: FilledButton.icon(
                            onPressed: submitForm,
                            icon: Icon(item == null ? Icons.add : Icons.save),
                            label: Text(
                              item == null
                                  ? l10n.addPurchase
                                  : l10n.savePurchaseAction,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
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
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Text(
                item.description,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '${item.vendor.isEmpty ? l10n.unknownVendor : item.vendor} • ${item.category}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 4,
                  children: [
                    InfoChip(
                      icon: Icons.calendar_today,
                      label: _dateFormat.format(item.date),
                    ),
                    InfoChip(
                      icon: Icons.euro,
                      label: _currencyFormat.format(item.amount),
                    ),
                    InfoChip(
                      icon: item.isDeductible
                          ? Icons.check_circle
                          : Icons.info_outline,
                      label: item.isDeductible
                          ? l10n.deductibleLabel
                          : l10n.notDeductibleLabel,
                    ),
                  ],
                ),
              ),
              if (item.notes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    item.notes,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
            ],
          ),
        ),
      ),
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
            _DashboardMetricCard(
              title: l10n.totalAmountLabel,
              value: _currencyFormat.format(_totalAmount),
              icon: Icons.account_balance_wallet,
            ),
            _DashboardMetricCard(
              title: l10n.deductibleTotalLabel,
              value: _currencyFormat.format(_deductibleAmount),
              icon: Icons.check_circle,
            ),
            _DashboardMetricCard(
              title: l10n.nonDeductibleTotalLabel,
              value: _currencyFormat.format(_nonDeductibleAmount),
              icon: Icons.remove_circle_outline,
            ),
            _DashboardMetricCard(
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
        ) ...[
          SliverPersistentHeader(
            pinned: true,
            delegate: _MonthHeaderDelegate(
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

class _DashboardMetricCard extends StatelessWidget {
  const _DashboardMetricCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Text(value, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthSection {
  _MonthSection({required this.month, required this.items});

  final DateTime month;
  final List<PurchaseItem> items;
}

class _MonthHeaderDelegate extends SliverPersistentHeaderDelegate {
  _MonthHeaderDelegate({required this.title});

  final String title;

  @override
  double get minExtent => 36;

  @override
  double get maxExtent => 36;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      alignment: Alignment.centerLeft,
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _MonthHeaderDelegate oldDelegate) {
    return oldDelegate.title != title;
  }
}
