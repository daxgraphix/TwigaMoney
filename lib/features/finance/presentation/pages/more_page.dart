import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:twigamoney/l10n/app_localizations.dart';
import '../../../../core/utils/responsive.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final crossAxisCount = Responsive.isDesktop(context)
        ? 4
        : (Responsive.isTablet(context) ? 3 : 2);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.more, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Theme.of(context).primaryColor, size: 28),
          onPressed: () { if (context.canPop()) { context.pop(); } else { context.go('/'); } },
        ),
      ),
      body: GridView.count(
        crossAxisCount: crossAxisCount,
        padding: EdgeInsets.all(Responsive.getPadding(context)),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: Responsive.isDesktop(context) ? 1.2 : 1.0,
        children: [
          _buildTile(context, l10n.addTransaction, Icons.add_circle_outline,
              () {
            context.push('/add-transaction');
          }),
          _buildTile(context, l10n.categories, Icons.category_outlined, () {
            context.push('/categories');
          }),
          _buildTile(context, l10n.analysis, Icons.analytics_outlined, () {
            context.push('/analysis');
          }),
          _buildTile(context, l10n.reports, Icons.bar_chart_outlined, () {
            context.push('/reports');
          }),
          _buildTile(context, l10n.financialTools, Icons.calculate_outlined,
              () {
            context.push('/financial-tools');
          }),
          _buildTile(context, l10n.settings, Icons.settings_outlined, () {
            context.push('/settings');
          }),
          _buildTile(context, l10n.about, Icons.info_outline, () {
            context.go('/about');
          }),
          _buildTile(context, l10n.help, Icons.help_outline, () {
            context.go('/help-support');
          }),
        ],
      ),
    );
  }

  Widget _buildTile(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Theme.of(context).primaryColor),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
