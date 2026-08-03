import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/data/hive_database.dart';
import 'package:twigamoney/features/shop/data/models/shop_model.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = AppTheme.primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appearance Section
            _buildSectionHeader(l10n.appearance),
            _buildListGroup(
              children: [
                ValueListenableBuilder<ThemeMode>(
                  valueListenable: AppTheme.themeModeNotifier,
                  builder: (context, themeMode, child) {
                    return _buildListItem(
                      icon: themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
                      title: l10n.darkMode,
                      subtitle: themeMode == ThemeMode.dark ? l10n.enabled : l10n.disabled,
                      trailingWidget: Switch(
                        value: themeMode == ThemeMode.dark,
                        activeColor: primary,
                        onChanged: (value) {
                          AppTheme.themeModeNotifier.value =
                              value ? ThemeMode.dark : ThemeMode.light;
                          Hive.box('settings').put('darkMode', value);
                          Hive.box('settings').put('themeMode',
                              value ? 'dark' : 'light');
                        },
                      ),
                      onTap: () {
                        final isDark = themeMode == ThemeMode.dark;
                        final newMode = isDark ? ThemeMode.light : ThemeMode.dark;
                        AppTheme.themeModeNotifier.value = newMode;
                        Hive.box('settings').put('darkMode', !isDark);
                        Hive.box('settings').put('themeMode', isDark ? 'light' : 'dark');
                      },
                    );
                  },
                ),
                _buildDivider(),
                ValueListenableBuilder<Locale>(
                  valueListenable: AppTheme.localeNotifier,
                  builder: (context, locale, child) {
                    return _buildListItem(
                      icon: Icons.translate,
                      title: l10n.language,
                      subtitle: locale.languageCode == 'sw' ? l10n.swahili : l10n.english,
                      onTap: () => _showLanguageDialog(context),
                    );
                  },
                ),
                _buildDivider(),
                _buildListItem(
                  icon: Icons.currency_exchange,
                  title: l10n.currency,
                  subtitle: Hive.box('settings').get('selectedCurrency', defaultValue: 'TZS'),
                  onTap: () => _showCurrencyDialog(context),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Profile Section
            _buildSectionHeader(l10n.business),
            _buildListGroup(
              children: [
                _buildListItem(
                  icon: Icons.store_outlined,
                  title: l10n.shopDetails,
                  subtitle: l10n.nameAddressContact,
                  onTap: _editShopProfile,
                ),
                _buildDivider(),
                _buildListItem(
                  icon: Icons.person_outline,
                  title: l10n.ownerProfile,
                  subtitle: l10n.ownerProfileDesc,
                  onTap: _editUserProfile,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Data Section
            _buildSectionHeader(l10n.dataManagement),
            _buildListGroup(
              children: [
                _buildListItem(
                  icon: Icons.cloud_upload_outlined,
                  title: l10n.backupData,
                  subtitle: l10n.exportData,
                  onTap: _backupData,
                ),
                _buildDivider(),
                _buildListItem(
                  icon: Icons.cloud_download_outlined,
                  title: l10n.restoreData,
                  subtitle: l10n.restoreFromBackup,
                  onTap: _restoreData,
                ),
                _buildDivider(),
                _buildListItem(
                  icon: Icons.delete_outline,
                  title: l10n.clearCache,
                  subtitle: l10n.clearCacheDesc,
                  onTap: _clearCache,
                ),
              ],
            ),
            
            const SizedBox(height: 32),

            // Support Section
            _buildSectionHeader(l10n.support),
            _buildListGroup(
              children: [
                _buildListItem(
                  icon: Icons.help_outline,
                  title: l10n.helpCenter,
                  subtitle: l10n.helpCenterDesc,
                  onTap: () => context.push('/help-support'),
                ),
                _buildDivider(),
                _buildListItem(
                  icon: Icons.info_outline,
                  title: l10n.aboutTwigaMoney,
                  subtitle: 'v1.0.0',
                  onTap: () => context.push('/about'),
                ),
              ],
            ),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context) {
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
                Hive.box('settings').put('selectedCurrency', 'TZS');
                Navigator.pop(context);
                setState(() {});
              },
            ),
            ListTile(
              title: Text(l10n.usDollar),
              onTap: () {
                Hive.box('settings').put('selectedCurrency', 'USD');
                Navigator.pop(context);
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 24, 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildListGroup({required List<Widget> children}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurfaceColor : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.softShadow,
        border: Border.all(color: isDark ? AppTheme.darkBorderColor : Colors.grey.shade100),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildListItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailingWidget,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primaryColor, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)) : null,
      trailing: trailingWidget ?? const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildDivider() => const Divider(height: 1, indent: 16, endIndent: 16);

  void _showLanguageDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.english),
              onTap: () {
                AppTheme.localeNotifier.value = const Locale('en');
                Hive.box('settings').put('languageCode', 'en');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(l10n.swahili),
              onTap: () {
                AppTheme.localeNotifier.value = const Locale('sw');
                Hive.box('settings').put('languageCode', 'sw');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _backupData() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final backupFile = File('${directory.path}/TwigaMoney_backup_$timestamp.json');

      final products = HiveDatabase.productBox.values.map((p) => p.toJson()).toList();
      final shop = HiveDatabase.shopBox.get('shop_details');
      
      // Finance Data
      final transactions = HiveDatabase.transactionBox.values.map((t) => {
        'id': t.id,
        'description': t.description,
        'amount': t.amount,
        'date': t.date.toIso8601String(),
        'type': t.type.name,
        'categoryId': t.categoryId,
        'accountId': t.accountId,
      }).toList();
      
      final budgets = HiveDatabase.budgetBox.values.map((b) => {
        'id': b.id,
        'name': b.name,
        'amount': b.amount,
        'categoryId': b.categoryId,
        'period': b.period.name,
        'startDate': b.startDate.toIso8601String(),
        'endDate': b.endDate?.toIso8601String(),
        'spent': b.spent,
        'limitAlertThreshold': b.limitAlertThreshold,
      }).toList();
      
      final categories = HiveDatabase.categoryBox.values.map((c) => {
        'id': c.id,
        'name': c.name,
        'colorValue': c.colorValue,
        'iconName': c.iconName,
      }).toList();
      
      final accounts = HiveDatabase.accountBox.values.map((a) => {
        'id': a.id,
        'name': a.name,
        'balance': a.balance,
        'type': a.type,
      }).toList();

      final settingsMap = <String, dynamic>{};
      for (var key in HiveDatabase.settingsBox.keys) {
        settingsMap[key.toString()] = HiveDatabase.settingsBox.get(key);
      }

      final backup = {
        'version': '1.0.0',
        'timestamp': DateTime.now().toIso8601String(),
        'products': products,
        'shop': shop is ShopModel ? shop.toJson() : shop,
        'settings': settingsMap,
        'transactions': transactions,
        'budgets': budgets,
        'categories': categories,
        'accounts': accounts,
      };

      await backupFile.writeAsString(jsonEncode(backup));

      if (mounted) {
        await Share.shareXFiles([XFile(backupFile.path)], text: 'TwigaMoney Backup $timestamp');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.backupCreatedAndShared)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.backupFailed(e.toString())), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _restoreData() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.restoreData),
          content: Text(l10n.restoreDataConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(l10n.continue_, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) return;

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      
      await HiveDatabase.importAllData(jsonString);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.restoreSuccessful)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.restoreFailed(e.toString())), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _clearCache() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final dir = await getTemporaryDirectory();
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.cacheClearedSuccessfully)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorClearingCache(e.toString()))),
      );
    }
  }

  void _editShopProfile() {
    final l10n = AppLocalizations.of(context)!;
    final shopBox = HiveDatabase.shopBox;
    final currentShop = shopBox.get('shop_details');
    final nameController = TextEditingController(text: currentShop?.name ?? '');
    final address1Controller = TextEditingController(text: currentShop?.addressLine1 ?? '');
    final address2Controller = TextEditingController(text: currentShop?.addressLine2 ?? '');
    final phoneController = TextEditingController(text: currentShop?.phoneNumber ?? '');
    final upiController = TextEditingController(text: currentShop?.upiId ?? '');
    final footerController = TextEditingController(text: currentShop?.footerText ?? '');
    final logoController = TextEditingController(text: currentShop?.logoText ?? '');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.shopProfile),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: '${l10n.shopName} *'),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: address1Controller,
                  decoration: InputDecoration(labelText: '${l10n.addressLine1} *'),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: address2Controller,
                  decoration: InputDecoration(labelText: l10n.addressLine2),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: '${l10n.phoneNumber} *',
                    prefixText: '+',
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: upiController,
                  decoration: InputDecoration(
                    labelText: l10n.upiPaymentId,
                    hintText: 'e.g. upi://pay@bank',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: logoController,
                  decoration: InputDecoration(
                    labelText: l10n.shopLogoText,
                    hintText: l10n.textShownOnReceipts,
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: footerController,
                  decoration: InputDecoration(
                    labelText: l10n.receiptFooter,
                    hintText: l10n.thankYouMessage,
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.shopNameRequired), backgroundColor: Colors.red),
                  );
                  return;
                }
                if (address1Controller.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.addressRequired), backgroundColor: Colors.red),
                  );
                  return;
                }
                final updatedShop = ShopModel(
                  id: currentShop?.id ?? 'shop_1',
                  name: nameController.text.trim(),
                  addressLine1: address1Controller.text.trim(),
                  addressLine2: address2Controller.text.trim(),
                  phoneNumber: phoneController.text.trim(),
                  footerText: footerController.text.trim(),
                  upiId: upiController.text.trim(),
                  logoText: logoController.text.trim(),
                );
                shopBox.put('shop_details', updatedShop);
                Navigator.pop(context);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.shopProfileUpdatedSuccessfully)),
                  );
                }
                setState(() {});
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editUserProfile() async {
    final l10n = AppLocalizations.of(context)!;
    final settingsBox = Hive.box('settings');
    final nameController = TextEditingController(
        text: settingsBox.get('userName', defaultValue: ''));
    final emailController = TextEditingController(
        text: settingsBox.get('userEmail', defaultValue: ''));
    final phoneController = TextEditingController(
        text: settingsBox.get('userPhone', defaultValue: ''));

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.myProfile),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: l10n.fullName),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: l10n.emailAddress),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: l10n.phoneNumber),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              settingsBox.put('userName', nameController.text.trim());
              settingsBox.put('userEmail', emailController.text.trim());
              settingsBox.put('userPhone', phoneController.text.trim());

              Navigator.pop(context);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(l10n.profileUpdatedSuccessfully)),
                );
              }
              setState(() {});
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}

