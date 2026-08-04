import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:twigamoney/core/data/hive_database.dart';
import 'package:twigamoney/core/widgets/empty_state_widget.dart';
import 'package:twigamoney/l10n/app_localizations.dart';
import 'package:twigamoney/core/widgets/page_transitions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/entities/budget.dart';
import '../../presentation/bloc/finance_bloc.dart';

class BudgetListPage extends StatefulWidget {
  const BudgetListPage({super.key});

  @override
  State<BudgetListPage> createState() => _BudgetListPageState();
}

class _BudgetListPageState extends State<BudgetListPage> {
  String _searchQuery = '';
  String _selectedPeriod = 'All';

  @override
  void initState() {
    super.initState();
    context.read<FinanceBloc>().add(LoadBudgetsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.getPadding(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        leading: const BackButtonWidget(),
        title: Text(l10n.budgets, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/budgets/add'),
            tooltip: l10n.addBudget,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportBudgets,
            tooltip: l10n.exportBudgets,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: padding, vertical: 16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: l10n.searchBudgets,
                        prefixIcon: const Icon(Icons.search),
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          l10n.all,
                          l10n.weekly,
                          l10n.monthly,
                          l10n.yearly,
                        ].map((period) {
                          final periodStr = period.toString();
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(periodStr),
                              selected: _selectedPeriod == periodStr,
                              onSelected: (_) => setState(() => _selectedPeriod = periodStr),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<FinanceBloc, FinanceState>(
              builder: (context, state) {
                if (state is FinanceLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allBudgets = state is BudgetsLoaded ? state.budgets : [];
                final filteredBudgets = allBudgets.where((b) {
                  final matchesSearch = b.name.toLowerCase().contains(_searchQuery);
                  final matchesPeriod = _selectedPeriod == 'All' || b.period.name.toLowerCase() == _selectedPeriod.toLowerCase();
                  return matchesSearch && matchesPeriod;
                }).toList();
                final categoryBox = HiveDatabase.categoryBox;

                if (filteredBudgets.isEmpty) {
                  return EmptyStateWidget(
                    icon: _searchQuery.isNotEmpty ? Icons.search_off : Icons.savings_outlined,
                    title: _searchQuery.isNotEmpty ? l10n.noBudgetsMatchSearch : l10n.noBudgetsYet,
                    subtitle: _searchQuery.isNotEmpty ? null : l10n.tapToCreateBudget,
                    onActionPressed: _searchQuery.isNotEmpty 
                      ? () => setState(() => _searchQuery = '')
                      : () => context.push('/budgets/add'),
                    actionLabel: _searchQuery.isNotEmpty ? l10n.clearSearch : l10n.addBudget,
                  );
                }

                final totalBudgeted = filteredBudgets.fold(0.0, (sum, b) => sum + b.amount);
                final totalSpent = filteredBudgets.fold(0.0, (sum, b) => sum + b.spent);

                return ListView(
                  padding: EdgeInsets.fromLTRB(padding, 8, padding, padding + 16),
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Row(
                          children: [
                            Expanded(child: _buildSummaryCard(l10n.totalBudgeted, totalBudgeted)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildSummaryCard(l10n.totalSpent, totalSpent)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...filteredBudgets.map((budget) {
                      final category = categoryBox.get(budget.categoryId);
                      final spentPercentage = (budget.spent / budget.amount).clamp(0.0, 1.0);

                      return Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: Responsive.getCardElevation(context),
                            child: InkWell(
                              onTap: () => context.push('/budgets/edit/${budget.id}', extra: budget),
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: (category?.color ?? Colors.red).withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            category?.icon ?? Icons.category,
                                            color: category?.color ?? Colors.red,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                               Text(
                                                 budget.name,
                                                 style: const TextStyle(
                                                   fontSize: 16,
                                                   fontWeight: FontWeight.bold,
                                                 ),
                                                 maxLines: 1,
                                                 overflow: TextOverflow.ellipsis,
                                               ),
                                              Text(
                                                '${_formatPeriod(budget.period)} - ${category?.name ?? l10n.allCategories}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        PopupMenuButton<String>(
                                          onSelected: (value) {
                                            if (value == 'edit') {
                                              context.push('/budgets/edit/${budget.id}', extra: budget);
                                            } else if (value == 'delete') {
                                              _confirmDelete(context, budget);
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            PopupMenuItem(
                                              value: 'edit',
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.edit, size: 20),
                                                  const SizedBox(width: 8),
                                                  Text(l10n.edit),
                                                ],
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.delete, size: 20, color: Colors.red),
                                                  const SizedBox(width: 8),
                                                  Text(l10n.delete, style: const TextStyle(color: Colors.red)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: LinearProgressIndicator(
                                        value: spentPercentage,
                                        backgroundColor: Colors.grey[300],
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          budget.isOverBudget ? Colors.red : Colors.blue,
                                        ),
                                        minHeight: 8,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${(spentPercentage * 100).toStringAsFixed(0)}% ${l10n.used}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: budget.isOverBudget ? Colors.red : Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          '${budget.spent.toStringAsFixed(0)} / ${budget.amount.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, double amount) {
    final symbol = AppTheme.getCurrencySymbol(Hive.box('settings').get('selectedCurrency', defaultValue: 'TZS'));
    return Card(
      elevation: Responsive.getCardElevation(context),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('$symbol${amount.toStringAsFixed(0)}', 
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportBudgets() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final state = context.read<FinanceBloc>().state;
      final allBudgets = state is BudgetsLoaded ? state.budgets : HiveDatabase.budgetBox.values.toList();

      if (allBudgets.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.noBudgetsToExport)),
        );
        return;
      }

      final categoryBox = HiveDatabase.categoryBox;

      List<List<dynamic>> rows = [];
      rows.add([l10n.budgetName, l10n.category, l10n.budgetPeriod, l10n.budgetAmount, l10n.totalSpent, l10n.startDate, l10n.endDate]);

      for (var budget in allBudgets) {
        final category = categoryBox.get(budget.categoryId);
        rows.add([
          budget.name,
          category?.name ?? l10n.unknown,
          budget.period.name,
          budget.amount,
          budget.spent,
          AppTheme.getDateFormat().format(budget.startDate),
          budget.endDate != null ? AppTheme.getDateFormat().format(budget.endDate!) : 'N/A',
        ]);
      }

      String csvData = const ListToCsvConverter().convert(rows);
      final directory = await getTemporaryDirectory();
      final path = "${directory.path}/budgets_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv";
      final file = File(path);
      await file.writeAsString(csvData);

      await Share.shareXFiles([XFile(path)], text: l10n.budgetExport);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.exportFailed(e.toString())), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _confirmDelete(BuildContext context, Budget budget) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteBudget),
        content: Text(l10n.confirmDeleteBudget(budget.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<FinanceBloc>().add(DeleteBudgetEvent(budget.id));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.budgetDeletedSuccessfully),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatPeriod(BudgetPeriod period) {
    final l10n = AppLocalizations.of(context)!;
    switch (period) {
      case BudgetPeriod.weekly:
        return l10n.weekly;
      case BudgetPeriod.monthly:
        return l10n.monthly;
      case BudgetPeriod.yearly:
        return l10n.yearly;
      case BudgetPeriod.custom:
        return l10n.custom;
    }
  }
}
