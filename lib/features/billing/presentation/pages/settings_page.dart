import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:twigamoney/l10n/app_localizations.dart';
import '../../../../core/data/hive_database.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/page_transitions.dart';
import '../../../billing/domain/repositories/sales_repository.dart';
import '../../../billing/domain/entities/sales_transaction.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late String _selectedCurrency;
  late String _selectedDateFormat;
  late String _selectedLanguage;
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final settingsBox = Hive.box('settings');
    _selectedCurrency = settingsBox.get('selectedCurrency', defaultValue: 'TZS');
    _selectedDateFormat = settingsBox.get('dateFormat', defaultValue: 'dd MMM yyyy');
    _selectedLanguage = settingsBox.get('languageCode', defaultValue: 'en');
    // Read darkMode bool first, then fall back to themeMode string for backward compat
    _isDarkMode = settingsBox.get('darkMode',
            defaultValue: settingsBox.get('themeMode', defaultValue: 'light') == 'dark') as bool;
  }

  void _saveSetting(String key, dynamic value) {
    Hive.box('settings').put(key, value);
    setState(() {
      if (key == 'selectedCurrency') _selectedCurrency = value;
      if (key == 'dateFormat') _selectedDateFormat = value;
      if (key == 'languageCode') _selectedLanguage = value;
      if (key == 'isDarkMode') {
        _isDarkMode = value;
        Hive.box('settings').put('themeMode', value ? 'dark' : 'light');
        Hive.box('settings').put('darkMode', value);
        AppTheme.themeModeNotifier.value =
            value ? ThemeMode.dark : ThemeMode.light;
      }
    });
  }

  void _showLanguageDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectLanguage),
        content: RadioGroup<String>(
          groupValue: _selectedLanguage,
          onChanged: (value) {
            if (value != null) {
              _saveSetting('languageCode', value);
              AppTheme.localeNotifier.value = Locale(value);
              Navigator.pop(context);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: Text(l10n.english),
                value: 'en',
              ),
              RadioListTile<String>(
                title: Text(l10n.swahili),
                value: 'sw',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCurrencyDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectCurrency),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.tanzanianShilling),
              onTap: () {
                _saveSetting('selectedCurrency', 'TZS');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(l10n.usDollar),
              onTap: () {
                _saveSetting('selectedCurrency', 'USD');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDateFormatDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectDateFormat),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.dateFormatMedium),
              onTap: () {
                _saveSetting('dateFormat', 'dd MMM yyyy');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(l10n.dateFormatShort),
              onTap: () {
                _saveSetting('dateFormat', 'MM/dd/yyyy');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(l10n.dateFormatIso),
              onTap: () {
                _saveSetting('dateFormat', 'yyyy-MM-dd');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(l10n.dateFormatEuropean),
              onTap: () {
                _saveSetting('dateFormat', 'dd/MM/yyyy');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        leading: const BackButtonWidget(),
      ),
      body: ListView(
        padding: EdgeInsets.all(Responsive.getPadding(context)),
        children: [
          _SettingSection(title: l10n.profile, children: [_SettingTile(icon: Icons.person, title: l10n.editProfile, subtitle: l10n.updateProfileInfo, onTap: _showProfileDialog), _SettingTile(icon: Icons.lock, title: l10n.changePassword, subtitle: l10n.updateYourPassword, onTap: _showPasswordDialog),]), const SizedBox(height: 16), _SettingSection(title: l10n.general,
            children: [
              _SettingTile(
                icon: Icons.language,
                title: l10n.language,
                subtitle: _selectedLanguage == 'sw' ? l10n.swahili : l10n.english,
                onTap: _showLanguageDialog,
              ),
              _SettingTile(
                icon: Icons.currency_exchange,
                title: l10n.currency,
                subtitle: _selectedCurrency,
                onTap: _showCurrencyDialog,
              ),
              _SettingTile(
                icon: Icons.calendar_today,
                title: l10n.dateFormat,
                subtitle: _selectedDateFormat,
                onTap: _showDateFormatDialog,
              ),
              _SettingTile(
                icon: Icons.dark_mode,
                title: l10n.darkMode,
                trailing: Switch(
                  value: _isDarkMode,
                  onChanged: (value) => _saveSetting('isDarkMode', value),
                  activeThumbColor: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingSection(
            title: l10n.exports,
            children: [
              _SettingTile(
                icon: Icons.picture_as_pdf,
                title: l10n.exportInvoices,
                subtitle: l10n.exportAsPdf,
                onTap: _exportAllInvoices,
              ),
              _SettingTile(
                icon: Icons.share,
                title: l10n.shareData,
                subtitle: l10n.exportAllData,
                onTap: _exportAllData,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingSection(
            title: l10n.data,
            children: [
              _SettingTile(
                icon: Icons.backup,
                title: l10n.backupData,
                subtitle: l10n.backupToCloud,
                onTap: _backupData,
              ),
              _SettingTile(
                icon: Icons.restore,
                title: l10n.restoreData,
                subtitle: l10n.restoreFromBackup,
                onTap: _restoreData,
              ),
              _SettingTile(
                icon: Icons.delete_sweep,
                title: l10n.clearCache,
                subtitle: l10n.freeUpSpace,
                onTap: _clearCache,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingSection(
            title: l10n.about,
            children: [
              _SettingTile(
                icon: Icons.info,
                title: l10n.aboutApp,
                onTap: _showAbout,
              ),
              _SettingTile(
                icon: Icons.description,
                title: l10n.termsConditions,
                onTap: () => context.push('/terms'),
              ),
              _SettingTile(
                icon: Icons.security,
                title: l10n.privacyPolicy,
                onTap: () => context.push('/privacy'),
              ),
              _SettingTile(
                icon: Icons.help,
                title: l10n.helpSupport,
                onTap: () => context.push('/help-support'),
              ),
            ],
          ),
           const SizedBox(height: 24),
           ElevatedButton(
             onPressed: () {
               showDialog(
                 context: context,
                 builder: (context) => AlertDialog(
                   title: Text(l10n.clearAllData),
                   content: Text(l10n.confirmClearAllData),
                   actions: [
                     TextButton(
                       onPressed: () => Navigator.pop(context),
                       child: Text(l10n.cancel),
                     ),
                     TextButton(
                       onPressed: () {
                         Navigator.pop(context);
                         _clearAllData();
                       },
                       child: Text(l10n.clearAll, style: const TextStyle(color: Colors.red)),
                     ),
                   ],
                 ),
               );
             },
             style: ElevatedButton.styleFrom(
               backgroundColor: Colors.red,
               foregroundColor: Colors.white,
               padding: const EdgeInsets.symmetric(vertical: 16),
             ),
             child: Text(l10n.clearAllData),
           ),
         ],
       ),
     );
   }

  void _showProfileDialog() { 
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: Hive.box('settings').get('userName', defaultValue: 'User')); 
    final emailController = TextEditingController(text: Hive.box('settings').get('userEmail', defaultValue: '')); 
    showDialog(context: context, builder: (context) => AlertDialog(title: Text(l10n.editProfile), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: nameController, decoration: InputDecoration(labelText: l10n.fullName)), const SizedBox(height: 16), TextField(controller: emailController, decoration: InputDecoration(labelText: l10n.emailAddress))]), actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)), ElevatedButton(onPressed: () { Hive.box('settings').put('userName', nameController.text); Hive.box('settings').put('userEmail', emailController.text); Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.profileUpdatedSuccessfully))); }, child: Text(l10n.save))])); 
  } 
  
  void _showPasswordDialog() { 
    final l10n = AppLocalizations.of(context)!;
    final passwordController = TextEditingController(); 
    showDialog(context: context, builder: (context) => AlertDialog(title: Text(l10n.changePassword), content: Column(mainAxisSize: MainAxisSize.min, children: [Text(l10n.enterNewPassword), const SizedBox(height: 16), TextField(controller: passwordController, obscureText: true, decoration: InputDecoration(labelText: l10n.newPassword))]), actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)), ElevatedButton(onPressed: () { if (passwordController.text.length >= 6) { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.passwordUpdated))); } else { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.passwordMinLength))); } }, child: Text(l10n.edit))])); 
  } 
  
  Future<void> _exportAllInvoices() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final salesRepo = context.read<SalesRepository>();
      final salesResult = await salesRepo.getSalesByDateRange(DateTime(2000), DateTime.now());
      final transactions = salesResult.fold(
        (_) => <SalesTransaction>[],
        (list) => list,
      );

      if (transactions.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.noInvoicesToExport)),
          );
        }
        return;
      }

      final pdf = pw.Document();
       pdf.addPage(
         pw.Page(
           build: (pw.Context context) => pw.Column(
             crossAxisAlignment: pw.CrossAxisAlignment.start,
             children: [
               pw.Text(
                 l10n.invoiceExportTitle,
                 style: pw.TextStyle(
                   fontSize: 20,
                   fontWeight: pw.FontWeight.bold,
                 ),
               ),
              pw.SizedBox(height: 20),
              ...transactions.map(
                (t) => pw.Text(
                  'Invoice #${t.id} | ${t.productName} | Qty: ${t.quantity} | '
                  'Revenue: ${t.totalRevenue.toStringAsFixed(2)} | '
                  'Date: ${t.timestamp.toString().split(' ').first}',
                ),
              ),
            ],
          ),
        ),
      );

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/invoices_export_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());

      await Share.shareXFiles([XFile(file.path)], text: l10n.invoiceExportTitle);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(l10n.invoicesExportedAndShared(transactions.length))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.error}: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _exportAllData() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final salesRepo = context.read<SalesRepository>();
      final salesResult = await salesRepo.getSalesByDateRange(DateTime(2000), DateTime.now());
      final transactions = salesResult.fold(
        (_) => <SalesTransaction>[],
        (list) => list,
      );

      final csvData = [
        <String>['ID', 'Product', 'Qty', 'Revenue', 'Date'],
        ...transactions.map(
          (t) => <String>[
            t.id,
            t.productName,
            t.quantity.toString(),
            t.totalRevenue.toStringAsFixed(2),
            t.timestamp.toIso8601String(),
          ],
        ),
      ];

       final csv = const ListToCsvConverter().convert(csvData);
       final dir = await getTemporaryDirectory();
       final file = File(
           '${dir.path}/twigamoney_data_${DateTime.now().millisecondsSinceEpoch}.csv');
       await file.writeAsString(csv);

       await Share.shareXFiles([XFile(file.path)], text: l10n.backupData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(l10n.recordsExportedAsCsv(transactions.length))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.error}: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _backupData() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.backingUpData)),
      );
      final jsonData = await HiveDatabase.exportAllData();
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/twigamoney_backup_${DateTime.now().millisecondsSinceEpoch}.json',
      );
      await file.writeAsString(jsonData);
      await Share.shareXFiles(
        [XFile(file.path)],
        text: l10n.backupData,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.backupCompleted)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.backupFailed(e.toString())}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _restoreData() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) {
        return;
      }

      final backupFile = File(result.files.single.path!);
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.restoreBackup),
          content: Text(
            l10n.restoreConfirmMessage(backupFile.path.split('/').last),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(l10n.restore, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      final jsonString = await backupFile.readAsString();
      await HiveDatabase.importAllData(jsonString);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.restoreSuccessful)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.restoreFailed(e.toString())}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _clearCache() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.clearCache),
        content: Text(l10n.clearCacheConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.clear),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final dir = await getTemporaryDirectory();
      final tempDir = Directory(dir.path);
      await for (final entity in tempDir.list()) {
        if (entity is File) {
          await entity.delete();
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.cacheCleared)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.errorClearingCache(e.toString())}'), backgroundColor: Colors.red),
        );
      }
    }
  }

   void _showAbout() {
      final l10n = AppLocalizations.of(context)!;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.aboutTwigaMoney),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Text(
                '${l10n.appName} ${l10n.version} 1.0.0\n\n'
                '${l10n.appDescription}\n\n'
                '${l10n.copyright}',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.close),
            ),
          ],
        ),
      );
    }

   void _clearAllData() async {
     final l10n = AppLocalizations.of(context)!;
     final confirmed = await showDialog<bool>(
       context: context,
       builder: (ctx) => AlertDialog(
         title: Text(l10n.clearAllData),
         content: Text(l10n.confirmClearAllData),
         actions: [
           TextButton(
             onPressed: () => Navigator.pop(ctx, false),
             child: Text(l10n.cancel),
           ),
           ElevatedButton(
             onPressed: () => Navigator.pop(ctx, true),
             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
             child: Text(l10n.clearAll, style: const TextStyle(color: Colors.white)),
           ),
         ],
       ),
     );

     if (confirmed != true) return;

     try {
       await HiveDatabase.clearAllBoxes();
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(l10n.allDataCleared)),
         );
       }
     } catch (e) {
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(l10n.failedToClearData(e.toString())), backgroundColor: Colors.red),
         );
       }
     }
   }
}

class _SettingSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (trailing != null) {
      return ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: trailing,
        onTap: onTap,
      );
    }

    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}



