import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:twigamoney/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/page_transitions.dart';
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
        title: Text(l10n.customerTransactions, style: const TextStyle(fontWeight: FontWeight.bold)),
        leading: const BackButtonWidget(),
      ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_customer == null) {
      return Scaffold(
        appBar: AppBar(
        title: Text(l10n.customerTransactions, style: const TextStyle(fontWeight: FontWeight.bold)),
        leading: const BackButtonWidget(),
      ),
        body: Center(
          child: Text(l10n.customerNotFound),
        ),
      );
    }

    final currency = Hive.box('settings').get('selectedCurrency', defaultValue: 'TZS');
    final symbol = AppTheme.getCurrencySymbol(currency);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.transactions, style: const TextStyle(fontWeight: FontWeight.bold)),
        leading: const BackButtonWidget(),
      ),
      body: Column(
        children: [
          // Customer Summary Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: AppTheme.softShadow,
              border: Border.all(color: Colors.grey.withValues(alpha: 0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _customer!.name,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryItem(
                        l10n.totalTransactions,
                        _transactions.length.toString(),
                        Colors.blue,
                      ),
                    ),
                    Container(height: 32, width: 1, color: Colors.grey.withValues(alpha: 0.2), margin: const EdgeInsets.symmetric(horizontal: 16)),
                    Expanded(
                      child: _buildSummaryItem(
                        l10n.totalAmount,
                        '$symbol${_totalAmount.toStringAsFixed(0)}',
                        Colors.red,
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
                        Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noTransactionsFound,
                          style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = _transactions[index];
                      final isPaid = transaction.status == TransactionStatus.paid;
                      final statusColor = isPaid ? Colors.green : Colors.orange;
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: AppTheme.softShadow,
                            border: Border.all(color: Colors.grey.withValues(alpha: 0.05)),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                isPaid ? Icons.check_circle_outline : Icons.pending_outlined,
                                color: statusColor,
                              ),
                            ),
                            title: Text(
                              transaction.productName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                _formatDate(transaction.createdAt),
                                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                              ),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '$symbol${transaction.totalRevenue.toStringAsFixed(0)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Text(
                                  '${transaction.quantity} ${l10n.units}',
                                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                                ),
                              ],
                            ),
                            onTap: () => _showTransactionDetails(transaction),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
      ],
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

