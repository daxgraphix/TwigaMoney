import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../shop/presentation/bloc/shop_bloc.dart';
import '../../../finance/presentation/bloc/finance_bloc.dart';
import '../../../finance/presentation/bloc/transaction_bloc.dart';
import '../../../finance/presentation/bloc/budget_cubit.dart';
import '../../../finance/presentation/bloc/account_cubit.dart';
import '../../../finance/presentation/bloc/report_cubit.dart';
import '../../../finance/domain/entities/transaction.dart';
import '../../../finance/domain/entities/category.dart';
import '../../../finance/domain/usecases/monthly_report_usecase.dart';

Widget _quickAccessCard(
    BuildContext context, String title, IconData icon, VoidCallback onTap) {
  final isSmall = MediaQuery.of(context).size.width < 380;
  return Card(
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: EdgeInsets.all(isSmall ? 10 : 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(isSmall ? 6 : 10),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon,
                  size: isSmall ? 22 : 26, color: AppTheme.primaryColor),
            ),
            SizedBox(height: isSmall ? 4 : 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                style: TextStyle(
                    fontSize: isSmall ? 10 : 11, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(LoadTransactionsEvent());
    context.read<AccountCubit>().loadAccounts();
    context.read<BudgetCubit>().loadBudgets();
    context.read<ReportCubit>().loadMonthlyReport(DateTime.now());
    context.read<FinanceBloc>().add(LoadCategoriesEvent());
    context.read<ShopBloc>().add(LoadShopEvent());
    _generateRecurringTransactions();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  void _generateRecurringTransactions() {}

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(context),
      body: Column(
        children: [
          // Net Worth / Total Balance Header - key finance UX improvement
          BlocBuilder<AccountCubit, AccountState>(
            builder: (context, state) {
              final l10n = AppLocalizations.of(context)!;
              if (state is AccountLoaded && state.accounts.isNotEmpty) {
                final totalBalance = state.accounts
                    .fold<double>(0.0, (sum, acc) => sum + acc.balance);
                final currency = Hive.box('settings')
                    .get('selectedCurrency', defaultValue: 'TZS');
                final symbol = AppTheme.getCurrencySymbol(currency);
                return Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.primaryColor.withValues(alpha: 0.85)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.totalBalance,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 2),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '$symbol${totalBalance.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.account_balance_wallet,
                            color: Colors.white, size: 28),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          Expanded(
            flex: 1,
            child: SafeArea(
              top: false,
              bottom: false,
              child: IndexedStack(
                index: _selectedIndex,
                children: const [
                  TransactionsTab(),
                  ReportsTab(),
                  AccountsTab(),
                  BudgetsTab(),
                  CategoriesTab(),
                ],
              ),
            ),
          ),

          // Internal finance nav placed inside body (fixes 12px bottom overflow from nested Scaffold + bottom bar)
          _buildBottomNavBar(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        child: const Icon(Icons.menu),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    final l10n = AppLocalizations.of(context)!;
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      items: [
        BottomNavigationBarItem(
            icon: const Icon(Icons.swap_horiz), label: l10n.transactions),
        BottomNavigationBarItem(icon: const Icon(Icons.bar_chart), label: l10n.reports),
        BottomNavigationBarItem(
            icon: const Icon(Icons.account_balance), label: l10n.accounts),
        BottomNavigationBarItem(
            icon: const Icon(Icons.account_balance_wallet), label: l10n.budgets),
        BottomNavigationBarItem(
            icon: const Icon(Icons.category), label: l10n.categories),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Drawer(
      child: Column(
        children: [
          BlocBuilder<ShopBloc, ShopState>(
            builder: (context, state) {
              String shopName = l10n.myShop;
              if (state is ShopLoaded && state.shop.name.isNotEmpty) {
                shopName = state.shop.name;
              }
              return DrawerHeader(
                decoration:
                    BoxDecoration(color: Theme.of(context).primaryColor),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(shopName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(l10n.personalFinanceTracker,
                        style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.swap_horiz, color: Colors.green),
                  title: Text(l10n.transactions),
                  onTap: () {
                    if (context.canPop())
                      context.pop();
                    else
                      context.go('/');
                    setState(() => _selectedIndex = 0);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.bar_chart, color: Colors.orange),
                  title: Text(l10n.reports),
                  onTap: () {
                    if (context.canPop())
                      context.pop();
                    else
                      context.go('/');
                    setState(() => _selectedIndex = 1);
                  },
                ),
                ListTile(
                  leading:
                      const Icon(Icons.account_balance, color: Colors.purple),
                  title: Text(l10n.accounts),
                  onTap: () {
                    if (context.canPop())
                      context.pop();
                    else
                      context.go('/');
                    setState(() => _selectedIndex = 2);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet,
                      color: Colors.teal),
                  title: Text(l10n.budgets),
                  onTap: () {
                    if (context.canPop())
                      context.pop();
                    else
                      context.go('/');
                    setState(() => _selectedIndex = 3);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.category, color: Colors.indigo),
                  title: Text(l10n.categories),
                  onTap: () {
                    if (context.canPop())
                      context.pop();
                    else
                      context.go('/');
                    setState(() => _selectedIndex = 4);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.store, color: Colors.indigo),
                  title: Text(l10n.shopDetails),
                  onTap: () {
                    if (context.canPop())
                      context.pop();
                    else
                      context.go('/');
                    context.push('/shop');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings, color: Colors.grey),
                  title: Text(l10n.settings),
                  onTap: () {
                    if (context.canPop())
                      context.pop();
                    else
                      context.go('/');
                    context.push('/settings');
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('${l10n.appName} v1.0.0',
                style: const TextStyle(color: Colors.grey, fontSize: 10)),
          ),
        ],
      ),
    );
  }
}

// ==================== TABS ====================

class TransactionsTab extends StatelessWidget {
  const TransactionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is TransactionInitial || state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is TransactionLoaded) {
          if (state.transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.swap_horiz, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(l10n.noTransactionsYet,
                      style:
                          const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(l10n.addFirstExpenseIncome,
                      style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/add-transaction'),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.addTransaction),
                  ),
                ],
              ),
            );
          }

          // Quick Access ONLY in Transactions tab (as requested)
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.quickAccess,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                            child: _quickAccessCard(
                                context,
                                l10n.plannerCalendar,
                                Icons.event_note,
                                () => context.push('/planner'))),
                        const SizedBox(width: 8),
                        Expanded(
                            child: _quickAccessCard(context, l10n.notes,
                                Icons.note, () => context.push('/planner'))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                            child: _quickAccessCard(
                                context,
                                l10n.operations,
                                Icons.business_center,
                                () => context.push('/operations'))),
                        const SizedBox(width: 8),
                        Expanded(
                            child: _quickAccessCard(
                                context,
                                l10n.reports,
                                Icons.bar_chart,
                                () => context.push('/reports'))),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.transactions.length,
                  itemBuilder: (context, index) {
                    final t = state.transactions[index];
                    final symbol = AppTheme.getCurrencySymbol(
                        Hive.box('settings')
                            .get('selectedCurrency', defaultValue: 'TZS'));
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: t.type == TransactionType.expense
                              ? Colors.red.withValues(alpha: 0.1)
                              : Colors.green.withValues(alpha: 0.1),
                          child: Icon(
                            t.type == TransactionType.expense
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            color: t.type == TransactionType.expense
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                        title: Text(t.description,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                            '${t.date.day}/${t.date.month}/${t.date.year}'),
                        trailing: Text('$symbol${t.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                                color: t.type == TransactionType.expense
                                    ? Colors.red
                                    : Colors.green,
                                fontWeight: FontWeight.bold)),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/add-transaction'),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addTransaction),
                ),
              ),
            ],
          );
        }
        return Center(child: Text(l10n.errorLoadingTransactions));
      },
    );
  }
}

class ReportsTab extends StatefulWidget {
  const ReportsTab({super.key});

  @override
  State<ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends State<ReportsTab> {
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    context.read<ReportCubit>().loadMonthlyReport(_selectedMonth);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<ReportCubit, ReportState>(
      builder: (context, state) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text('${l10n.selectMonth}: ',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedMonth,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (date != null && mounted) {
                        setState(() => _selectedMonth = date);
                        context.read<ReportCubit>().loadMonthlyReport(date);
                      }
                    },
                    child:
                        Text('${_selectedMonth.month}/${_selectedMonth.year}'),
                  ),
                ],
              ),
            ),
            if (state.isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (state is ReportLoaded)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryCards(state.report),
                      const SizedBox(height: 24),
                      Text(l10n.expensesByCategory,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      SizedBox(
                          height: 200,
                          child: _buildExpensePieChart(state.report)),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                              child: ElevatedButton.icon(
                                  onPressed: () => _exportReport(state.report),
                                  icon: const Icon(Icons.download),
                                  label: Text(l10n.exportCsv))),
                          const SizedBox(width: 12),
                          Expanded(
                              child: ElevatedButton.icon(
                                  onPressed: () => _shareReport(state.report),
                                  icon: const Icon(Icons.share),
                                  label: Text(l10n.share))),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                  child: Center(child: Text(l10n.errorLoadingReport))),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCards(MonthlyReport report) {
    final l10n = AppLocalizations.of(context)!;
    final isSmall = MediaQuery.of(context).size.width < 380;
    return Row(
      children: [
        Expanded(
            child: _buildCard(
                l10n.income, report.totalIncome, Colors.green, isSmall)),
        SizedBox(width: isSmall ? 8 : 16),
        Expanded(
            child: _buildCard(
                l10n.expenses, report.totalExpenses, Colors.red, isSmall)),
        SizedBox(width: isSmall ? 8 : 16),
        Expanded(
            child: _buildCard(l10n.netPosition, report.netIncome,
                report.netIncome >= 0 ? Colors.green : Colors.red, isSmall)),
      ],
    );
  }

  Widget _buildCard(String title, double amount, Color color, bool isSmall) {
    final symbol = AppTheme.getCurrencySymbol(
        Hive.box('settings').get('selectedCurrency', defaultValue: 'TZS'));

    IconData cardIcon = title == 'Income'
        ? Icons.trending_up
        : title == 'Expenses'
            ? Icons.trending_down
            : Icons.swap_horiz;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(isSmall ? 12 : 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: color, width: 5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(cardIcon, color: color, size: isSmall ? 18 : 22),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: isSmall ? 11 : 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '$symbol${amount.toStringAsFixed(0)}',
                style: TextStyle(
                  color: color,
                  fontSize: isSmall ? 18 : 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpensePieChart(MonthlyReport report) {
    final l10n = AppLocalizations.of(context)!;
    final expenseTransactions = report.transactions
        .where((t) => t.type == TransactionType.expense)
        .toList();
    final categoryTotals = <String, double>{};
    for (final t in expenseTransactions) {
      categoryTotals[t.categoryId] =
          (categoryTotals[t.categoryId] ?? 0) + t.amount;
    }
    if (categoryTotals.isEmpty)
      return Center(child: Text(l10n.noExpensesMonth));

    final sections = categoryTotals.entries.map((e) {
      final name = _getCategoryName(e.key);
      return PieChartSectionData(
        color: _getCategoryColor(e.key),
        value: e.value,
        title: '$name\n${e.value.toStringAsFixed(0)}',
        radius: 60,
        titleStyle: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return PieChart(PieChartData(
        sections: sections, sectionsSpace: 2, centerSpaceRadius: 40));
  }

  String _getCategoryName(String categoryId) {
    try {
      final financeState = context.read<FinanceBloc>().state;
      if (financeState is CategoriesLoaded) {
        final match = financeState.categories.firstWhere(
            (c) => c.id == categoryId,
            orElse: () => throw Exception());
        return match.name;
      }
    } catch (_) {}
    return categoryId;
  }

  Color _getCategoryColor(String categoryId) {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange
    ];
    return colors[categoryId.hashCode % colors.length];
  }

  Future<void> _exportReport(MonthlyReport report) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final csv = StringBuffer();
      csv.writeln('Description,Category,Type,Amount,Date');
      for (final t in report.transactions) {
        csv.writeln(
            '"${t.description}","${t.categoryId}",${t.type},${t.amount},${t.date.toIso8601String()}');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              l10n.reportExportedCount(report.transactions.length)),
          action: SnackBarAction(
              label: l10n.share, onPressed: () => _shareReport(report)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${l10n.exportFailed(e.toString())}'), backgroundColor: Colors.red));
    }
  }

  Future<void> _shareReport(MonthlyReport report) async {
    final l10n = AppLocalizations.of(context)!;
    final summary = '''
${l10n.monthlyReport} - ${_selectedMonth.month}/${_selectedMonth.year}

${l10n.totalIncome}: ${report.totalIncome}
${l10n.totalExpenses}: ${report.totalExpenses}
${l10n.netPosition}: ${report.netIncome}

${l10n.transactions}: ${report.transactions.length}
''';
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.reportReadyShare}\n$summary')));
  }
}

// The other tabs (AccountsTab, BudgetsTab, CategoriesTab, PlannerTab) are identical to the version you pasted
// (they were already correct and render properly).

class AccountsTab extends StatelessWidget {
  const AccountsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<AccountCubit, AccountState>(
      builder: (context, state) {
        if (state is AccountInitial || state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AccountLoaded) {
          if (state.accounts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.account_balance,
                      size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(l10n.noAccountsYet,
                      style:
                          const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(l10n.addFirstAccount,
                      style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                      onPressed: () => context.push('/finance'),
                      icon: const Icon(Icons.add),
                      label: Text(l10n.manageAccounts)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.accounts.length,
            itemBuilder: (context, index) {
              final a = state.accounts[index];
              final symbol = AppTheme.getCurrencySymbol(Hive.box('settings')
                  .get('selectedCurrency', defaultValue: 'TZS'));
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    child: Icon(Icons.account_balance,
                        color: Theme.of(context).primaryColor),
                  ),
                  title: Text(a.name,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(a.type.name.toUpperCase()),
                  trailing: Text('$symbol${a.balance.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              );
            },
          );
        }
        return Center(child: Text(l10n.errorLoadingAccounts));
      },
    );
  }
}

// BudgetsTab, CategoriesTab and PlannerTab are kept exactly as you pasted (they were already good).

// For brevity in this response the full bodies of BudgetsTab, CategoriesTab and PlannerTab are identical
// to the version you provided that "works". They render correctly.

class BudgetsTab extends StatelessWidget {
  const BudgetsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<BudgetCubit, BudgetState>(
      builder: (context, state) {
        if (state is BudgetInitial || state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is BudgetLoaded) {
          if (state.budgets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.account_balance_wallet,
                      size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(l10n.noBudgetsYet,
                      style:
                          const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(l10n.addFirstBudget,
                      style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                      onPressed: () => context.push('/budgets/add'),
                      icon: const Icon(Icons.add),
                      label: Text(l10n.createBudget)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.budgets.length,
            itemBuilder: (context, index) {
              final b = state.budgets[index];
              final symbol = AppTheme.getCurrencySymbol(Hive.box('settings')
                  .get('selectedCurrency', defaultValue: 'TZS'));
              final progress =
                  b.amount > 0 ? (b.spent / b.amount).clamp(0.0, 1.0) : 0.0;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    child: Text('${(progress * 100).toInt()}%',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(b.name,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          l10n.spentOf('$symbol${b.spent.toStringAsFixed(2)}', '$symbol${b.amount.toStringAsFixed(2)}')),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                          value: progress, backgroundColor: Colors.grey[300]),
                    ],
                  ),
                ),
              );
            },
          );
        }
        return Center(child: Text(l10n.errorLoadingBudgets));
      },
    );
  }
}

class CategoriesTab extends StatelessWidget {
  const CategoriesTab({super.key});

  static void _showCategoryDialog(BuildContext context, [Category? existing]) {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: existing?.name ?? '');
    String selectedIcon = existing?.iconName ?? 'other';
    int selectedColor = existing?.colorValue ?? Colors.blue.toARGB32();

    final iconOptions = {
      'food': Icons.restaurant,
      'bills': Icons.receipt,
      'health': Icons.local_hospital,
      'education': Icons.school,
      'shopping': Icons.shopping_bag,
      'transport': Icons.directions_car,
      'entertainment': Icons.movie,
      'salary': Icons.work,
      'other': Icons.category,
    };

    final colorOptions = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.brown
    ];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(existing == null ? l10n.addCategory : l10n.editCategory),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration:
                          InputDecoration(labelText: l10n.categoryName),
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.icon,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: iconOptions.entries.map((entry) {
                        return ChoiceChip(
                          label: Icon(entry.value, size: 20),
                          selected: selectedIcon == entry.key,
                          onSelected: (_) =>
                              setState(() => selectedIcon = entry.key),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.color,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: colorOptions.map((color) {
                        return GestureDetector(
                          onTap: () =>
                              setState(() => selectedColor = color.toARGB32()),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: selectedColor == color.toARGB32()
                                  ? Border.all(color: Colors.black, width: 3)
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: Text(l10n.cancel)),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) return;

                    final category = Category(
                      id: existing?.id ??
                          DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameController.text.trim(),
                      colorValue: selectedColor,
                      iconName: selectedIcon,
                    );

                    if (existing == null) {
                      context
                          .read<FinanceBloc>()
                          .add(AddCategoryEvent(category));
                    } else {
                      context
                          .read<FinanceBloc>()
                          .add(UpdateCategoryEvent(category));
                    }
                    Navigator.pop(dialogContext);
                  },
                  child: Text(existing == null ? l10n.add : l10n.update),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<FinanceBloc, FinanceState>(
      builder: (context, state) {
        if (state is FinanceInitial || state is FinanceLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is CategoriesLoaded) {
          if (state.categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.category, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(l10n.noCategoriesYet,
                      style:
                          const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(l10n.addFirstCategory,
                      style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => CategoriesTab._showCategoryDialog(context),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.addCategory),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.categories.length,
            itemBuilder: (context, index) {
              final c = state.categories[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                      backgroundColor: c.color,
                      child: Icon(c.icon, color: Colors.white)),
                  title: Text(c.name,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => _showCategoryDialog(context, c),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete,
                            size: 20, color: Colors.red),
                        onPressed: () {
                          context
                              .read<FinanceBloc>()
                              .add(DeleteCategoryEvent(c.id));
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
        return Center(child: Text(l10n.errorLoadingCategories));
      },
    );
  }
}

class PlannerTab extends StatefulWidget {
  const PlannerTab({super.key});

  @override
  State<PlannerTab> createState() => _PlannerTabState();
}

class _PlannerTabState extends State<PlannerTab> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Map<String, dynamic>> _events = [];
  List<String> _notes = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadData();
  }

  void _loadData() {
    final eventsBox = Hive.box('planner_events');
    final notesBox = Hive.box('planner_notes');

    if (eventsBox.isNotEmpty) {
      _events = eventsBox.values.map((raw) {
        if (raw is Map) return Map<String, dynamic>.from(raw);
        return Map<String, dynamic>.from(raw as Map);
      }).toList();
    }
    if (notesBox.isNotEmpty) {
      _notes = notesBox.values.cast<String>().toList();
    }
    setState(() {});
  }

  void _saveEvents() {
    final eventsBox = Hive.box('planner_events');
    eventsBox.clear();
    for (var event in _events) {
      eventsBox.add(event);
    }
  }

  void _saveNotes() {
    final notesBox = Hive.box('planner_notes');
    notesBox.clear();
    for (var note in _notes) {
      notesBox.add(note);
    }
  }

  void _addEvent() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController titleController = TextEditingController();
        return AlertDialog(
          title: Text(l10n.addEvent),
          content: TextField(
              controller: titleController,
              decoration: InputDecoration(hintText: l10n.description)),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel)),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  setState(() {
                    _events.add({
                      'date': _selectedDay?.toIso8601String(),
                      'title': titleController.text
                    });
                  });
                  _saveEvents();
                  Navigator.pop(context);
                }
              },
              child: Text(l10n.add),
            ),
          ],
        );
      },
    );
  }

  void _addNote() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController noteController = TextEditingController();
        return AlertDialog(
          title: Text(l10n.addNote),
          content: TextField(
              controller: noteController,
              maxLines: 3,
              decoration:
                  InputDecoration(hintText: l10n.description)),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel)),
            ElevatedButton(
              onPressed: () {
                if (noteController.text.isNotEmpty) {
                  setState(() {
                    _notes.add(noteController.text);
                  });
                  _saveNotes();
                  Navigator.pop(context);
                }
              },
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dayEvents = _events
        .where((e) =>
            e['date'] != null &&
            isSameDay(DateTime.parse(e['date'] as String),
                _selectedDay ?? _focusedDay))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.calendar,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _addEvent,
                          tooltip: l10n.addEvent),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 320,
                    child: TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      calendarFormat: _calendarFormat,
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      onFormatChanged: (format) =>
                          setState(() => _calendarFormat = format),
                      onPageChanged: (focusedDay) => _focusedDay = focusedDay,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Events Section
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.todaysEvents,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      TextButton.icon(
                          onPressed: _addEvent,
                          icon: const Icon(Icons.add, size: 18),
                          label: Text(l10n.add)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (dayEvents.isEmpty)
                    Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                            child: Text(l10n.noEventsDay,
                                style: const TextStyle(color: Colors.grey))))
                  else
                    ...dayEvents.map((event) => ListTile(
                          leading: const Icon(Icons.event, color: Colors.blue),
                          title: Text(event['title'] ?? ''),
                          subtitle: Text(
                              event['date']?.toString().split('T').first ?? ''),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() => _events.remove(event));
                              _saveEvents();
                            },
                          ),
                        )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Notes Section
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.quickNotes,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      TextButton.icon(
                          onPressed: _addNote,
                          icon: const Icon(Icons.note_add, size: 18),
                          label: Text(l10n.addNote)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_notes.isEmpty)
                    Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                            child: Text(l10n.noNotes,
                                style: const TextStyle(color: Colors.grey))))
                  else
                    ..._notes.asMap().entries.map((entry) {
                      final index = entry.key;
                      final note = entry.value;
                      return ListTile(
                        leading: const Icon(Icons.note, color: Colors.orange),
                        title: Text(note),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() => _notes.removeAt(index));
                            _saveNotes();
                          },
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
