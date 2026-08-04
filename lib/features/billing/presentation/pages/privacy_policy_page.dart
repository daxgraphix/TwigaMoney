import 'package:flutter/material.dart';
import '../../../../core/widgets/page_transitions.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButtonWidget(),
        title: const Text('Privacy Policy', style: TextStyle(fontWeight: FontWeight.bold)),
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

