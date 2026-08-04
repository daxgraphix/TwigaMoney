import 'package:flutter/material.dart';
import '../../../../core/widgets/page_transitions.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButtonWidget(),
        title: const Text('Terms & Conditions', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Text(
          'Terms & Conditions\n\n'
          'By using TwigaMoney, you agree to these terms:\n\n'
          '1. You are responsible for maintaining the security of your device.\n'
          '2. You retain ownership of all sales and customer data entered.\n'
          '3. The app is provided "as is" without warranties.\n'
          '4. You may not reproduce or redistribute the app without permission.\n'
          '5. We may update these terms from time to time.\n\n'
          'For questions, contact support@TwigaMoney.com.',
          style: TextStyle(height: 1.6),
        ),
      ),
    );
  }
}

