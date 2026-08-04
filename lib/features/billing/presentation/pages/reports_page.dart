import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/widgets.dart' as pdf_widgets;
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../bloc/analytics/analytics_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/page_transitions.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../finance/domain/entities/transaction.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> with TickerProviderStateMixin {
  late TabController _tabController;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAnalytics();
  }

  void _loadAnalytics() {
    context.read<AnalyticsBloc>().add(LoadAnalyticsEvent(
          startDate: _startDate,
          endDate: _endDate,
        ));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _exportReportToPDF() async {
    final l10n = AppLocalizations.of(context)!;
    
    try {
      final pdf = pdf_widgets.Document();
      final state = context.read<AnalyticsBloc>().state;
      final transactions = state.transactions;
      
      pdf.addPage(
        pdf_widgets.Page(
          build: (pdf_widgets.Context contextInside) {
            return pdf_widgets.Column(
              crossAxisAlignment: pdf_widgets.CrossAxisAlignment.start,
              children: [
                pdf_widgets.Text(l10n.twigaMoneyReport,
                    style: pdf_widgets.TextStyle(fontSize: 24, fontWeight: pdf_widgets.FontWeight.bold)),
                pdf_widgets.SizedBox(height: 8),
                pdf_widgets.Text(l10n.period(DateFormat('yyyy-MM-dd').format(_startDate), DateFormat('yyyy-MM-dd').format(_endDate))),
                pdf_widgets.SizedBox(height: 20),
                pdf_widgets.Text(l10n.reportGeneratedOn(DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()))),
                pdf_widgets.SizedBox(height: 20),
                pdf_widgets.Text('Total Transactions: ${transactions.length}'),
              ],
            );
          },
        ),
      );

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/report_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());

      await Share.shareXFiles([XFile(file.path)], text: l10n.twigaMoneyReport);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.reportExportedSuccessfully)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.exportFailed(e.toString())), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _exportReportToCSV() async {
    final l10n = AppLocalizations.of(context)!;
    
    try {
      final state = context.read<AnalyticsBloc>().state;
      final transactions = state.transactions;
      final csvData = [
        ['ID', l10n.description, l10n.amount, l10n.date, l10n.type],
        ...transactions.map((t) => [
              t.id,
              t.description,
              t.amount.toStringAsFixed(2),
              t.date.toIso8601String(),
              t.type.name,
            ]),
      ];

      final csv = const ListToCsvConverter().convert(csvData);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/report_${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsString(csv);

      await Share.shareXFiles([XFile(file.path)], text: '${l10n.twigaMoneyReport} CSV');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.csvReportExported)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.exportFailed(e.toString())), backgroundColor: Colors.red),
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
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(l10n.generateCustomReport, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: reportType,
                decoration: InputDecoration(
                  labelText: l10n.reportType,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                items: [
                  DropdownMenuItem(value: 'Sales', child: Text(l10n.salesReport)),
                  DropdownMenuItem(value: 'Products', child: Text(l10n.productsReport)),
                  DropdownMenuItem(value: 'Finance', child: Text(l10n.financeReport)),
                  DropdownMenuItem(value: 'Customers', child: Text(l10n.customersReport)),
                ],
                onChanged: (val) => setDialogState(() => reportType = val!),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined),
                title: Text(l10n.startDate, style: const TextStyle(fontSize: 14)),
                subtitle: Text(AppTheme.getDateFormat().format(customStart!), style: const TextStyle(fontWeight: FontWeight.bold)),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: customStart!,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setDialogState(() => customStart = picked);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_outlined),
                title: Text(l10n.endDate, style: const TextStyle(fontSize: 14)),
                subtitle: Text(AppTheme.getDateFormat().format(customEnd!), style: const TextStyle(fontWeight: FontWeight.bold)),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: customEnd!,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setDialogState(() => customEnd = picked);
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
                
                setState(() {
                  _startDate = start;
                  _endDate = end;
                });
                _loadAnalytics();
                
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(content: Text(l10n.customReportPeriod(type))),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(100, 45),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
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
      _loadAnalytics();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnalyticsBloc, AnalyticsState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            leading: const BackButtonWidget(),
            title: Text(AppLocalizations.of(context)!.reports, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                icon: const Icon(Icons.download),
                onSelected: (value) {
                  switch (value) {
                    case 'pdf':
                      _exportReportToPDF();
                      break;
                    case 'csv':
                      _exportReportToCSV();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'pdf', 
                    child: Row(
                      children: [
                        const Icon(Icons.picture_as_pdf, size: 20, color: Colors.red),
                        const SizedBox(width: 12),
                        Text(AppLocalizations.of(context)!.exportPdf),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'csv', 
                    child: Row(
                      children: [
                        const Icon(Icons.table_chart, size: 20, color: Colors.green),
                        const SizedBox(width: 12),
                        Text(AppLocalizations.of(context)!.exportCsv),
                      ],
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: _exportReportToPDF,
                tooltip: AppLocalizations.of(context)!.shareReport,
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadAnalytics,
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
          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildSalesTab(state),
                    _buildProductsTab(state),
                    _buildFinanceTab(state),
                    _buildCustomersTab(state),
                  ],
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _showCustomReportDialog,
            icon: const Icon(Icons.add_chart),
            label: Text(AppLocalizations.of(context)!.newReport),
          ),
        );
      },
    );
  }

  Widget _buildSalesTab(AnalyticsState state) {
    final dailyRevenue = state.dailyRevenue;
    final dailyProfit = state.dailyProfit;
    final totalSales = state.transactions.where((t) => t.type == TransactionType.income).length;
    final l10n = AppLocalizations.of(context)!;
    final currency = Hive.box('settings').get('selectedCurrency', defaultValue: 'TZS');
    final symbol = AppTheme.getCurrencySymbol(currency);
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(Responsive.getPadding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateRangeHeader(),
          const SizedBox(height: 16),
          _buildSummaryCards(state, totalSales),
          const SizedBox(height: 32),
          _buildSectionHeader(l10n.revenueTrend),
          const SizedBox(height: 16),
          _buildChartCard(
            "",
            SizedBox(
              height: 250, // Increased height
              child: dailyRevenue.isEmpty 
                ? _buildEmptyState()
                : LineChart(
                    LineChartData(
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          tooltipBgColor: Theme.of(context).colorScheme.surface,
                          tooltipRoundedRadius: 12,
                          getTooltipItems: (spots) => spots.map((spot) {
                            return LineTooltipItem(
                              '${NumberFormat.currency(symbol: symbol, decimalDigits: 0).format(spot.y)}',
                              TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final date = _startDate.add(Duration(days: value.toInt()));
                              if (value.toInt() % (state.dailyRevenue.length > 10 ? 5 : 2) != 0) return const SizedBox();
                              return Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Text(
                                  DateFormat('dd/MM').format(date),
                                  style: TextStyle(
                                    fontSize: 11, 
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            },
                            reservedSize: 35,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) => Text(
                              NumberFormat.compact().format(value),
                              style: TextStyle(
                                fontSize: 11, 
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            reservedSize: 45,
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: dailyRevenue.entries.map((entry) {
                            final date = DateTime.tryParse(entry.key) ?? DateTime.now();
                            final days = date.difference(_startDate).inDays.toDouble();
                            return FlSpot(days, entry.value);
                          }).toList()
                            ..sort((a, b) => a.x.compareTo(b.x)),
                          isCurved: true,
                          color: AppTheme.primaryColor,
                          barWidth: 5,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                              radius: 4,
                              color: AppTheme.primaryColor,
                              strokeWidth: 2,
                              strokeColor: Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor,
                            ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryColor.withValues(alpha: 0.3),
                                AppTheme.primaryColor.withValues(alpha: 0.0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
            ),
          ),
          const SizedBox(height: 32),
          _buildSectionHeader(l10n.profitTrend),
          const SizedBox(height: 16),
          _buildChartCard(
            "",
            SizedBox(
              height: 250,
              child: dailyProfit.isEmpty 
                ? _buildEmptyState()
                : LineChart(
                    LineChartData(
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          tooltipBgColor: Theme.of(context).colorScheme.surface,
                          tooltipRoundedRadius: 12,
                          getTooltipItems: (spots) => spots.map((spot) {
                            return LineTooltipItem(
                              '${NumberFormat.currency(symbol: symbol, decimalDigits: 0).format(spot.y)}',
                              TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final date = _startDate.add(Duration(days: value.toInt()));
                              if (value.toInt() % (state.dailyProfit.length > 10 ? 5 : 2) != 0) return const SizedBox();
                              return Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Text(
                                  DateFormat('dd/MM').format(date),
                                  style: TextStyle(
                                    fontSize: 11, 
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            },
                            reservedSize: 35,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) => Text(
                              NumberFormat.compact().format(value),
                              style: TextStyle(
                                fontSize: 11, 
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            reservedSize: 45,
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: dailyProfit.entries.map((entry) {
                            final date = DateTime.tryParse(entry.key) ?? DateTime.now();
                            final days = date.difference(_startDate).inDays.toDouble();
                            return FlSpot(days, entry.value);
                          }).toList()
                            ..sort((a, b) => a.x.compareTo(b.x)),
                          isCurved: true,
                          color: Colors.green,
                          barWidth: 5,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                              radius: 4,
                              color: Colors.green,
                              strokeWidth: 2,
                              strokeColor: Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor,
                            ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.withValues(alpha: 0.3),
                                Colors.green.withValues(alpha: 0.0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
            ),
          ),
          const SizedBox(height: 32),
          _buildSectionHeader(l10n.peakHours),
          const SizedBox(height: 16),
          _buildChartCard(
            "",
            SizedBox(
              height: 200,
              child: state.peakHours.isEmpty
                ? _buildEmptyState()
                : BarChart(
                    BarChartData(
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: state.peakHours.entries.map((e) => BarChartGroupData(
                        x: e.key,
                        barRods: [
                          BarChartRodData(
                            toY: e.value.toDouble(), 
                            color: AppTheme.secondaryColor,
                            width: 12,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                          )
                        ],
                      )).toList(),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() % 4 != 0) return const SizedBox();
                              return Text('${value.toInt()}h', style: TextStyle(fontSize: 10, color: Colors.grey[600]));
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                    ),
                  ),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildDateRangeHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, size: 16, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Text(
            '${DateFormat('MMM dd, yyyy').format(_startDate)} - ${DateFormat('MMM dd, yyyy').format(_endDate)}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: _selectDateRange,
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: Text(AppLocalizations.of(context)!.edit),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.noData,
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(AnalyticsState state, int totalSales) {
    final totalRevenue = state.dailyRevenue.values.fold<double>(0, (sum, val) => sum + val);
    final totalProfit = state.dailyProfit.values.fold<double>(0, (sum, val) => sum + val);
    final currency = Hive.box('settings').get('selectedCurrency', defaultValue: 'TZS');
    final symbol = AppTheme.getCurrencySymbol(currency);
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildSummaryCard(
              AppLocalizations.of(context)!.totalRevenueLabel,
              '$symbol${NumberFormat.compact().format(totalRevenue)}',
              '',
              Icons.payments_outlined,
              Colors.blue,
            ),
            _buildSummaryCard(
              AppLocalizations.of(context)!.totalProfitLabel,
              '$symbol${NumberFormat.compact().format(totalProfit)}',
              '${totalRevenue > 0 ? ((totalProfit / totalRevenue) * 100).toStringAsFixed(1) : '0.0'}% ${l10n.marginLabel}',
              Icons.trending_up,
              Colors.green,
            ),
            if (constraints.maxWidth > 600 || true) // Show 3rd card
              _buildSummaryCard(
                AppLocalizations.of(context)!.transactionsCount,
                totalSales.toString(),
                l10n.averageLabel(totalSales > 0 ? '$symbol${NumberFormat.compact().format(totalRevenue / totalSales)}' : '0'),
                Icons.shopping_cart_outlined,
                Colors.orange,
              ),
          ],
        );
      },
    );
  }

  Widget _buildProductsTab(AnalyticsState state) {
    final topProducts = state.topPerformingProducts;
    final lowTurnover = state.lowTurnoverProducts;
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(Responsive.getPadding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateRangeHeader(),
          const SizedBox(height: 16),
          _buildSummaryCard(
            l10n.topProducts,
            topProducts.length.toString(),
            l10n.recordsExportedAsCsv(topProducts.length.toString()),
            Icons.inventory_2_outlined,
            Colors.indigo,
          ),
          const SizedBox(height: 32),
          _buildSectionHeader(l10n.bestSellers),
          const SizedBox(height: 16),
          _buildListCard(
            "",
            itemBuilder: (context, index) {
              final product = topProducts[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                title: Text(product.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(l10n.unitsSold(product.totalSold.toString()), style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      NumberFormat.compact().format(product.totalRevenue),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      l10n.marginPercent(product.marginPercentage.toStringAsFixed(1)),
                      style: TextStyle(fontSize: 10, color: Colors.green[600], fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            },
            itemCount: topProducts.length,
          ),
          const SizedBox(height: 32),
          _buildSectionHeader(l10n.lowTurnoverProducts),
          const SizedBox(height: 16),
          _buildListCard(
            "",
            itemBuilder: (context, index) {
              final product = lowTurnover[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                ),
                title: Text(product.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(l10n.turnoverRate(product.turnoverRate.toStringAsFixed(2)), style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                trailing: Text(
                  l10n.soldCount(product.totalSold.toString()),
                  style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500),
                ),
              );
            },
            itemCount: lowTurnover.length,
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildFinanceTab(AnalyticsState state) {
    final transactions = state.transactions;
    final categoryDist = state.categoryDistribution;
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(Responsive.getPadding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateRangeHeader(),
          const SizedBox(height: 32),
          _buildSectionHeader(l10n.cashFlowTrend),
          const SizedBox(height: 16),
          _buildChartCard(
            "",
            SizedBox(
              height: 220,
              child: transactions.isEmpty 
                ? _buildEmptyState()
                : BarChart(
                    BarChartData(
                      barGroups: _generateFinanceBarGroups(transactions),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey.withValues(alpha: 0.1),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final date = _startDate.add(Duration(days: value.toInt()));
                              if (value.toInt() % 5 != 0) return const SizedBox();
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  DateFormat('dd/MM').format(date),
                                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                                ),
                              );
                            },
                            reservedSize: 30,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) => Text(
                              NumberFormat.compact().format(value),
                              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                            ),
                            reservedSize: 40,
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
            ),
          ),
          const SizedBox(height: 32),
          _buildSectionHeader(l10n.expenseByCategory),
          const SizedBox(height: 16),
          _buildChartCard(
            "",
            SizedBox(
              height: 240,
              child: categoryDist.isEmpty 
                ? _buildEmptyState()
                : Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 4,
                            centerSpaceRadius: 40,
                            sections: categoryDist.entries.map((entry) {
                              final index = categoryDist.keys.toList().indexOf(entry.key);
                              return PieChartSectionData(
                                value: entry.value,
                                title: '', // Don't show title on pie to avoid clutter
                                color: Colors.primaries[index % Colors.primaries.length],
                                radius: 50,
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: categoryDist.length > 5 ? 5 : categoryDist.length,
                          itemBuilder: (context, index) {
                            final entry = categoryDist.entries.elementAt(index);
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Colors.primaries[index % Colors.primaries.length],
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      entry.key,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    NumberFormat.compact().format(entry.value),
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
            ),
          ),
          const SizedBox(height: 32),
          _buildSectionHeader(l10n.recentTransactions),
          const SizedBox(height: 16),
          _buildListCard(
            "",
            itemBuilder: (context, index) {
              final tx = transactions[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (tx.type == TransactionType.expense ? Colors.red : Colors.green).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    tx.type == TransactionType.expense ? Icons.remove : Icons.add,
                    color: tx.type == TransactionType.expense ? Colors.red : Colors.green,
                  ),
                ),
                title: Text(tx.description, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(DateFormat('MMM dd, HH:mm').format(tx.date), style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                trailing: Text(
                  '${tx.type == TransactionType.expense ? "-" : "+"}${NumberFormat.compact().format(tx.amount)}',
                  style: TextStyle(
                    color: tx.type == TransactionType.expense ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              );
            },
            itemCount: transactions.length > 10 ? 10 : transactions.length,
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  List<BarChartGroupData> _generateFinanceBarGroups(List<Transaction> transactions) {
    final Map<int, double> dailyFlow = {};
    for (var tx in transactions) {
      final days = tx.date.difference(_startDate).inDays;
      if (days < 0) continue;
      final amount = tx.type == TransactionType.expense ? -tx.amount : tx.amount;
      dailyFlow[days] = (dailyFlow[days] ?? 0) + amount;
    }
    
    return dailyFlow.entries.map((e) => BarChartGroupData(
      x: e.key,
      barRods: [
        BarChartRodData(
          toY: e.value, 
          color: e.value >= 0 ? Colors.green : Colors.red,
          width: 8,
          borderRadius: BorderRadius.circular(2),
        )
      ],
    )).toList();
  }

  Widget _buildCustomersTab(AnalyticsState state) {
    final outstanding = state.outstandingCustomers;
    final debtAging = state.debtAging;
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(Responsive.getPadding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateRangeHeader(),
          const SizedBox(height: 16),
          _buildSummaryCard(
            l10n.totalCustomers,
            outstanding.length.toString(),
            l10n.activeBalancesDesc,
            Icons.people_outline,
            Colors.purple,
          ),
          const SizedBox(height: 32),
          _buildSectionHeader(l10n.debtAging),
          const SizedBox(height: 16),
          _buildChartCard(
            "",
            SizedBox(
              height: 250,
              child: debtAging.isEmpty
                ? _buildEmptyState()
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: (debtAging.values.fold<double>(0, (max, val) => val > max ? val : max) * 1.2),
                      barGroups: [
                        BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: debtAging['0-30'] ?? 0, color: Colors.blue, width: 40, borderRadius: BorderRadius.circular(8))]),
                        BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: debtAging['31-60'] ?? 0, color: Colors.orange, width: 40, borderRadius: BorderRadius.circular(8))]),
                        BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: debtAging['60+'] ?? 0, color: Colors.red, width: 40, borderRadius: BorderRadius.circular(8))]),
                      ],
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey.withValues(alpha: 0.1),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              String text = '';
                              switch (value.toInt()) {
                                case 0: text = l10n.agingRange0_30; break;
                                case 1: text = l10n.agingRange31_60; break;
                                case 2: text = l10n.agingRange60Plus; break;
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) => Text(
                              NumberFormat.compact().format(value),
                              style: const TextStyle(fontSize: 10),
                            ),
                            reservedSize: 40,
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
            ),
          ),
          const SizedBox(height: 32),
          _buildSectionHeader(l10n.outstandingBalances),
          const SizedBox(height: 16),
          _buildListCard(
            "",
            itemBuilder: (context, index) {
              final customer = outstanding[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: Colors.purple.withValues(alpha: 0.1),
                  child: Text(
                    customer.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(customer.phone.isNotEmpty ? customer.phone : l10n.noPhone, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                trailing: Text(
                  NumberFormat.compact().format(customer.currentBalance),
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              );
            },
            itemCount: outstanding.length,
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
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
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.softShadow,
      ),
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
    );
  }

  Widget _buildListCard(
    String title, {
    Widget Function(BuildContext, int)? itemBuilder,
    int? itemCount,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.softShadow,
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
          if (itemCount == 0 || itemCount == null)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(AppLocalizations.of(context)!.noData),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: itemCount,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                indent: 70,
                color: Colors.grey.withValues(alpha: 0.05),
              ),
              itemBuilder: itemBuilder!,
            ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
