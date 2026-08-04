import 'package:twigamoney/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/page_transitions.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/data/hive_database.dart';
import '../../domain/entities/account.dart';
import '../../presentation/bloc/account_cubit.dart';

class AccountListPage extends StatefulWidget {
  const AccountListPage({super.key});

  @override
  State<AccountListPage> createState() => _AccountListPageState();
}

class _AccountListPageState extends State<AccountListPage> {
  @override
  void initState() {
    super.initState();
    context.read<AccountCubit>().loadAccounts();
  }

  IconData _accountIcon(AccountType type) {
    switch (type) {
      case AccountType.checking:
        return Icons.account_balance;
      case AccountType.savings:
        return Icons.savings;
      case AccountType.credit:
        return Icons.credit_card;
      case AccountType.investment:
        return Icons.trending_up;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final padding = Responsive.getPadding(context);
    return Scaffold(
      appBar: AppBar(
        leading: const BackButtonWidget(),
        title: Text(l10n.accounts, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: BlocBuilder<AccountCubit, AccountState>(
        builder: (context, state) {
          if (state.isLoading && state.accounts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final accounts = state.accounts.isNotEmpty ? state.accounts : HiveDatabase.accountBox.values.toList();
          final totalBalance = accounts.fold<double>(0.0, (sum, a) => sum + a.balance);
          final currency = AppTheme.getCurrencySymbol(Hive.box('settings').get('selectedCurrency', defaultValue: 'TZS'));

          if (accounts.isEmpty) {
            final l10n = AppLocalizations.of(context)!;
            return EmptyStateWidget(
              icon: Icons.account_balance_outlined,
              title: l10n.noAccountsYet,
              subtitle: l10n.tapToCreateAccount,
              onActionPressed: () => context.push('/edit-account'),
              actionLabel: l10n.addAccount,
            );
          }

          return ListView(
            padding: EdgeInsets.fromLTRB(padding, 16, padding, padding + 16),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: Responsive.getCardElevation(context),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Icon(Icons.account_balance_wallet, color: Theme.of(context).primaryColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l10n.totalBalance, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                                Text('$currency${totalBalance.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(l10n.transactionsWithCount(accounts.length),
                                style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...accounts.map((account) => Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: Responsive.getCardElevation(context),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        child: Icon(_accountIcon(account.type), color: Theme.of(context).primaryColor),
                      ),
                      title: Text(account.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(account.type.name.toUpperCase()),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('$currency${account.balance.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (value) {
                              if (value == 'edit') {
                                context.push('/edit-account', extra: account);
                              } else if (value == 'delete') {
                                _confirmDelete(account);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(value: 'edit', child: Row(children: [const Icon(Icons.edit, size: 20), const SizedBox(width: 8), Text(l10n.edit)])),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(children: [const Icon(Icons.delete, size: 20, color: Colors.red), const SizedBox(width: 8), Text(l10n.delete, style: const TextStyle(color: Colors.red))]),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/edit-account'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(Account account) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAccount),
        content: Text(l10n.confirmDeleteAccount(account.name)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () {
              context.read<AccountCubit>().deleteAccount(account.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(l10n.accountDeleted),
                    backgroundColor: Colors.green),
              );
            },
            child: Text(l10n.delete,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }
}
