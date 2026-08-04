import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:twigamoney/core/widgets/empty_state_widget.dart';
import 'package:twigamoney/core/widgets/page_transitions.dart';
import 'package:twigamoney/l10n/app_localizations.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/data/hive_database.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/account.dart';
import '../../presentation/bloc/transaction_bloc.dart';
import '../../presentation/bloc/finance_bloc.dart';

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({super.key});

  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  String _typeFilter = 'All';
  String _dateFilter = 'All Time';
  String _searchQuery = '';
  final DateFormat _dateFmt = AppTheme.getDateFormat();
  final TextEditingController _searchController = TextEditingController();

  List<Transaction> _allTransactions = [];
  List<Transaction> _filteredTransactions = [];
  Map<String, Category> _categoryMap = {};
  Map<String, Account> _accountMap = {};
  String _currencySymbol = 'TZS';

  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(LoadTransactionsEvent());
    context.read<FinanceBloc>().add(LoadCategoriesEvent());
    _currencySymbol = AppTheme.getCurrencySymbol(
        Hive.box('settings').get('selectedCurrency', defaultValue: 'TZS'));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateFilteredTransactions() {
    final now = DateTime.now();
    DateTime? start;
    final l10n = AppLocalizations.of(context)!;

    if (_dateFilter == l10n.thisWeek) {
      start = now.subtract(Duration(days: now.weekday - 1));
    } else if (_dateFilter == l10n.thisMonth) {
      start = DateTime(now.year, now.month, 1);
    } else if (_dateFilter == l10n.thisYear) {
      start = DateTime(now.year, 1, 1);
    } else {
      start = null;
    }

    setState(() {
      _filteredTransactions = _allTransactions.where((t) {
        final matchesType = _typeFilter == l10n.all ||
            (_typeFilter == l10n.income && t.type == TransactionType.income) ||
            (_typeFilter == l10n.expenses && t.type == TransactionType.expense) ||
            (_typeFilter == l10n.transfer && t.type == TransactionType.fundTransfer);
        final matchesDate = start == null || !t.date.isBefore(start);
        final matchesSearch = _searchQuery.isEmpty ||
            t.description.toLowerCase().contains(_searchQuery.toLowerCase());
        return matchesType && matchesDate && matchesSearch;
      }).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    if (_typeFilter == 'All') _typeFilter = l10n.all;
    if (_dateFilter == 'All Time') _dateFilter = l10n.allTime;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: const BackButtonWidget(),
        title: Text(l10n.transactions, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () => _exportTransactions(context),
            tooltip: l10n.exportCsv,
          ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<TransactionBloc, TransactionState>(
            listener: (context, state) {
              if (state is TransactionLoaded) {
                _allTransactions = state.transactions;
                _updateFilteredTransactions();
              }
            },
          ),
          BlocListener<FinanceBloc, FinanceState>(
            listener: (context, state) {
              if (state is CategoriesLoaded) {
                setState(() {
                  _categoryMap = {for (final c in state.categories) c.id: c};
                });
              }
            },
          ),
        ],
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: Responsive.getPadding(context), vertical: 8),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: l10n.searchTransactions,
                      prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (val) {
                      _searchQuery = val;
                      _updateFilteredTransactions();
                    },
                  ),
                ),
              ),
            ),
            _buildFilterChips(),
            _buildDateFilterChips(),
            const SizedBox(height: 8),
            Expanded(child: _buildTransactionList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-transaction'),
        elevation: 4,
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }

  Widget _buildFilterChips() {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [l10n.all, l10n.income, l10n.expenses, l10n.transfer].map((type) {
          final isSelected = _typeFilter == type;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(type),
              selected: isSelected,
              onSelected: (_) {
                setState(() => _typeFilter = type);
                _updateFilteredTransactions();
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDateFilterChips() {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [l10n.allTime, l10n.thisWeek, l10n.thisMonth, l10n.thisYear].map((range) {
          final isSelected = _dateFilter == range;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(range),
              selected: isSelected,
              onSelected: (_) {
                setState(() => _dateFilter = range);
                _updateFilteredTransactions();
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTransactionList() {
    final padding = Responsive.getPadding(context);
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, txState) {
        if (txState is TransactionLoading && _filteredTransactions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_filteredTransactions.isEmpty) {
          final l10n = AppLocalizations.of(context)!;
          return EmptyStateWidget(
            icon: _searchQuery.isNotEmpty ? Icons.search_off : Icons.receipt_long_outlined,
            title: _searchQuery.isNotEmpty ? l10n.noTransactionsMatchSearch : l10n.noTransactionsFound,
            subtitle: _searchQuery.isNotEmpty 
              ? l10n.tryAdjustingSearch 
              : l10n.addFirstTransaction,
            onActionPressed: _searchQuery.isNotEmpty 
              ? () => _searchController.clear()
              : () => context.push('/add-transaction'),
            actionLabel: _searchQuery.isNotEmpty ? l10n.clear : l10n.addTransaction,
          );
        }

        // Pre-fetch accounts map if not done yet
        if (_accountMap.isEmpty) {
          final accounts = HiveDatabase.accountBox.values.toList();
          _accountMap = {for (final a in accounts) a.id: a};
        }

        return ListView.builder(
          padding: EdgeInsets.fromLTRB(padding, 8, padding, padding + 80),
          physics: const BouncingScrollPhysics(),
          itemCount: _filteredTransactions.length,
          itemBuilder: (context, index) {
            final tx = _filteredTransactions[index];
            final category = _categoryMap[tx.categoryId] ??
                Category(
                    id: '', name: 'Unknown', colorValue: 0xFF9E9E9E, iconName: 'other');
            final account = _accountMap[tx.accountId];
            final isIncome = tx.type == TransactionType.income;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Dismissible(
                  key: Key(tx.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
                  confirmDismiss: (_) async {
                    final l10n = AppLocalizations.of(context)!;
                    return await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            title: Text(l10n.deleteTransaction),
                            content: Text(l10n.confirmDeleteTransaction(tx.description)),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: Text(l10n.cancel)),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(l10n.delete,
                                    style: TextStyle(
                                        color: Theme.of(context).colorScheme.error)),
                              ),
                            ],
                          ),
                        ) ??
                        false;
                  },
                  onDismissed: (_) {
                    final l10n = AppLocalizations.of(context)!;
                    context.read<TransactionBloc>().add(DeleteTransactionEvent(tx.id));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(l10n.transactionDeleted(tx.description)),
                          backgroundColor: Colors.green),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: AppTheme.softShadow,
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.05)),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: category.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(category.icon, color: category.color, size: 22),
                      ),
                      title: Text(tx.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${_dateFmt.format(tx.date)}${account != null ? ' • ${account.name}' : ''}',
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      ),
                      trailing: Text(
                        '${isIncome ? '+' : '-'}$_currencySymbol${tx.amount.toStringAsFixed(0)}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: isIncome ? Colors.green : Colors.red),
                      ),
                      onTap: () => _showDetailSheet(context, tx, category, account),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDetailSheet(BuildContext context, Transaction tx, Category category, Account? account) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(category.icon, color: category.color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tx.description, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(category.name, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _detailRow(l10n.amount, '$_currencySymbol${tx.amount.toStringAsFixed(2)}'),
            _detailRow(l10n.type, tx.type.name.toUpperCase()),
            _detailRow(l10n.category, category.name),
            if (account != null) _detailRow(l10n.account, account.name),
            _detailRow(l10n.date, _dateFmt.format(tx.date)),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/add-transaction', extra: tx);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: Text(l10n.edit),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.withValues(alpha: 0.1),
                      foregroundColor: Colors.red,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      context.read<TransactionBloc>().add(DeleteTransactionEvent(tx.id));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.transactionDeleted(tx.description)), backgroundColor: Colors.green),
                      );
                    },
                    child: Text(l10n.delete),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportTransactions(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      if (_filteredTransactions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.noTransactionsToExport)),
        );
        return;
      }

      List<List<dynamic>> rows = [];
      rows.add([l10n.date, l10n.description, l10n.amount, l10n.type, l10n.category, l10n.account]);

      for (var tx in _filteredTransactions) {
        final category = _categoryMap[tx.categoryId];
        final account = _accountMap[tx.accountId];
        rows.add([
          _dateFmt.format(tx.date),
          tx.description,
          tx.amount,
          tx.type.name,
          category?.name ?? l10n.unknown,
          account?.name ?? l10n.unknown,
        ]);
      }

      String csvData = const ListToCsvConverter().convert(rows);
      final directory = await getTemporaryDirectory();
      final path = "${directory.path}/transactions_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv";
      final file = File(path);
      await file.writeAsString(csvData);

      await Share.shareXFiles([XFile(path)], text: l10n.transactionExport);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.exportFailed(e.toString())), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
