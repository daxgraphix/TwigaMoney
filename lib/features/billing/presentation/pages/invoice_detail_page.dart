import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../../../../core/utils/pdf_invoice_helper.dart';
import '../../../../core/widgets/page_transitions.dart';
import '../../../../core/theme/app_theme.dart';
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: const BackButtonWidget(),
        title: const Text('Invoice Detail', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: _generateAndSharePdf,
            tooltip: 'Share PDF',
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: _shareInvoice,
            tooltip: 'Share Text',
          ),
        ],
      ),
      body: _transaction == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: AppTheme.softShadow,
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.05)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Invoice',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: (_transaction!.status == TransactionStatus.paid ? Colors.green : Colors.orange).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                _transaction!.status.name.toUpperCase(),
                                style: TextStyle(
                                  color: _transaction!.status == TransactionStatus.paid ? Colors.green : Colors.orange,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '#${_transaction!.id}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildInfoRow(Icons.calendar_today_outlined, 'Date', DateFormat('dd MMM yyyy, HH:mm').format(_transaction!.timestamp)),
                        const SizedBox(height: 12),
                        _buildInfoRow(Icons.person_outline, 'Customer', _transaction!.customerId),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Items',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: AppTheme.softShadow,
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.05)),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.inventory_2_outlined, color: Theme.of(context).primaryColor, size: 20),
                          ),
                          title: Text(_transaction!.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Qty: ${_transaction!.quantity}'),
                          trailing: Text(
                            '$symbol${_transaction!.totalRevenue.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        if (_transaction!.items.isNotEmpty)
                          ..._transaction!.items.map((item) => ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                                title: Text(item),
                                subtitle: const Text('Additional item'),
                              )),
                        const Divider(indent: 20, endIndent: 20),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              _buildAmountRow('Subtotal', '$symbol${_transaction!.totalRevenue.toStringAsFixed(0)}', isBold: false),
                              const SizedBox(height: 8),
                              _buildAmountRow('Total', '$symbol${_transaction!.totalRevenue.toStringAsFixed(0)}', isBold: true),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    onPressed: _shareInvoice,
                    icon: const Icon(Icons.share_outlined, size: 20),
                    label: const Text('SHARE INVOICE'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 8),
        Text('$label: ', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }

  Widget _buildAmountRow(String label, String value, {required bool isBold}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? null : Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 22 : 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isBold ? Theme.of(context).primaryColor : null,
          ),
        ),
      ],
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

  Future<void> _generateAndSharePdf() async {
    if (_transaction == null) return;
    
    try {
      final currency = Hive.box('settings').get('selectedCurrency', defaultValue: 'TZS');
      final symbol = AppTheme.getCurrencySymbol(currency);
      
      final File pdfFile = await PdfInvoiceHelper.generate(_transaction!, symbol);
      
      await Share.shareXFiles(
        [XFile(pdfFile.path)],
        subject: 'Invoice #${_transaction!.id}',
        text: 'Please find the attached invoice.',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate PDF: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
