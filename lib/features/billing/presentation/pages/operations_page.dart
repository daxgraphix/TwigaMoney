import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/data/hive_database.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../finance/domain/entities/transaction.dart';

class OperationsPage extends StatefulWidget {
  const OperationsPage({super.key});

  @override
  State<OperationsPage> createState() => _OperationsPageState();
}

class _OperationsPageState extends State<OperationsPage> {
  @override
  void initState() {
    super.initState();
    // Load initial operations data
    _loadOperationsData();
  }

  void _toggleShift(BuildContext context) {
    final settingsBox = HiveDatabase.settingsBox;
    final newActive = !(settingsBox.get('shiftActive', defaultValue: false) as bool);
    settingsBox.put('shiftActive', newActive);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(newActive ? AppLocalizations.of(context)!.shiftStarted : AppLocalizations.of(context)!.shiftEnded),
        backgroundColor: newActive ? Colors.green : Colors.orange,
      ),
    );
    // Also refresh the UI to show updated state
    setState(() {});
  }

  void _showCashDropDialog(BuildContext context) {
    final controller = TextEditingController();
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.cashDrop),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: l10n.amount,
            prefixText: '${AppTheme.getCurrencySymbol(HiveDatabase.settingsBox.get('selectedCurrency', defaultValue: 'TZS'))} ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount == null || amount <= 0) return;
              final txn = Transaction(
                id: 'cashdrop_${DateTime.now().millisecondsSinceEpoch}',
                description: l10n.cashDrop,
                amount: amount,
                date: DateTime.now(),
                categoryId: 'cash-drop',
                accountId: '',
                type: TransactionType.expense,
              );
              HiveDatabase.transactionBox.add(txn);
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.cashDropRecorded(AppTheme.getCurrencySymbol(HiveDatabase.settingsBox.get('selectedCurrency', defaultValue: 'TZS')), amount.toStringAsFixed(0)))),
              );
            },
            child: Text(l10n.record),
          ),
        ],
      ),
    );
  }

  void _loadOperationsData() {
    // Refresh shift data from Hive
    if (mounted) {
      setState(() {}); // Trigger rebuild to update UI
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.operations),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Theme.of(context).primaryColor),
          onPressed: () { if (context.canPop()) { context.pop(); } else { context.go('/'); } },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadOperationsData(),
            tooltip: AppLocalizations.of(context)!.refreshData,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              EdgeInsets.all(Responsive.getPadding(context)).copyWith(bottom: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Shift Card ──────────────────────────────────────────
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      ValueListenableBuilder<Box>(
                        valueListenable: HiveDatabase.settingsBox.listenable(),
                        builder: (context, box, _) {
                          final isShiftActive =
                              box.get('shiftActive', defaultValue: false) as bool;
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: (isShiftActive ? Colors.green : Colors.orange).withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isShiftActive
                                          ? Icons.play_arrow_rounded
                                          : Icons.pause_rounded,
                                      size: 32,
                                      color: isShiftActive
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isShiftActive
                                              ? AppLocalizations.of(context)!.shiftActiveStatus
                                              : AppLocalizations.of(context)!.shiftClosedStatus,
                                          style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: -0.5),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          isShiftActive
                                              ? AppLocalizations.of(context)!.recordingSales
                                              : AppLocalizations.of(context)!.startShiftToBegin,
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 28),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () => _toggleShift(context),
                                  icon: Icon(isShiftActive
                                      ? Icons.stop_rounded
                                      : Icons.play_arrow_rounded),
                                  label: Text(isShiftActive
                                      ? AppLocalizations.of(context)!.endCurrentShift
                                      : AppLocalizations.of(context)!.startNewShift),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isShiftActive
                                        ? Colors.red
                                        : Colors.green,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 18),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Text(AppLocalizations.of(context)!.quickActions,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
               // Quick Actions - using simple Column + Row for reliability
               Column(
                 children: [
                   Row(
                     children: [
                       Expanded(child: _buildQuickActionCard(AppLocalizations.of(context)!.cashDrop, Icons.money, AppTheme.primaryColor, () => _showCashDropDialog(context))),
                       const SizedBox(width: 12),
                       Expanded(child: _buildQuickActionCard(AppLocalizations.of(context)!.endOfDay, Icons.assessment, AppTheme.primaryColor, () => context.push('/shift-report'))),
                     ],
                   ),
                   const SizedBox(height: 12),
                   Row(
                     children: [
                       Expanded(child: _buildQuickActionCard(AppLocalizations.of(context)!.viewReports, Icons.bar_chart, AppTheme.primaryColor, () => context.go('/reports'))),
                       const SizedBox(width: 12),
                       Expanded(child: _buildQuickActionCard(AppLocalizations.of(context)!.planner, Icons.event_note, AppTheme.primaryColor, () => context.push('/planner'))),
                     ],
                   ),
                 ],
               ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    final isSmallPhone = MediaQuery.of(context).size.width < 380;
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.all(isSmallPhone ? 16 : 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: isSmallPhone ? 22 : 26, color: color),
              ),
              const Spacer(),
              Text(
                title,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                    fontSize: isSmallPhone ? 13 : 15),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${AppLocalizations.of(context)!.action}',
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

