import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../billing/domain/entities/customer.dart';
import '../../../billing/domain/entities/sales_transaction.dart';
import '../../../billing/domain/repositories/sales_repository.dart';
import '../../../billing/domain/repositories/customer_repository.dart';

class CustomerTransactionsPage extends StatefulWidget {
  final String customerId;

  const CustomerTransactionsPage({super.key, required this.customerId});

  @override
  State<CustomerTransactionsPage> createState() => _CustomerTransactionsPageState();
}

class _CustomerTransactionsPageState extends State<CustomerTransactionsPage> {
  Customer? _customer;
  List<SalesTransaction> _transactions = [];
  bool _isLoading = true;
  double _totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _loadCustomerData();
  }

  Future<void> _loadCustomerData() async {
    setState(() => _isLoading = true);
    final l10n = AppLocalizations.of(context)!;

    try {
      // Load customer info
      final customerRepo = context.read<CustomerRepository>();
      final customerResult = await customerRepo.getCustomers();

      customerResult.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.failedToLoadCustomer(failure.toString()))),
          );
        },
        (customers) {
          final customer = customers.firstWhere(
            (c) => c.id == widget.customerId,
            orElse: () => Customer.empty(),
          );
          if (customer.id.isNotEmpty) {
            setState(() => _customer = customer);
          }
        },
      );

      // Load transactions for the last 30 days
      final salesRepo = context.read<SalesRepository>();
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 30));

      final transactionResult = await salesRepo.getSalesByDateRange(startDate, endDate);

      transactionResult.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.noTransactionsFound)),
          );
        },
        (transactions) {
          final customerTransactions = transactions
              .where((t) => t.customerId == widget.customerId)
              .toList();

          setState(() {
            _transactions = customerTransactions;
            _totalAmount = customerTransactions.fold(0.0, (sum, t) => sum + t.totalRevenue);
          });
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.error}: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.customerTransactions),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_customer == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.customerTransactions),
        ),
        body: Center(
          child: Text(l10n.customerNotFound),
        ),
      );
    }

    final currency = Hive.box('settings').get('selectedCurrency', defaultValue: 'TZS');
    final symbol = AppTheme.getCurrencySymbol(currency);

    return Scaffold(
      appBar: AppBar(
        title: Text('${_customer!.name} - ${l10n.transactions}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Theme.of(context).primaryColor),
          onPressed: () { if (context.canPop()) { context.pop(); } else { context.go('/'); } },
        ),
      ),
      body: Column(
        children: [
          // Customer Summary Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.totalTransactions,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      _transactions.length.toString(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.totalAmount,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '$symbol${_totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.numberOfTransactions,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '${_transactions.length}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),

          // Transactions List
          Expanded(
            child: _transactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noTransactionsFound,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = _transactions[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: transaction.status == TransactionStatus.paid
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              transaction.status == TransactionStatus.paid
                                  ? Icons.check_circle
                                  : Icons.pending,
                              color: transaction.status == TransactionStatus.paid
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                          title: Text(
                            l10n.transactionWithId(transaction.id),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                           subtitle: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text(
                                 '${transaction.quantity}x ${transaction.productName}',
                                 style: TextStyle(color: Colors.grey[600]),
                               ),
                               Text(
                                 _formatDate(transaction.createdAt),
                                 style: TextStyle(
                                   fontSize: 12,
                                   color: Colors.grey[500],
                                 ),
                               ),
                             ],
                           ),
                           trailing: Text(
                             '$symbol${transaction.totalRevenue.toStringAsFixed(2)}',
                             style: const TextStyle(
                               fontSize: 16,
                               fontWeight: FontWeight.bold,
                             ),
                           ),
                          onTap: () => _showTransactionDetails(transaction),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showTransactionDetails(SalesTransaction transaction) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.transactionWithId(transaction.id)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${l10n.date}: ${_formatDate(transaction.createdAt)}'),
              Text('${l10n.status}: ${transaction.status.name.toUpperCase()}'),
              const SizedBox(height: 16),
              Text('${l10n.items}:', style: const TextStyle(fontWeight: FontWeight.bold)),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text('${transaction.quantity}x ${transaction.productName} - ${AppTheme.getCurrencySymbol(Hive.box('settings').get('selectedCurrency', defaultValue: 'TZS'))}${transaction.totalRevenue.toStringAsFixed(2)}'),
              ),
              const SizedBox(height: 16),
              Text(
                '${l10n.total}: ${AppTheme.getCurrencySymbol(Hive.box('settings').get('selectedCurrency', defaultValue: 'TZS'))}${transaction.totalRevenue.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

