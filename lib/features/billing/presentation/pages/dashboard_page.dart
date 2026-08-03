import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../shop/presentation/bloc/shop_bloc.dart';
import '../bloc/dashboard_bloc.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String? _shopNameOverride;

  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(const LoadDashboardDataEvent());

    final shopState = context.read<ShopBloc>().state;
    if (shopState is ShopLoaded && shopState.shop.name.isNotEmpty) {
      _shopNameOverride = shopState.shop.name;
    }
  }

  String _getUserDisplayName(AppLocalizations l10n) {
    final settingsBox = Hive.box('settings');
    final userName =
        (settingsBox.get('userName', defaultValue: '') as String).trim();
    final userEmail =
        (settingsBox.get('userEmail', defaultValue: '') as String).trim();
    if (userName.isNotEmpty) {
      return userName.split(' ').first;
    } else if (userEmail.isNotEmpty) {
      return userEmail.split('@').first;
    }
    return l10n.user;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currency =
        Hive.box('settings').get('selectedCurrency', defaultValue: 'TZS');
    final symbol = AppTheme.getCurrencySymbol(currency);
    final isSmallPhone = MediaQuery.of(context).size.width < 380;
    final theme = Theme.of(context);
    final shopName = _shopNameOverride ?? l10n.myShop;

    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state.isLoading && state.todayRevenue == 0) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.error != null && state.todayRevenue == 0) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<DashboardBloc>()
                        .add(const LoadDashboardDataEvent(forceRefresh: true)),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            ),
          );
        }

        final netPosition = state.totalCashBalance - state.totalOutstandingDebt;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(shopName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => context
                    .read<DashboardBloc>()
                    .add(const LoadDashboardDataEvent(forceRefresh: true)),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              context
                  .read<DashboardBloc>()
                  .add(const LoadDashboardDataEvent(forceRefresh: true));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header / Welcome Section ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                    decoration: const BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l10n.hello(_getUserDisplayName(l10n)),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                  Text(l10n.businessSummary,
                                      style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.notifications_outlined,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        // Net Position Card
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: AppTheme.softShadow,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(l10n.netPosition,
                                        style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 6),
                                    FittedBox(
                                      child: Text(
                                        '$symbol${netPosition.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: netPosition >= 0
                                              ? AppTheme.secondaryColor
                                              : Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 40,
                                width: 1,
                                color: Colors.grey.withValues(alpha: 0.2),
                                margin: const EdgeInsets.symmetric(horizontal: 16),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(l10n.profit,
                                        style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 6),
                                    FittedBox(
                                      child: Text(
                                        '$symbol${state.todayProfit.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.all(Responsive.getPadding(context)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Alerts Section ---
                        if (state.lowStockAlerts.isNotEmpty || state.overdueDebt > 0)
                          _buildInsightAlerts(context, state, l10n, symbol),
                        
                        const SizedBox(height: 16),
                        Text(l10n.keyMetrics,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        GridView.count(
                          crossAxisCount: Responsive.getGridCrossAxisCount(context),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: isSmallPhone ? 1.2 : 1.4,
                          children: [
                            _buildKPICard(
                                context,
                                l10n.revenue,
                                '$symbol${state.todayRevenue.toStringAsFixed(0)}',
                                Icons.payments_outlined,
                                Colors.blue),
                            _buildKPICard(
                                context,
                                l10n.expenses,
                                '$symbol${state.financeExpenses.toStringAsFixed(0)}',
                                Icons.shopping_bag_outlined,
                                Colors.purple),
                            _buildKPICard(
                                context,
                                l10n.cashBalance,
                                '$symbol${state.totalCashBalance.toStringAsFixed(0)}',
                                Icons.account_balance_wallet_outlined,
                                Colors.indigo),
                            _buildKPICard(
                                context,
                                l10n.customerDebt,
                                '$symbol${state.totalOutstandingDebt.toStringAsFixed(0)}',
                                Icons.people_outline,
                                Colors.orange),
                          ],
                        ),

                        const SizedBox(height: 24),
                        Text(l10n.quickActions,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        GridView.count(
                          crossAxisCount: Responsive.getGridCrossAxisCount(context),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: isSmallPhone ? 1.0 : 1.1,
                          children: [
                            _buildQuickActionCard(
                                context,
                                l10n.newSale,
                                l10n.sellItems,
                                Icons.add_shopping_cart,
                                Colors.orange,
                                () => context.push('/new-sale')),
                            _buildQuickActionCard(
                                context,
                                l10n.operations,
                                l10n.dailyTasks,
                                Icons.business_center,
                                Colors.brown,
                                () => context.push('/operations')),
                            _buildQuickActionCard(
                                context,
                                l10n.inventory,
                                l10n.manageStock,
                                Icons.inventory_2_outlined,
                                Colors.blue,
                                () => context.push('/products')),
                            _buildQuickActionCard(
                                context,
                                l10n.analytics,
                                l10n.fullReports,
                                Icons.insert_chart_outlined,
                                Colors.green,
                                () => context.go('/reports')),
                            _buildQuickActionCard(
                                context,
                                l10n.customers,
                                l10n.manageDebt,
                                Icons.group_outlined,
                                Colors.purple,
                                () => context.push('/customers')),
                            _buildQuickActionCard(
                                context,
                                l10n.planner,
                                l10n.tasksAndNotes,
                                Icons.event_note_outlined,
                                Colors.teal,
                                () => context.push('/planner')),
                          ],
                        ),
                        const SizedBox(height: 80), // Extra space for scrolling
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInsightAlerts(BuildContext context, DashboardState state, AppLocalizations l10n, String symbol) {
    return Column(
      children: [
        if (state.overdueDebt > 0)
          _buildWarningCard(
            l10n.overdueCollections,
            l10n.overdueDebtMessage(symbol, state.overdueDebt.toStringAsFixed(0)),
            Icons.error_outline,
            Colors.red,
            () => context.push('/customers'),
          ),
        if (state.lowStockAlerts.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _buildWarningCard(
              l10n.lowStockWarning,
              l10n.lowStockMessage(state.lowStockAlerts.length),
              Icons.warning_amber_rounded,
              Colors.orange,
              () => context.push('/products'),
            ),
          ),
      ],
    );
  }

  Widget _buildKPICard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    final isSmall = MediaQuery.of(context).size.width < 380;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.softShadow,
        border: Border.all(color: color.withValues(alpha: 0.05)),
      ),
      padding: EdgeInsets.all(isSmall ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: isSmall ? 18 : 22),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(value,
                    style: TextStyle(
                        fontSize: isSmall ? 18 : 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface)),
              ),
              const SizedBox(height: 4),
              Text(title,
                  style: TextStyle(
                      fontSize: isSmall ? 11 : 13,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(BuildContext context, String title,
      String subtitle, IconData icon, Color color, VoidCallback onTap) {
    final isSmall = MediaQuery.of(context).size.width < 380;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: EdgeInsets.all(isSmall ? 14 : 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppTheme.softShadow,
            border: Border.all(color: Colors.grey.withValues(alpha: 0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: isSmall ? 20 : 24),
              ),
              const Spacer(),
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isSmall ? 14 : 15,
                      color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: TextStyle(
                      fontSize: isSmall ? 11 : 12, color: Colors.grey[500]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWarningCard(String title, String message, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: color, fontSize: 14)),
                  Text(message,
                      style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.8))),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}
