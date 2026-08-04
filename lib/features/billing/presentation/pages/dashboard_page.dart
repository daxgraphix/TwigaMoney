import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:twigamoney/l10n/app_localizations.dart';
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

  String _getProfitComparison(DashboardState state, String symbol, AppLocalizations l10n) {
    if (state.yesterdayProfit == 0) return '';
    
    final difference = state.todayProfit - state.yesterdayProfit;
    final percentChange = (difference / state.yesterdayProfit) * 100;
    
    final sign = difference >= 0 ? '+' : '';
    return '$sign${percentChange.toStringAsFixed(1)}% vs ${l10n.yesterdaySalesLabel.split(' ').first}';
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
          appBar: null,
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
                    padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 10, 20, 32),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(shopName,
                                    style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.9),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500)),
                                Text(l10n.hello(_getUserDisplayName(l10n)),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Row(
                              children: [
                                _headerActionButton(
                                  icon: Icons.refresh,
                                  onTap: () => context.read<DashboardBloc>().add(
                                      const LoadDashboardDataEvent(forceRefresh: true)),
                                ),
                                const SizedBox(width: 8),
                                _headerActionButton(
                                  icon: Icons.notifications_outlined,
                                  onTap: () {},
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Unified Summary Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: theme.brightness == Brightness.light 
                                ? Colors.white 
                                : AppTheme.darkSurfaceColor,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: IntrinsicHeight(
                            child: Row(
                              children: [
                                Expanded(
                                  child: _summaryItem(
                                    l10n.netPosition,
                                    '$symbol${netPosition.toStringAsFixed(0)}',
                                    netPosition >= 0 ? AppTheme.secondaryColor : Colors.red,
                                    subtitle: '${l10n.today}: $symbol${state.todayRevenue.toStringAsFixed(0)}',
                                  ),
                                ),
                                VerticalDivider(
                                  color: Colors.grey.withValues(alpha: 0.2),
                                  thickness: 1,
                                  width: 32,
                                ),
                                Expanded(
                                  child: _summaryItem(
                                    l10n.profit,
                                    '$symbol${state.todayProfit.toStringAsFixed(0)}',
                                    Colors.green,
                                    subtitle: _getProfitComparison(state, symbol, l10n),
                                  ),
                                ),
                              ],
                            ),
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

  Widget _headerActionButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _summaryItem(String label, String value, Color valueColor, {String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: valueColor,
              letterSpacing: -0.5,
            ),
          ),
        ),
        if (subtitle != null && subtitle.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              color: subtitle.contains('+') ? Colors.green : (subtitle.contains('-') ? Colors.red : Colors.grey[600]),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildKPICard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    final isSmall = MediaQuery.of(context).size.width < 380;
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.softShadow,
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.05)),
      ),
      padding: EdgeInsets.all(isSmall ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: isSmall ? 18 : 20),
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value,
                style: TextStyle(
                    fontSize: isSmall ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    color: theme.colorScheme.onSurface)),
          ),
          const SizedBox(height: 2),
          Text(title,
              style: TextStyle(
                  fontSize: isSmall ? 11 : 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500)),
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
