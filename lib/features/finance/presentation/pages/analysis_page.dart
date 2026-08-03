import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/category.dart';
import '../../../../core/data/hive_database.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/finance_bloc.dart';
import '../bloc/report_cubit.dart';
import '../../domain/usecases/comprehensive_report_usecase.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  String _dateRangeFilter = 'This Month';
  bool _showForecasting = false;

  final List<String> _dateRangeOptions = const [
    'This Month',
    'Last 3 Months',
    'This Year',
    'All Time',
  ];

  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(LoadTransactionsEvent());
    context.read<FinanceBloc>().add(LoadCategoriesEvent());
    _loadReport();
  }

  void _loadReport() {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate = now;

    switch (_dateRangeFilter) {
      case 'Last 3 Months':
        startDate = DateTime(now.year, now.month - 2, 1);
        break;
      case 'This Year':
        startDate = DateTime(now.year, 1, 1);
        break;
      case 'All Time':
        startDate = DateTime(2000);
        break;
      case 'This Month':
      default:
        startDate = DateTime(now.year, now.month, 1);
    }
    context.read<ReportCubit>().loadComprehensiveReport(startDate, endDate);
  }

  List<Transaction> _getFilteredTransactions(List<Transaction> transactions) {
    final now = DateTime.now();
    DateTime startDate;

    switch (_dateRangeFilter) {
      case 'Last 3 Months':
        startDate = DateTime(now.year, now.month - 2, 1);
        break;
      case 'This Year':
        startDate = DateTime(now.year, 1, 1);
        break;
      case 'All Time':
        startDate = DateTime(2000);
        break;
      case 'This Month':
      default:
        startDate = DateTime(now.year, now.month, 1);
    }

    return transactions.where((t) => !t.date.isBefore(startDate)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final currency = HiveDatabase.settingsBox.get('selectedCurrency', defaultValue: 'TZS');
    final symbol = AppTheme.getCurrencySymbol(currency);
    final padding = Responsive.getPadding(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Analysis', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_showForecasting ? Icons.trending_up : Icons.show_chart, 
              color: _showForecasting ? Theme.of(context).primaryColor : null),
            onPressed: () => setState(() => _showForecasting = !_showForecasting),
            tooltip: 'Toggle Forecasting',
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _dateRangeFilter,
                icon: const Icon(Icons.filter_list, size: 18),
                style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 13),
                items: _dateRangeOptions
                    .map((option) => DropdownMenuItem(value: option, child: Text(option)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _dateRangeFilter = value);
                    _loadReport();
                  }
                },
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<ReportCubit, ReportState>(
        builder: (context, reportState) {
          return BlocBuilder<TransactionBloc, TransactionState>(
            builder: (context, transactionState) {
              return BlocBuilder<FinanceBloc, FinanceState>(
                builder: (context, financeState) {
                  if (transactionState.isLoading || financeState is FinanceLoading || reportState.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final filteredTransactions = _getFilteredTransactions(transactionState.transactions);
                  final categories = financeState is CategoriesLoaded ? financeState.categories : <Category>[];
                  final categoryMap = {for (var c in categories) c.id: c};
                  
                  final BusinessReport? report = reportState is ReportLoaded && reportState.report is BusinessReport 
                      ? reportState.report as BusinessReport 
                      : null;

                  if (filteredTransactions.isEmpty) {
                    return const Center(child: Text('No transactions found for this period'));
                  }

                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(padding, 16, padding, padding + 16),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_showForecasting && report != null) ...[
                              _buildForecastingSection(report, symbol),
                              const SizedBox(height: 24),
                            ],
                            _buildSummaryCards(filteredTransactions, symbol),
                            const SizedBox(height: 24),
                            if (Responsive.isDesktop(context))
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _buildChartSection('Income vs Expenses', _buildBarChart(filteredTransactions))),
                                  const SizedBox(width: 24),
                                  Expanded(child: _buildChartSection('Expense Distribution', _buildPieChart(filteredTransactions, categories))),
                                ],
                              )
                            else
                              Column(
                                children: [
                                  _buildChartSection('Income vs Expenses', _buildBarChart(filteredTransactions)),
                                  const SizedBox(height: 24),
                                  _buildChartSection('Expense Distribution', _buildPieChart(filteredTransactions, categories)),
                                ],
                              ),
                            const SizedBox(height: 24),
                            Text('Category Breakdown', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            _buildCategoryBreakdown(filteredTransactions, categoryMap, symbol),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(List<Transaction> transactions, String symbol) {
    final totalIncome = transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalExpenses = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
    final averageAmount = transactions.isEmpty ? 0.0 : transactions.fold(0.0, (sum, t) => sum + t.amount) / transactions.length;

    return GridView.count(
      crossAxisCount: Responsive.getGridCrossAxisCount(context),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 2.2,
      children: [
        _buildStatCard('Total Income', totalIncome, Colors.green, symbol, Icons.trending_up),
        _buildStatCard('Total Expenses', totalExpenses, Colors.red, symbol, Icons.trending_down),
        _buildStatCard('Net Savings', totalIncome - totalExpenses, Colors.blue, symbol, Icons.account_balance_wallet),
        _buildStatCard('Avg / Trans', averageAmount, Colors.orange, symbol, Icons.receipt_long),
      ],
    );
  }

  Widget _buildStatCard(String label, double value, Color color, String symbol, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.softShadow,
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '$symbol${value.toStringAsFixed(0)}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(String title, Widget chart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 16),
        Container(
          height: 300,
          padding: const EdgeInsets.fromLTRB(12, 24, 24, 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppTheme.softShadow,
          ),
          child: chart,
        ),
      ],
    );
  }

  Widget _buildBarChart(List<Transaction> transactions) {
    final Map<String, List<Transaction>> grouped = {};
    for (final t in transactions) {
      final key = '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(key, () => []).add(t);
    }

    final keys = grouped.keys.toList()..sort();
    final displayKeys = keys.length > 6 ? keys.sublist(keys.length - 6) : keys;

    if (displayKeys.isEmpty) return const Center(child: Text('Not enough data'));

    final groups = List.generate(displayKeys.length, (index) {
      final key = displayKeys[index];
      final txs = grouped[key]!;
      final income = txs.where((t) => t.type == TransactionType.income).fold(0.0, (sum, t) => sum + t.amount);
      final expense = txs.where((t) => t.type == TransactionType.expense).fold(0.0, (sum, t) => sum + t.amount);

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(toY: income, color: Colors.green, width: 12, borderRadius: BorderRadius.circular(4)),
          BarChartRodData(toY: expense, color: Colors.red, width: 12, borderRadius: BorderRadius.circular(4)),
        ],
      );
    });

    double maxY = 0;
    for (var group in groups) {
      for (var rod in group.barRods) {
        if (rod.toY > maxY) maxY = rod.toY;
      }
    }
    maxY = maxY == 0 ? 100 : maxY * 1.2;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < displayKeys.length) {
                  final key = displayKeys[value.toInt()];
                  final month = int.parse(key.split('-')[1]);
                  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(months[month - 1], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: groups,
      ),
    );
  }

  Widget _buildPieChart(List<Transaction> transactions, List<Category> categories) {
    final expenses = transactions.where((t) => t.type == TransactionType.expense);
    final Map<String, double> byCategoryId = {};
    double totalExpense = 0;

    for (final t in expenses) {
      byCategoryId[t.categoryId] = (byCategoryId[t.categoryId] ?? 0.0) + t.amount;
      totalExpense += t.amount;
    }

    if (totalExpense == 0) return const Center(child: Text('No expense data'));

    final sortedEntries = byCategoryId.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final List<PieChartSectionData> sections = [];
    final categoryMap = {for (var c in categories) c.id: c};
    
    for (int i = 0; i < sortedEntries.length && i < 5; i++) {
      final entry = sortedEntries[i];
      final category = categoryMap[entry.key] ?? Category(id: '', name: 'Other', colorValue: Colors.grey.r.toInt() << 24 | Colors.grey.g.toInt() << 16 | Colors.grey.b.toInt() << 8 | Colors.grey.a.toInt(), iconName: '');
      sections.add(PieChartSectionData(
        value: entry.value,
        title: '${(entry.value / totalExpense * 100).toStringAsFixed(0)}%',
        color: category.color,
        radius: 60,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      ));
    }

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: sections,
      ),
    );
  }

  Widget _buildCategoryBreakdown(List<Transaction> transactions, Map<String, Category> categoryMap, String symbol) {
    final expenses = transactions.where((t) => t.type == TransactionType.expense);
    final Map<String, double> byCategoryId = {};
    double totalExpense = 0;

    for (final t in expenses) {
      byCategoryId[t.categoryId] = (byCategoryId[t.categoryId] ?? 0.0) + t.amount;
      totalExpense += t.amount;
    }

    final sortedEntries = byCategoryId.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sortedEntries.map((entry) {
        final category = categoryMap[entry.key] ??
            Category(id: '', name: 'Unknown', colorValue: 0xFF9E9E9E, iconName: 'other');
        final percentage = totalExpense > 0 ? (entry.value / totalExpense) : 0.0;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.softShadow,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: category.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(category.icon, color: category.color, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            Text('${(percentage * 100).toStringAsFixed(1)}% of total expenses', 
                              style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                          ],
                        ),
                      ),
                      Text('$symbol${entry.value.toStringAsFixed(0)}', 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Stack(
                    children: [
                      Container(
                        height: 8,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: percentage,
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [category.color, category.color.withValues(alpha: 0.7)],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildForecastingSection(BusinessReport report, String symbol) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.auto_graph, color: Colors.purple, size: 20),
            const SizedBox(width: 8),
            Text('30-Day Forecast', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.purple)),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: Responsive.getGridCrossAxisCount(context),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.5,
          children: [
            _buildStatCard('Projected Revenue', report.projectedRevenue, Colors.purple, symbol),
            _buildStatCard('Projected Profit', report.projectedProfit, Colors.deepPurple, symbol),
          ],
        ),
      ],
    );
  }
}
