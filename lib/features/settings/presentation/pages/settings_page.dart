import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:twigamoney/l10n/app_localizations.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/page_transitions.dart';
import '../cubit/settings_cubit.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final primary = AppTheme.primaryColor;

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: const BackButtonWidget(),
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
                    _buildListItem(
                      icon: state.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      title: l10n.darkMode,
                      subtitle: state.isDarkMode ? l10n.enabled : l10n.disabled,
                      trailingWidget: Switch(
                        value: state.isDarkMode,
                        activeThumbColor: primary,
                        onChanged: (value) {
                          context.read<SettingsCubit>().toggleDarkMode(value);
                          AppTheme.themeModeNotifier.value =
                              value ? ThemeMode.dark : ThemeMode.light;
                        },
                      ),
                      onTap: () {
                        final newValue = !state.isDarkMode;
                        context.read<SettingsCubit>().toggleDarkMode(newValue);
                        AppTheme.themeModeNotifier.value =
                            newValue ? ThemeMode.dark : ThemeMode.light;
                      },
                    ),
                    _buildDivider(),
                    _buildListItem(
                      icon: Icons.translate,
                      title: l10n.language,
                      subtitle: state.languageCode == 'en' ? l10n.english : state.languageCode,
                      onTap: () => _showLanguageDialog(context),
                    ),
                    _buildDivider(),
                    _buildListItem(
                      icon: Icons.currency_exchange,
                      title: l10n.currency,
                      subtitle: state.currencyCode,
                      onTap: () => _showCurrencyDialog(context),
                    ),
                    _buildDivider(),
                    _buildListItem(
                      icon: Icons.calendar_today,
                      title: l10n.dateFormat,
                      subtitle: state.dateFormat,
                      onTap: () => _showDateFormatDialog(context),
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
                      onTap: () => context.push('/shop'),
                    ),
                    _buildDivider(),
                    _buildListItem(
                      icon: Icons.person_outline,
                      title: l10n.ownerProfile,
                      subtitle: l10n.ownerProfileDesc,
                      onTap: () => _editUserProfile(state),
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
                      onTap: () {
                        context.read<SettingsCubit>().clearCache();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.cacheClearedSuccessfully)),
                        );
                      },
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
      },
    );
  }

  void _showCurrencyDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.selectCurrency),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.tanzanianShilling),
              onTap: () {
                context.read<SettingsCubit>().setCurrency('TZS');
                Navigator.pop(dialogContext);
              },
            ),
            ListTile(
              title: Text(l10n.usDollar),
              onTap: () {
                context.read<SettingsCubit>().setCurrency('USD');
                Navigator.pop(dialogContext);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDateFormatDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.selectDateFormat),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.dateFormatMedium),
              onTap: () {
                context.read<SettingsCubit>().setDateFormat('dd MMM yyyy');
                Navigator.pop(dialogContext);
              },
            ),
            ListTile(
              title: Text(l10n.dateFormatShort),
              onTap: () {
                context.read<SettingsCubit>().setDateFormat('MM/dd/yyyy');
                Navigator.pop(dialogContext);
              },
            ),
            ListTile(
              title: Text(l10n.dateFormatIso),
              onTap: () {
                context.read<SettingsCubit>().setDateFormat('yyyy-MM-dd');
                Navigator.pop(dialogContext);
              },
            ),
            ListTile(
              title: Text(l10n.dateFormatEuropean),
              onTap: () {
                context.read<SettingsCubit>().setDateFormat('dd/MM/yyyy');
                Navigator.pop(dialogContext);
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.cardColor,
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
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.english),
              onTap: () {
                context.read<SettingsCubit>().setLanguage('en');
                AppTheme.localeNotifier.value = const Locale('en');
                Navigator.pop(dialogContext);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _backupData() async {
    final l10n = AppLocalizations.of(context)!;
    
    // Request storage permissions for Android < 13
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (status.isDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.storagePermissionRequired)),
          );
        }
        return;
      }
    }

    try {
      final json = await context.read<SettingsCubit>().settingsRepository.exportData();
      
      await json.fold(
        (failure) async {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.backupFailed(failure.message)), backgroundColor: Colors.red),
          );
        },
        (jsonString) async {
          final tempDir = await Directory.systemTemp.createTemp();
          final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
          final file = File('${tempDir.path}/TwigaMoney_backup_$timestamp.json');
          await file.writeAsString(jsonString);

          if (mounted) {
            await Share.shareXFiles([XFile(file.path)], text: 'TwigaMoney Backup $timestamp');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.backupCreatedAndShared)),
            );
          }
        },
      );
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
    
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (status.isDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.storagePermissionRequired)),
          );
        }
        return;
      }
    }

    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
              child: Text(l10n.continueButton, style: const TextStyle(color: Colors.white)),
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
      
      final restoreResult = await context.read<SettingsCubit>().settingsRepository.importData(jsonString);

      restoreResult.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.restoreFailed(failure.message)), backgroundColor: Colors.red),
          );
        },
        (_) {
          context.read<SettingsCubit>().loadSettings();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.restoreSuccessful)),
          );
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.restoreFailed(e.toString())), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _editUserProfile(SettingsState state) async {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: state.userName);
    final emailController = TextEditingController(text: state.userEmail);
    final phoneController = TextEditingController(text: state.userPhone);

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<SettingsCubit>().updateProfile(
                name: nameController.text.trim(),
                email: emailController.text.trim(),
                phone: phoneController.text.trim(),
              );

              Navigator.pop(dialogContext);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(l10n.profileUpdatedSuccessfully)),
                );
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}
