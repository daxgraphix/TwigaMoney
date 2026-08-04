import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/data/hive_database.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/page_transitions.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../finance/domain/entities/transaction.dart';

import '../../domain/entities/shift.dart';

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
    final shiftBox = HiveDatabase.shiftBox;
    final isShiftActive = settingsBox.get('shiftActive', defaultValue: false) as bool;
    
    final newActive = !isShiftActive;
    
    if (newActive) {
      // Starting a new shift
      final newShift = Shift(
        id: 'shift_${DateTime.now().millisecondsSinceEpoch}',
        startTime: DateTime.now(),
        cashierId: 'default_cashier', // In a real app, get current user id
      );
      shiftBox.put('current_shift', newShift);
      settingsBox.put('currentShiftId', newShift.id);
    } else {
      // Ending current shift
      final currentShift = shiftBox.get('current_shift');
      if (currentShift != null) {
        final endedShift = currentShift.copyWith(
          endTime: DateTime.now(),
        );
        // Save to history and clear current
        shiftBox.put(currentShift.id, endedShift);
        shiftBox.delete('current_shift');
      }
    }

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
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.money, color: AppTheme.primaryColor, size: 24),
            ),
            const SizedBox(width: 16),
            Text(l10n.cashDrop, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.amount,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: '0.00',
                prefixIcon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppTheme.getCurrencySymbol(HiveDatabase.settingsBox.get('selectedCurrency', defaultValue: 'TZS')),
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(width: 1, height: 24, color: theme.dividerColor),
                    ],
                  ),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(l10n.cancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(controller.text);
                    if (amount == null || amount <= 0) return;
                    
                    // Record in transactions
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
                    
                    // Update current shift cash drop
                    final shiftBox = HiveDatabase.shiftBox;
                    final currentShift = shiftBox.get('current_shift');
                    if (currentShift != null) {
                      shiftBox.put('current_shift', currentShift.copyWith(
                        cashDrop: currentShift.cashDrop + amount,
                      ));
                    }

                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.cashDropRecorded(AppTheme.getCurrencySymbol(HiveDatabase.settingsBox.get('selectedCurrency', defaultValue: 'TZS')), amount.toStringAsFixed(0))),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(l10n.record),
                ),
              ),
            ],
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
        title: Text(AppLocalizations.of(context)!.operations, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        leading: const BackButtonWidget(),
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
          physics: const BouncingScrollPhysics(),
          padding:
              EdgeInsets.all(Responsive.getPadding(context)).copyWith(bottom: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Shift Card ──────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Card(
                  margin: EdgeInsets.zero,
                  elevation: 0,
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
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              ),

              const SizedBox(height: 32),
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(AppLocalizations.of(context)!.quickActions,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
               // Quick Actions - using simple Column + Row for reliability
               Column(
                 children: [
                   Row(
                     children: [
                       Expanded(child: _buildQuickActionCard(AppLocalizations.of(context)!.cashDrop, Icons.money, AppTheme.primaryColor, () => _showCashDropDialog(context))),
                       const SizedBox(width: 12),
                       Expanded(child: _buildQuickActionCard(AppLocalizations.of(context)!.endOfDay, Icons.assessment, AppTheme.primaryColor, () {
                         final shiftId = HiveDatabase.settingsBox.get('currentShiftId', defaultValue: 'default');
                         context.push('/shift-report?id=$shiftId');
                       })),
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

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.softShadow,
      ),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.05)),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: EdgeInsets.all(isSmallPhone ? 16 : 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, size: isSmallPhone ? 24 : 28, color: color),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                      fontSize: isSmallPhone ? 14 : 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  '${AppLocalizations.of(context)!.action}',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

