import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../../features/billing/domain/entities/sales_transaction.dart';

class PdfInvoiceHelper {
  static Future<File> generate(SalesTransaction transaction, String symbol) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildHeader(transaction),
            pw.SizedBox(height: 30),
            _buildCustomerInfo(transaction),
            pw.SizedBox(height: 30),
            _buildInvoiceTable(transaction, symbol),
            pw.Divider(thickness: 1, color: PdfColors.grey300),
            pw.SizedBox(height: 20),
            _buildTotal(transaction, symbol),
            pw.Spacer(),
            _buildFooter(),
          ],
        ),
      ),
    );

    return saveDocument(name: 'invoice_${transaction.id}.pdf', pdf: pdf);
  }

  static pw.Widget _buildHeader(SalesTransaction transaction) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('TwigaMoney', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 24, color: PdfColors.orange700)),
            pw.Text('Your Business, Simplified', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('INVOICE', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 32, color: PdfColors.grey900)),
            pw.Text('#${transaction.id}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14, color: PdfColors.grey700)),
            pw.Text(DateFormat('dd MMM yyyy').format(transaction.timestamp), style: const pw.TextStyle(fontSize: 12)),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildCustomerInfo(SalesTransaction transaction) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Bill To:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
        pw.SizedBox(height: 4),
        pw.Text(transaction.customerId.isNotEmpty ? transaction.customerId : 'Guest Customer', 
            style: const pw.TextStyle(fontSize: 14)),
      ],
    );
  }

  static pw.Widget _buildInvoiceTable(SalesTransaction transaction, String symbol) {
    final headers = ['Description', 'Qty', 'Unit Price', 'Total'];
    
    final data = [
      [
        transaction.productName,
        '${transaction.quantity}',
        '$symbol ${(transaction.totalRevenue / transaction.quantity).toStringAsFixed(2)}',
        '$symbol ${transaction.totalRevenue.toStringAsFixed(2)}',
      ]
    ];

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: null,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.orange700),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
      },
    );
  }

  static pw.Widget _buildTotal(SalesTransaction transaction, String symbol) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Row(
        children: [
          pw.Spacer(flex: 6),
          pw.Expanded(
            flex: 4,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildTotalRow('Subtotal', '$symbol ${transaction.totalRevenue.toStringAsFixed(2)}'),
                pw.SizedBox(height: 4),
                pw.Divider(color: PdfColors.grey300),
                pw.SizedBox(height: 4),
                _buildTotalRow('Total', '$symbol ${transaction.totalRevenue.toStringAsFixed(2)}', isBold: true, fontSize: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTotalRow(String label, String value, {bool isBold = false, double fontSize = 14}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal, fontSize: fontSize)),
        pw.Text(value, style: pw.TextStyle(fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal, fontSize: fontSize)),
      ],
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 10),
        pw.Center(
          child: pw.Text('Thank you for your business!', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
        ),
      ],
    );
  }

  static Future<File> saveDocument({required String name, required pw.Document pdf}) async {
    final bytes = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes);
    return file;
  }
}
