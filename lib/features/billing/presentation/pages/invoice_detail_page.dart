import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/page_transitions.dart';
import '../../../billing/domain/repositories/sales_repository.dart';
import '../../../billing/domain/entities/sales_transaction.dart';

class InvoiceDetailPage extends StatefulWidget {
  final String invoiceId;

  const InvoiceDetailPage({super.key, required this.invoiceId});

  @override
  State<InvoiceDetailPage> createState() => _InvoiceDetailPageState();
}

class _InvoiceDetailPageState extends State<InvoiceDetailPage> {
  SalesTransaction? _transaction;

  @override
  void initState() {
    super.initState();
    _loadInvoice();
  }

  Future<void> _loadInvoice() async {
    final salesRepo = context.read<SalesRepository>();
    // Assuming invoiceId is transaction id
    final salesResult = await salesRepo.getSalesByDateRange(DateTime(2000), DateTime(2100));
    salesResult.fold(
      (failure) => null,
      (transactions) {
        final found = transactions.where((t) => t.id == widget.invoiceId);
        _transaction = found.isNotEmpty ? found.first : null;
      },
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final currency = Hive.box('settings').get('selectedCurrency', defaultValue: 'TZS');
    final symbol = AppTheme.getCurrencySymbol(currency);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButtonWidget(),
        title: const Text('Invoice Detail'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareInvoice,
            tooltip: 'Share Invoice',
          ),
        ],
      ),
      body: _transaction == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Invoice #${_transaction!.id}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Date: ${DateFormat('dd/MM/yyyy HH:mm').format(_transaction!.timestamp)}'),
                          Text('Customer: ${_transaction!.customerId}'),
                          Text('Status: ${_transaction!.status.name}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Items',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      title: Text(_transaction!.productName),
                      subtitle: Text('Qty: ${_transaction!.quantity}'),
                      trailing: Text('$symbol${_transaction!.totalRevenue.toStringAsFixed(2)}'),
                    ),
                  ),
                  if (_transaction!.items.isNotEmpty)
                    ..._transaction!.items.map((item) => Card(
                          child: ListTile(
                            title: Text(item),
                            subtitle: const Text('Additional item'),
                          ),
                        )),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Subtotal'),
                              Text('$symbol${_transaction!.totalRevenue.toStringAsFixed(2)}'),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '$symbol${_transaction!.totalRevenue.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                   ),
                 ],
               ),
             ),
    );
  }

  void _shareInvoice() {
    if (_transaction == null) return;
    final currency = Hive.box('settings').get('selectedCurrency', defaultValue: 'TZS');
    final symbol = AppTheme.getCurrencySymbol(currency);
    final text = '''
Invoice #${_transaction!.id}
Date: ${DateFormat('dd/MM/yyyy HH:mm').format(_transaction!.timestamp)}
Total: $symbol${_transaction!.totalRevenue.toStringAsFixed(2)}
Thank you for your purchase!
''';
    Share.share(text, subject: 'Invoice #${_transaction!.id}');
  }
}