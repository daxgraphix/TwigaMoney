import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
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
  final DateFormat _dateFmt = DateFormat('dd MMM yyyy');
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

    switch (_dateFilter) {
      case 'This Week':
        start = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'This Month':
        start = DateTime(now.year, now.month, 1);
        break;
      case 'This Year':
        start = DateTime(now.year, 1, 1);
        break;
      default:
        start = null;
    }

    setState(() {
      _filteredTransactions = _allTransactions.where((t) {
        final matchesType = _typeFilter == 'All' ||
            (_typeFilter == 'Income' && t.type == TransactionType.income) ||
            (_typeFilter == 'Expense' && t.type == TransactionType.expense) ||
            (_typeFilter == 'Transfer' && t.type == TransactionType.fundTransfer);
        final matchesDate = start == null || !t.date.isBefore(start);
        final matchesSearch = _searchQuery.isEmpty ||
            t.description.toLowerCase().contains(_searchQuery.toLowerCase());
        return matchesType && matchesDate && matchesSearch;
      }).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () => _exportTransactions(context),
            tooltip: 'Export CSV',
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
                      hintText: 'Search transactions...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
            Expanded(child: _buildTransactionList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-transaction'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: ['All', 'Income', 'Expense', 'Transfer'].map((type) {
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: ['All Time', 'This Week', 'This Month', 'This Year'].map((range) {
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text('No transactions found',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600])),
              ],
            ),
          );
        }

        // Pre-fetch accounts map if not done yet
        if (_accountMap.isEmpty) {
          final accounts = HiveDatabase.accountBox.values.toList();
          _accountMap = {for (final a in accounts) a.id: a};
        }

        return ListView.builder(
          padding: EdgeInsets.fromLTRB(padding, 8, padding, padding + 16),
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
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Transaction'),
                            content: Text('Delete "${tx.description}"?'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel')),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text('Delete',
                                    style: TextStyle(
                                        color: Theme.of(context).colorScheme.error)),
                              ),
                            ],
                          ),
                        ) ??
                        false;
                  },
                  onDismissed: (_) {
                    context.read<TransactionBloc>().add(DeleteTransactionEvent(tx.id));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('"${tx.description}" deleted'),
                          backgroundColor: Colors.green),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: Responsive.getCardElevation(context),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: category.color.withValues(alpha: 0.1),
                        child: Icon(category.icon, color: category.color, size: 20),
                      ),
                      title: Text(tx.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text(
                        '${_dateFmt.format(tx.date)}${account != null ? ' • ${account.name}' : ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        '${isIncome ? '+' : '-'}$_currencySymbol${tx.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
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
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: category.color.withValues(alpha: 0.1),
                  child: Icon(category.icon, color: category.color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(tx.description, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _detailRow('Amount', '$_currencySymbol${tx.amount.toStringAsFixed(2)}'),
            _detailRow('Type', tx.type.name.toUpperCase()),
            _detailRow('Category', category.name),
            if (account != null) _detailRow('Account', account.name),
            _detailRow('Date', _dateFmt.format(tx.date)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/add-transaction', extra: tx);
                    },
                    child: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                      context.read<TransactionBloc>().add(DeleteTransactionEvent(tx.id));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('"${tx.description}" deleted'), backgroundColor: Colors.green),
                      );
                    },
                    child: const Text('Delete', style: TextStyle(color: Colors.white)),
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
    try {
      if (_filteredTransactions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No transactions to export')),
        );
        return;
      }

      List<List<dynamic>> rows = [];
      rows.add(['Date', 'Description', 'Amount', 'Type', 'Category', 'Account']);

      for (var tx in _filteredTransactions) {
        final category = _categoryMap[tx.categoryId];
        final account = _accountMap[tx.accountId];
        rows.add([
          _dateFmt.format(tx.date),
          tx.description,
          tx.amount,
          tx.type.name,
          category?.name ?? 'Unknown',
          account?.name ?? 'Unknown',
        ]);
      }

      String csvData = const ListToCsvConverter().convert(rows);
      final directory = await getTemporaryDirectory();
      final path = "${directory.path}/transactions_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv";
      final file = File(path);
      await file.writeAsString(csvData);

      await Share.shareXFiles([XFile(path)], text: 'TwigaMoney Transaction Export');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e'), backgroundColor: Colors.red),
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
