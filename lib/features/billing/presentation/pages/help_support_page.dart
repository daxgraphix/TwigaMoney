import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  Future<void> _launchMail(String address) async {
    final uri = Uri(scheme: 'mailto', path: address);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchPhone(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.helpSupport),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Theme.of(context).primaryColor),
          onPressed: () { if (context.canPop()) { context.pop(); } else { context.go('/'); } },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.faq, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ExpansionTile(
            title: Text(l10n.faqAddProductTitle),
            children: [Padding(padding: const EdgeInsets.all(16), child: Text(l10n.faqAddProductContent))],
          ),
          ExpansionTile(
            title: Text(l10n.faqProcessSaleTitle),
            children: [Padding(padding: const EdgeInsets.all(16), child: Text(l10n.faqProcessSaleContent))],
          ),
          ExpansionTile(
            title: Text(l10n.faqBackupDataTitle),
            children: [Padding(padding: const EdgeInsets.all(16), child: Text(l10n.faqBackupDataContent))],
          ),
          ExpansionTile(
            title: Text(l10n.faqDarkModeTitle),
            children: [Padding(padding: const EdgeInsets.all(16), child: Text(l10n.faqDarkModeContent))],
          ),
          ExpansionTile(
            title: Text(l10n.faqShopProfileTitle),
            children: [Padding(padding: const EdgeInsets.all(16), child: Text(l10n.faqShopProfileContent))],
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.contact_support),
            title: Text(l10n.contactSupport),
            subtitle: const Text('support@TwigaMoney.com'),
            trailing: const Icon(Icons.launch),
            onTap: () => _launchMail('support@TwigaMoney.com'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.phone),
            title: Text(l10n.phone),
            subtitle: const Text('+255 700 000 000'),
            trailing: const Icon(Icons.launch),
            onTap: () => _launchPhone('+255700000000'),
          ),
          const Divider(),
            ListTile(
              leading: const Icon(Icons.video_call),
              title: Text(l10n.videoTutorial),
              subtitle: Text(l10n.watchHowToUse),
              trailing: const Icon(Icons.launch),
              onTap: () => context.push('/planner'), // For now, link to planner as video tutorial placeholder
            ),
          const Divider(),
            ListTile(
              leading: const Icon(Icons.book),
              title: Text(l10n.documentation),
              subtitle: Text(l10n.readUserGuide),
              trailing: const Icon(Icons.launch),
              onTap: () => context.push('/about'), // For now, link to about as documentation placeholder
            ),
        ],
      ),
    );
  }
}

