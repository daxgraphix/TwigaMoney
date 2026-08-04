import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

import 'package:twigamoney/l10n/app_localizations.dart';

class MainNavigationShell extends StatelessWidget {
  final Widget child;

  const MainNavigationShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final l10n = AppLocalizations.of(context)!;

    int currentIndex = 0;
    if (location == '/') {
      currentIndex = 0;
    } else if (location.startsWith('/new-sale')) {
      currentIndex = 1;
    } else if (location.startsWith('/transactions') ||
        location.startsWith('/budgets') ||
        location.startsWith('/accounts') ||
        location.startsWith('/categories') ||
        location.startsWith('/analysis')) {
      currentIndex = 2;
    } else if (location.startsWith('/products')) {
      currentIndex = 3;
    } else if (location.startsWith('/more') || 
               location.startsWith('/settings') || 
               location.startsWith('/reports') ||
               location.startsWith('/about')) {
      currentIndex = 4;
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          elevation: 0,
          backgroundColor: isDark ? AppTheme.darkSurfaceColor : Colors.white,
          indicatorColor: AppTheme.primaryColor.withValues(alpha: 0.1),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          height: 65,
          onDestinationSelected: (index) {
            if (index == currentIndex) return;
            
            switch (index) {
              case 0:
                context.go('/');
                break;
              case 1:
                context.go('/new-sale');
                break;
              case 2:
                context.go('/transactions');
                break;
              case 3:
                context.go('/products');
                break;
              case 4:
                context.go('/more');
                break;
            }
          },
          destinations: [
            _buildDestination(
              icon: Icons.dashboard_outlined,
              selectedIcon: Icons.dashboard,
              label: l10n.dashboard,
              isSelected: currentIndex == 0,
            ),
            _buildDestination(
              icon: Icons.point_of_sale_outlined,
              selectedIcon: Icons.point_of_sale,
              label: l10n.sales,
              isSelected: currentIndex == 1,
            ),
            _buildDestination(
              icon: Icons.account_balance_wallet_outlined,
              selectedIcon: Icons.account_balance_wallet,
              label: l10n.finance,
              isSelected: currentIndex == 2,
            ),
            _buildDestination(
              icon: Icons.inventory_2_outlined,
              selectedIcon: Icons.inventory_2,
              label: l10n.inventory,
              isSelected: currentIndex == 3,
            ),
            _buildDestination(
              icon: Icons.more_horiz_outlined,
              selectedIcon: Icons.more_horiz,
              label: l10n.more,
              isSelected: currentIndex == 4,
            ),
          ],
        ),
      ),
    );
  }

  NavigationDestination _buildDestination({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required bool isSelected,
  }) {
    return NavigationDestination(
      icon: Icon(icon, color: Colors.grey),
      selectedIcon: Icon(selectedIcon, color: AppTheme.primaryColor),
      label: label,
    );
  }
}
