import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
        appBar: AppBar(title: const Text('Shift Report')),
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
        title: Text('Shift Report: ${shiftId.substring(0, 8)}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(context, shift, symbol, isDark),
            const SizedBox(height: 24),
            const Text(
              'Shift Transactions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (transactions.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text('No transactions recorded in this shift'),
              ))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final tx = transactions[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkSurfaceColor : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? AppTheme.darkBorderColor : Colors.grey.shade200),
                    ),
                    child: ListTile(
                      title: Text(tx.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(DateFormat('HH:mm').format(tx.timestamp)),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('$symbol${tx.totalRevenue.toStringAsFixed(0)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('${tx.quantity} units', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, Shift shift, String symbol, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetric('START TIME', DateFormat('HH:mm').format(shift.startTime)),
              _buildMetric('END TIME', shift.endTime != null ? DateFormat('HH:mm').format(shift.endTime!) : 'ACTIVE'),
            ],
          ),
          const Divider(height: 32, color: Colors.white24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetric('TOTAL SALES', '$symbol${shift.totalSales.toStringAsFixed(0)}'),
              _buildMetric('TOTAL PROFIT', '$symbol${shift.totalProfit.toStringAsFixed(0)}'),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetric('CASH DROPS', '$symbol${shift.cashDrop.toStringAsFixed(0)}'),
              _buildMetric('NET CASH', '$symbol${(shift.totalSales - shift.cashDrop).toStringAsFixed(0)}'),
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
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
