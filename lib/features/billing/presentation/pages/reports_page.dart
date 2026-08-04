import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/widgets.dart' as pdf_widgets;
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../billing/domain/repositories/sales_repository.dart';
import '../../../billing/domain/entities/sales_transaction.dart';
import '../../../finance/domain/repositories/transaction_repository.dart';
import '../../../finance/domain/entities/transaction.dart';
import '../../../billing/domain/repositories/customer_repository.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> with TickerProviderStateMixin {
  late TabController _tabController;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  Map<String, dynamic> _reportData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadReportData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReportData() async {
    setState(() => _isLoading = true);

    try {
      final salesRepo = context.read<SalesRepository>();
      final financeRepo = context.read<TransactionRepository>();
      final customerRepo = context.read<CustomerRepository>();

      // Sales data
      final salesResult = await salesRepo.getSalesByDateRange(_startDate, _endDate);
      final dailyRevenueResult = await salesRepo.getDailyRevenue(_startDate, _endDate);
      final dailyProfitResult = await salesRepo.getDailyProfit(_startDate, _endDate);

      // Product analytics
      final topProductsResult = await salesRepo.getTopPerformingProducts(_startDate, _endDate);
      final lowTurnoverResult = await salesRepo.getLowTurnoverProducts();

      // Financial data
      final transactions = await financeRepo.getTransactionsByDateRange(_startDate, _endDate);

      // Customer data
      final customersResult = await customerRepo.getCustomers();

      salesResult.fold(
        (failure) => _showError(AppLocalizations.of(context)!.failedToLoadSalesData),
        (sales) {
          dailyRevenueResult.fold(
            (failure) => _showError(AppLocalizations.of(context)!.failedToLoadRevenueData),
            (dailyRevenue) {
              dailyProfitResult.fold(
                (failure) => _showError(AppLocalizations.of(context)!.failedToLoadProfitData),
                (dailyProfit) {
                  topProductsResult.fold(
                    (failure) => _showError(AppLocalizations.of(context)!.failedToLoadProductAnalytics),
                    (topProducts) {
                      lowTurnoverResult.fold(
                        (failure) => _showError(AppLocalizations.of(context)!.failedToLoadLowTurnoverData),
                        (lowTurnover) {
                          transactions.fold(
                            (failure) => _showError(AppLocalizations.of(context)!.failedToLoadFinancialData),
                            (financeTransactions) {
                              customersResult.fold(
                                (failure) => _showError(AppLocalizations.of(context)!.failedToLoadCustomerData),
                                (customers) {
                                  setState(() {
                                    _reportData = {
                                      'sales': sales,
                                      'dailyRevenue': dailyRevenue,
                                      'dailyProfit': dailyProfit,
                                      'topProducts': topProducts,
                                      'lowTurnover': lowTurnover,
                                      'financeTransactions': financeTransactions,
                                      'customers': customers,
                                    };
                                    _isLoading = false;
                                  });
                                },
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
          );
        },
      );
    } catch (e) {
      _showError(AppLocalizations.of(context)!.errorLoadingReportData(e.toString()));
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _exportReportToPDF() async {
    try {
      final pdf = pdf_widgets.Document();
      pdf.addPage(
        pdf_widgets.Page(
          build: (pdf_widgets.Context contextInside) {
            final l10n = AppLocalizations.of(context)!;
            return pdf_widgets.Column(
              crossAxisAlignment: pdf_widgets.CrossAxisAlignment.start,
              children: [
                pdf_widgets.Text(l10n.twigaMoneyReport,
                    style: pdf_widgets.TextStyle(fontSize: 24, fontWeight: pdf_widgets.FontWeight.bold)),
                pdf_widgets.SizedBox(height: 8),
                pdf_widgets.Text(l10n.period(DateFormat('yyyy-MM-dd').format(_startDate), DateFormat('yyyy-MM-dd').format(_endDate))),
                pdf_widgets.SizedBox(height: 20),
                pdf_widgets.Text(l10n.reportGeneratedOn(DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()))),
              ],
            );
          },
        ),
      );

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/report_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());

      await Share.shareXFiles([XFile(file.path)], text: AppLocalizations.of(context)!.twigaMoneyReport);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.reportExportedSuccessfully)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.exportFailed(e.toString())), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _exportReportToCSV() async {
    try {
      final l10n = AppLocalizations.of(context)!;
      final sales = _reportData['sales'] as List<SalesTransaction>? ?? [];
      final csvData = [
        ['ID', l10n.products, l10n.quantity, l10n.revenue, l10n.profit, l10n.date],
        ...sales.map((s) => [
              s.id,
              s.productName,
              s.quantity,
              s.totalRevenue.toStringAsFixed(2),
              s.totalProfit.toStringAsFixed(2),
              s.timestamp.toIso8601String(),
            ]),
      ];

      final csv = const ListToCsvConverter().convert(csvData);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/report_${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsString(csv);

      await Share.shareXFiles([XFile(file.path)], text: '${AppLocalizations.of(context)!.twigaMoneyReport} CSV');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.csvReportExported)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.exportFailed(e.toString())), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _showCustomReportDialog() async {
    final l10n = AppLocalizations.of(context)!;
    DateTime? customStart = _startDate;
    DateTime? customEnd = _endDate;
    String reportType = 'Sales';

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.generateCustomReport),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: reportType,
                decoration: InputDecoration(labelText: l10n.reportType),
                items: [
                  DropdownMenuItem(value: 'Sales', child: Text(l10n.salesReport)),
                  DropdownMenuItem(value: 'Products', child: Text(l10n.productsReport)),
                  DropdownMenuItem(value: 'Finance', child: Text(l10n.financeReport)),
                  DropdownMenuItem(value: 'Customers', child: Text(l10n.customersReport)),
                ],
                onChanged: (val) => setState(() => reportType = val!),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(l10n.startDate),
                subtitle: Text(DateFormat('yyyy-MM-dd').format(customStart!)),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: customStart!,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => customStart = picked);
                },
              ),
              ListTile(
                title: Text(l10n.endDate),
                subtitle: Text(DateFormat('yyyy-MM-dd').format(customEnd!)),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: customEnd!,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => customEnd = picked);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final start = customStart!;
                final end = customEnd!;
                final type = reportType;
                
                Navigator.pop(context);
                
                this.setState(() {
                  _startDate = start;
                  _endDate = end;
                });
                _loadReportData();
                
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(content: Text(l10n.customReportPeriod(type))),
                );
              },
              child: Text(l10n.generate),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadReportData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.reports),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Theme.of(context).primaryColor),
          onPressed: () { if (context.canPop()) { context.pop(); } else { context.go('/'); } },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _showCustomReportDialog,
            tooltip: AppLocalizations.of(context)!.generateCustomReport,
          ),
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
            tooltip: AppLocalizations.of(context)!.selectDateRange,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'pdf':
                  _exportReportToPDF();
                  break;
                case 'csv':
                  _exportReportToCSV();
                  break;
                case 'share':
                  _exportReportToPDF();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'pdf', child: Text(AppLocalizations.of(context)!.exportPdf)),
              PopupMenuItem(value: 'csv', child: Text(AppLocalizations.of(context)!.exportCsv)),
              PopupMenuItem(value: 'share', child: Text(AppLocalizations.of(context)!.shareReport)),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReportData,
            tooltip: AppLocalizations.of(context)!.refreshData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryColor,
          tabs: [
            Tab(text: AppLocalizations.of(context)!.sales),
            Tab(text: AppLocalizations.of(context)!.products),
            Tab(text: AppLocalizations.of(context)!.finance),
            Tab(text: AppLocalizations.of(context)!.customers),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildSalesTab(),
                _buildProductsTab(),
                _buildFinanceTab(),
                _buildCustomersTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCustomReportDialog,
        icon: const Icon(Icons.add_chart),
        label: Text(AppLocalizations.of(context)!.newReport),
      ),
    );
  }

  Widget _buildSalesTab() {
    final sales = _reportData['sales'] as List<SalesTransaction>? ?? [];
    final dailyRevenue = _reportData['dailyRevenue'] as Map<String, double>? ?? {};
    final dailyProfit = _reportData['dailyProfit'] as Map<String, double>? ?? {};

    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    final todaySales = sales.where((s) =>
        s.timestamp.year == today.year &&
        s.timestamp.month == today.month &&
        s.timestamp.day == today.day).toList();

    final yesterdaySales = sales.where((s) =>
        s.timestamp.year == yesterday.year &&
        s.timestamp.month == yesterday.month &&
        s.timestamp.day == yesterday.day).toList();

    final totalRevenue = sales.fold<double>(0, (sum, sale) => sum + sale.totalRevenue);
    final totalProfit = sales.fold<double>(0, (sum, sale) => sum + sale.totalProfit);

    return SingleChildScrollView(
      padding: EdgeInsets.all(Responsive.getPadding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  AppLocalizations.of(context)!.todaySalesLabel,
                  '${AppTheme.getCurrencySymbol(Hive.box('settings').get('selectedCurrency', defaultValue: 'TZS'))}${todaySales.fold<double>(0, (sum, s) => sum + s.totalRevenue).toStringAsFixed(2)}',
                  AppLocalizations.of(context)!.transactionsWithCount(todaySales.length),
                  Icons.today,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  AppLocalizations.of(context)!.yesterdaySalesLabel,
                  '${AppTheme.getCurrencySymbol(Hive.box('settings').get('selectedCurrency', defaultValue: 'TZS'))}${yesterdaySales.fold<double>(0, (sum, s) => sum + s.totalRevenue).toStringAsFixed(2)}',
                  AppLocalizations.of(context)!.transactionsWithCount(yesterdaySales.length),
                  Icons.calendar_today,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  AppLocalizations.of(context)!.totalRevenueLabel,
                  '${AppTheme.getCurrencySymbol(Hive.box('settings').get('selectedCurrency', defaultValue: 'TZS'))}${totalRevenue.toStringAsFixed(2)}',
                  AppLocalizations.of(context)!.transactionsWithCount(sales.length),
                  Icons.attach_money,
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  AppLocalizations.of(context)!.totalProfitLabel,
                  '${AppTheme.getCurrencySymbol(Hive.box('settings').get('selectedCurrency', defaultValue: 'TZS'))}${totalProfit.toStringAsFixed(2)}',
                  '${totalRevenue > 0 ? ((totalProfit / totalRevenue) * 100).toStringAsFixed(1) : '0.0'}% margin',
                  Icons.trending_up,
                  Colors.orange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

            // Revenue Chart
          _buildChartCard(
            AppLocalizations.of(context)!.revenueTrend,
            SizedBox(
              height: MediaQuery.of(context).size.width < 380 ? 140 : 180,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: dailyRevenue.entries.map((entry) {
                        final date = DateTime.parse(entry.key);
                        final days = date.difference(_startDate).inDays;
                        return FlSpot(days.toDouble(), entry.value);
                      }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

            // Profit Chart
          _buildChartCard(
            AppLocalizations.of(context)!.profitTrend,
            SizedBox(
              height: MediaQuery.of(context).size.width < 380 ? 140 : 180,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: dailyProfit.entries.map((entry) {
                        final date = DateTime.parse(entry.key);
                        final days = date.difference(_startDate).inDays;
                        return FlSpot(days.toDouble(), entry.value);
                      }).toList(),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Recent Sales
          _buildListCard(
            AppLocalizations.of(context)!.recentSales,
            itemBuilder: (context, index) {
              final sale = sales[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.receipt_long, color: Colors.blue, size: 20),
                ),
                title: Text(
                  '${AppTheme.getCurrencySymbol(Hive.box('settings').get('selectedCurrency', defaultValue: 'TZS'))}${sale.totalRevenue.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  DateFormat('MMM dd, HH:mm').format(sale.timestamp),
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${sale.quantity} ${AppLocalizations.of(context)!.items}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '+${sale.totalProfit.toStringAsFixed(0)} ${AppLocalizations.of(context)!.profit.toLowerCase()}',
                      style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            },
            itemCount: sales.length > 10 ? 10 : sales.length,
          ),
        ],
      ),
    );
  }

  Widget _buildProductsTab() {
    final topProducts = _reportData['topProducts'] as List<dynamic>? ?? [];
    final lowTurnover = _reportData['lowTurnover'] as List<dynamic>? ?? [];

    return SingleChildScrollView(
      padding: EdgeInsets.all(Responsive.getPadding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Best Sellers
          _buildListCard(
            AppLocalizations.of(context)!.bestSellers,
            itemBuilder: (context, index) {
              final product = topProducts[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                leading: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(product.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  '${product.totalSold} sold • ${AppTheme.getCurrencySymbol(Hive.box('settings').get('selectedCurrency', defaultValue: 'TZS'))}${product.totalRevenue.toStringAsFixed(0)} rev',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${product.marginPercentage.toStringAsFixed(0)}% mgn',
                    style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
            itemCount: topProducts.length > 10 ? 10 : topProducts.length,
          ),

          const SizedBox(height: 24),

          // Low Turnover Products
          _buildListCard(
            AppLocalizations.of(context)!.lowTurnoverProducts,
            itemBuilder: (context, index) {
              final product = lowTurnover[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.inventory_2_outlined, color: Colors.orange, size: 20),
                ),
                title: Text(product.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  'Rate: ${product.turnoverRate.toStringAsFixed(2)} • ${product.totalSold} sold',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: Text(
                  '${AppTheme.getCurrencySymbol(Hive.box('settings').get('selectedCurrency', defaultValue: 'TZS'))}${product.totalRevenue.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              );
            },
            itemCount: lowTurnover.length > 10 ? 10 : lowTurnover.length,
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceTab() {
    final transactions =
        _reportData['financeTransactions'] as List<dynamic>? ?? [];

    final expenses = transactions
        .where((t) =>
            t is Transaction &&
            t.type == TransactionType.expense)
        .toList();
    final income = transactions
        .where(
            (t) => t is Transaction && t.type == TransactionType.income)
        .toList();

    final totalExpenses = expenses.fold<double>(0, (sum, t) => sum + t.amount);
    final totalIncome = income.fold<double>(0, (sum, t) => sum + t.amount);

    return SingleChildScrollView(
      padding: EdgeInsets.all(Responsive.getPadding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Financial Summary
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  AppLocalizations.of(context)!.totalIncome,
                  '${AppTheme.getCurrencySymbol(Hive.box('settings').get('selectedCurrency', defaultValue: 'TZS'))}${totalIncome.toStringAsFixed(2)}',
                  AppLocalizations.of(context)!.transactionsWithCount(income.length),
                  Icons.arrow_upward,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  AppLocalizations.of(context)!.totalExpenses,
                  '${AppTheme.getCurrencySymbol(Hive.box('settings').get('selectedCurrency', defaultValue: 'TZS'))}${totalExpenses.toStringAsFixed(2)}',
                  AppLocalizations.of(context)!.transactionsWithCount(expenses.length),
                  Icons.arrow_downward,
                  Colors.red,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Recent Transactions
          _buildListCard(
            AppLocalizations.of(context)!.recentTransactions,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              final isExpense = transaction is Transaction &&
                  transaction.type == TransactionType.expense;
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isExpense ? Colors.red.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                    color: isExpense ? Colors.red : Colors.green,
                    size: 20,
                  ),
                ),
                title: Text(transaction.description, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(DateFormat('MMM dd, yyyy').format(transaction.date), style: const TextStyle(fontSize: 12)),
                trailing: Text(
                  '${!isExpense ? '+' : '-'}${AppTheme.getCurrencySymbol(Hive.box('settings').get('selectedCurrency', defaultValue: 'TZS'))}${transaction.amount.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: !isExpense ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              );
            },
            itemCount: transactions.length > 20 ? 20 : transactions.length,
          ),
        ],
      ),
    );
  }

  Widget _buildCustomersTab() {
    final customers = _reportData['customers'] as List<dynamic>? ?? [];

    return SingleChildScrollView(
      padding: EdgeInsets.all(Responsive.getPadding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer Summary
          _buildSummaryCard(
            AppLocalizations.of(context)!.totalCustomers,
            '${customers.length}',
            AppLocalizations.of(context)!.active,
            Icons.people,
            Colors.blue,
          ),

          const SizedBox(height: 24),

          // Customer List
          _buildListCard(
            AppLocalizations.of(context)!.customerList,
            itemBuilder: (context, index) {
              final customer = customers[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  child: Text(
                    customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                    style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(customer.phone.isNotEmpty ? customer.phone : AppLocalizations.of(context)!.noPhone, style: const TextStyle(fontSize: 12)),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${AppTheme.getCurrencySymbol(Hive.box('settings').get('selectedCurrency', defaultValue: 'TZS'))}${customer.currentBalance.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: customer.currentBalance > 0 ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(AppLocalizations.of(context)!.balance, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              );
            },
            itemCount: customers.length > 20 ? 20 : customers.length,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width < 380 ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            chart,
          ],
        ),
      ),
    );
  }

  Widget _buildListCard(
    String title, {
    List<Widget>? items,
    Widget Function(BuildContext, int)? itemBuilder,
    int? itemCount,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if ((items?.isEmpty ?? false) || (itemCount == 0))
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(AppLocalizations.of(context)!.noData),
            )
          else if (itemBuilder != null && itemCount != null)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: itemCount,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                indent: 70,
                color: Colors.grey.withValues(alpha: 0.1),
              ),
              itemBuilder: itemBuilder,
            )
          else if (items != null)
            ...items,
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}







