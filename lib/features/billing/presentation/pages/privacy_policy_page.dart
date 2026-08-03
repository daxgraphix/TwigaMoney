import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Theme.of(context).primaryColor),
          onPressed: () { if (context.canPop()) { context.pop(); } else { context.go('/'); } },
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Text(
          'Privacy Policy\n\n'
          'At TwigaMoney, we value your privacy. This policy explains how we collect, use, and protect your information.\n\n'
          '- We collect minimal data necessary for app functionality\n'
          '- Your sales data is stored locally on your device\n'
          '- We do not sell or share your data with third parties\n'
          '- All app backups are encrypted\n'
          '- You can export or delete your data at any time\n\n'
          'By using TwigaMoney, you agree to this policy.',
          style: TextStyle(height: 1.6),
        ),
      ),
    );
  }
}

