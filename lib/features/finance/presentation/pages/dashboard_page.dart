import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:twigamoney/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/data/hive_database.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/category.dart';
import '../../presentation/bloc/finance_bloc.dart';
import '../../presentation/bloc/transaction_bloc.dart';
import '../../presentation/bloc/account_cubit.dart';
import '../../presentation/bloc/budget_cubit.dart';
import '../../presentation/bloc/report_cubit.dart';
import '../../domain/usecases/comprehensive_report_usecase.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DateFormat _dateFormat = AppTheme.getDateFormat();
  late final DateTime _now;
  late final DateTime _monthStart;
  late final DateTime _monthEnd;
  ReportPeriod _selectedReportPeriod = ReportPeriod.monthly;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _monthStart = DateTime(_now.year, _now.month, 1);
    _monthEnd = DateTime(_now.year, _now.month + 1, 1);
    
    // Trigger data loading through Blocs/Cubit
    context.read<FinanceBloc>().add(LoadCategoriesEvent());
    context.read<AccountCubit>().loadAccounts();
    context.read<BudgetCubit>().loadBudgets();
    context.read<TransactionBloc>().add(LoadTransactionsEvent());
    _loadProjections();
  }

  void _loadProjections() {
    context.read<ReportCubit>().loadReportByPeriod(_selectedReportPeriod);
  }

  void _onReportPeriodChanged(ReportPeriod period) {
    setState(() {
      _selectedReportPeriod = period;
    });
    _loadProjections();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsBox = HiveDatabase.settingsBox;
    final currency = settingsBox.get('selectedCurrency', defaultValue: 'TZS') as String;
    final symbol = AppTheme.getCurrencySymbol(currency);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName, style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: BlocBuilder<ReportCubit, ReportState>(
        builder: (context, reportState) {
          return BlocBuilder<FinanceBloc, FinanceState>(
            builder: (context, financeState) {
              return BlocBuilder<AccountCubit, AccountState>(
                builder: (context, accountState) {
                  return BlocBuilder<BudgetCubit, BudgetState>(
                    builder: (context, budgetState) {
                      return BlocBuilder<TransactionBloc, TransactionState>(
                        builder: (context, transactionState) {
                          if (accountState.isLoading || budgetState.isLoading || transactionState.isLoading) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          // Data Preparation
                          final accounts = accountState.accounts;
                          final totalBalance = accounts.fold<double>(0.0, (sum, acc) => sum + acc.balance);

                          final allTransactions = transactionState.transactions;
                          final thisMonthTransactions = allTransactions
                              .where((t) => !t.date.isBefore(_monthStart) && t.date.isBefore(_monthEnd))
                              .toList();
                          
                          final totalIncome = thisMonthTransactions
                              .where((t) => t.type == TransactionType.income)
                              .fold<double>(0.0, (sum, t) => sum + t.amount);
                          final totalExpenses = thisMonthTransactions
                              .where((t) => t.type == TransactionType.expense)
                              .fold<double>(0.0, (sum, t) => sum + t.amount);
                          final netSavings = totalIncome - totalExpenses;

                          final BusinessReport? report = reportState is ReportLoaded && reportState.report is BusinessReport 
                              ? reportState.report as BusinessReport 
                              : null;

                          final recentTransactions = [...allTransactions]..sort((a, b) => b.date.compareTo(a.date));
                      final last5 = recentTransactions.take(5).toList();

                      final categories = financeState is CategoriesLoaded ? financeState.categories : <Category>[];
                      final categoryMap = {for (final c in categories) c.id: c};

                      final budgets = budgetState.budgets;
                      final alertBudgets = budgets
                          .where((b) => b.amount > 0 && (b.spent / b.amount) > 0.8)
                          .toList();

                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<FinanceBloc>().add(LoadCategoriesEvent());
                          context.read<AccountCubit>().loadAccounts();
                          context.read<BudgetCubit>().loadBudgets();
                          context.read<TransactionBloc>().add(LoadTransactionsEvent());
                          _loadProjections();
                        },
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.account_balance_wallet, color: Theme.of(context).colorScheme.primary, size: 28),
                                  const SizedBox(width: 12),
                                  Text(
                                    l10n.appName,
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: _buildReportPeriodSelector(context, l10n),
                              ),
                              const SizedBox(height: 16),

                              if (report != null) ...[
                                _buildMonthlyOutlook(context, report, totalBalance, symbol, l10n),
                                const SizedBox(height: 20),
                              ],

                              Card(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(l10n.totalBalance, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
                                      const SizedBox(height: 8),
                                      Text(
                                        '$symbol${totalBalance.toStringAsFixed(2)}',
                                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              LayoutBuilder(
                                builder: (context, constraints) {
                                  if (constraints.maxWidth < 360) {
                                    return Column(
                                      children: [
                                        _buildStatCard(context, l10n.totalIncome, '$symbol${totalIncome.toStringAsFixed(2)}', Icons.arrow_upward, Colors.green),
                                        const SizedBox(height: 12),
                                        _buildStatCard(context, l10n.totalExpenses, '$symbol${totalExpenses.toStringAsFixed(2)}', Icons.arrow_downward, Colors.red),
                                        const SizedBox(height: 12),
                                        _buildStatCard(context, l10n.netSavings, '$symbol${netSavings.toStringAsFixed(2)}', Icons.savings, Colors.blue),
                                      ],
                                    );
                                  }
                                  return Row(
                                    children: [
                                      Expanded(child: _buildStatCard(context, l10n.totalIncome, '$symbol${totalIncome.toStringAsFixed(2)}', Icons.arrow_upward, Colors.green)),
                                      const SizedBox(width: 12),
                                      Expanded(child: _buildStatCard(context, l10n.totalExpenses, '$symbol${totalExpenses.toStringAsFixed(2)}', Icons.arrow_downward, Colors.red)),
                                      const SizedBox(width: 12),
                                      Expanded(child: _buildStatCard(context, l10n.netSavings, '$symbol${netSavings.toStringAsFixed(2)}', Icons.savings, Colors.blue)),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 24),

                              Text(l10n.recentTransactions, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              if (last5.isEmpty)
                                Card(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Center(child: Text(l10n.noTransactionsYet, style: TextStyle(color: Colors.grey[600]))),
                                  ),
                                )
                              else
                                Column(
                                  children: last5.map((tx) {
                                    final category = categoryMap[tx.categoryId] ??
                                        Category(id: '', name: l10n.unknown, colorValue: 0xFF9E9E9E, iconName: 'other');
                                    return Card(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      margin: const EdgeInsets.only(bottom: 12),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: category.color.withValues(alpha: 0.1),
                                          child: Icon(category.icon, color: category.color, size: 20),
                                        ),
                                        title: Text(tx.description, style: const TextStyle(fontWeight: FontWeight.w500)),
                                        subtitle: Text(_dateFormat.format(tx.date)),
                                        trailing: Text(
                                          '${tx.type == TransactionType.income ? '+' : '-'}$symbol${tx.amount.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: tx.type == TransactionType.income ? Colors.green : Colors.red,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              const SizedBox(height: 24),

                              if (alertBudgets.isNotEmpty) ...[
                                Text(l10n.budgetAlerts, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 12),
                                Column(
                                  children: alertBudgets.map((budget) {
                                    final category = categoryMap[budget.categoryId] ??
                                        Category(id: '', name: l10n.unknown, colorValue: 0xFF9E9E9E, iconName: 'other');
                                    final spentPercentage = (budget.spent / budget.amount * 100).toStringAsFixed(0);
                                    return Card(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      margin: const EdgeInsets.only(bottom: 12),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.warning_amber, color: Colors.orange, size: 24),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(budget.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                                  Text('${category.name} • ${l10n.percentSpent(spentPercentage)}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                                ],
                                              ),
                                            ),
                                            Text('$symbol${budget.spent.toStringAsFixed(2)} / $symbol${budget.amount.toStringAsFixed(2)}',
                                              style: const TextStyle(fontWeight: FontWeight.w500)),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      );
    },
  ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-transaction'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildReportPeriodSelector(BuildContext context, AppLocalizations l10n) {
    final periods = ReportPeriod.values;
    final labels = [
      l10n.dailyReport,
      l10n.weeklyReport,
      l10n.biweeklyReport,
      l10n.monthlyReport,
      l10n.yearlyReport,
    ];
    return Row(
      children: [
        for (int i = 0; i < periods.length; i++)
          Padding(
            padding: EdgeInsets.only(right: i < periods.length - 1 ? 8 : 0),
            child: ChoiceChip(
              label: Text(labels[i]),
              selected: _selectedReportPeriod == periods[i],
              onSelected: (_) => _onReportPeriodChanged(periods[i]),
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              selectedColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(
                color: _selectedReportPeriod == periods[i]
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: _selectedReportPeriod == periods[i]
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyOutlook(BuildContext context, BusinessReport report, double currentBalance, String symbol, AppLocalizations l10n) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final remainingDays = daysInMonth - now.day;
    
    // Simple projection: Current Balance + (Daily Profit Projection * remaining days)
    // We'll use the projectedProfit from report which is currently for 30 days.
    final dailyProjectedProfit = report.projectedProfit / 30;
    final projectedMonthEndBalance = currentBalance + (dailyProjectedProfit * remainingDays);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.monthlyOutlook,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w500),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l10n.predictive,
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.estMonthEndBalance,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$symbol${projectedMonthEndBalance.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Icon(
                dailyProjectedProfit >= 0 ? Icons.trending_up : Icons.trending_down,
                color: dailyProjectedProfit >= 0 ? Colors.greenAccent : Colors.redAccent,
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
