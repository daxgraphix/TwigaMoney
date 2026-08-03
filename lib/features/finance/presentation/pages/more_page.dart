import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildTile(context, 'Add Transaction', Icons.add_circle_outline, () {
            context.push('/add-transaction');
          }),
          _buildTile(context, 'Categories', Icons.category_outlined, () {
            context.push('/categories');
          }),
          _buildTile(context, 'Analysis', Icons.analytics_outlined, () {
            context.push('/analysis');
          }),
          _buildTile(context, 'Reports', Icons.bar_chart_outlined, () {
            context.push('/reports');
          }),
          _buildTile(context, 'Settings', Icons.settings_outlined, () {
            context.push('/settings');
          }),
          _buildTile(context, 'About', Icons.info_outline, () {
            context.go('/about');
          }),
          _buildTile(context, 'Help', Icons.help_outline, () {
            context.go('/help-support');
          }),
        ],
      ),
    );
  }

  Widget _buildTile(BuildContext context, String title, IconData icon, VoidCallback onTap) {
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
