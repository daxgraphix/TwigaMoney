import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/data/hive_database.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/page_transitions.dart';
import '../../domain/entities/shift.dart';
// import '../../domain/entities/sales_transaction.dart';

class ShiftReportPage extends StatelessWidget {
  final String shiftId;

  const ShiftReportPage({super.key, required this.shiftId});

  @override
  Widget build(BuildContext context) {
    final shiftBox = HiveDatabase.shiftBox;
    // Try to get the shift by ID, or if it's the current active shift
    Shift? shift = shiftBox.get(shiftId);
    if (shift == null) {
      final currentShift = shiftBox.get('current_shift');
      if (currentShift?.id == shiftId) {
        shift = currentShift;
      }
    }

    final currency = HiveDatabase.settingsBox.get('selectedCurrency', defaultValue: 'TZS');
    final symbol = AppTheme.getCurrencySymbol(currency);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (shift == null) {
      return Scaffold(
        appBar: AppBar(
          leading: const BackButtonWidget(),
          title: const Text('Shift Report', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: const Center(child: Text('Shift not found')),
      );
    }

    // Get transactions for this shift
    final transactions = HiveDatabase.salesTransactionBox.values
        .where((t) => t.shiftId == shiftId)
        .toList();

    return Scaffold(
      appBar: AppBar(
        leading: const BackButtonWidget(),
        title: Text(
          '${AppLocalizations.of(context)!.shiftReport}: ${shiftId.substring(0, 8)}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.getPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(context, shift, symbol, isDark),
            const SizedBox(height: 32),
            Row(
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
                  AppLocalizations.of(context)!.recentTransactions,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (transactions.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.noTransactionsYet,
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final tx = transactions[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.05)),
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.shopping_bag_outlined, color: AppTheme.primaryColor),
                      ),
                      title: Text(tx.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(DateFormat('HH:mm').format(tx.timestamp), style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('$symbol${tx.totalRevenue.toStringAsFixed(0)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('${tx.quantity} units', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, Shift shift, String symbol, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetric(l10n.startDate.toUpperCase(), DateFormat('HH:mm').format(shift.startTime)),
              _buildMetric(l10n.endDate.toUpperCase(), shift.endTime != null ? DateFormat('HH:mm').format(shift.endTime!) : l10n.active.toUpperCase()),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(height: 1, color: Colors.white24),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetric(l10n.revenue.toUpperCase(), '$symbol${shift.totalSales.toStringAsFixed(0)}'),
              _buildMetric(l10n.profit.toUpperCase(), '$symbol${shift.totalProfit.toStringAsFixed(0)}'),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetric(l10n.cashDrop.toUpperCase(), '$symbol${shift.cashDrop.toStringAsFixed(0)}'),
              _buildMetric(l10n.cashBalance.toUpperCase(), '$symbol${(shift.totalSales - shift.cashDrop).toStringAsFixed(0)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
