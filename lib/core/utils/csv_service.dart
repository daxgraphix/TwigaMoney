import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:twigamoney/l10n/app_localizations.dart';
import '../../features/product/domain/entities/product.dart';

class CsvService {
  static const String _productsFileName = 'products_export.csv';

  /// Export products to CSV file
  static Future<String?> exportProducts(List<Product> products, AppLocalizations l10n) async {
    try {
      // Request storage permission
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('Storage permission denied');
      }

      // Get downloads directory
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw Exception('Could not access storage directory');
      }

      final downloadsDir = Directory('${directory.path}/Download');
      if (!downloadsDir.existsSync()) {
        downloadsDir.createSync(recursive: true);
      }

      final filePath = '${downloadsDir.path}/$_productsFileName';

      // Convert products to CSV data
      final csvData = _productsToCsv(products, l10n);

      // Write to file
      final file = File(filePath);
      await file.writeAsString(csvData);

      return filePath;
    } catch (e) {
      throw Exception('Failed to export products: $e');
    }
  }

  /// Import products from CSV file
  static Future<List<Product>> importProducts() async {
    try {
      // Pick CSV file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null || result.files.isEmpty) {
        throw Exception('No file selected');
      }

      final filePath = result.files.first.path;
      if (filePath == null) {
        throw Exception('Invalid file path');
      }

      // Read CSV file
      final file = File(filePath);
      final csvString = await file.readAsString();

      // Parse CSV
      final csvData = const CsvToListConverter().convert(csvString);

      if (csvData.isEmpty) {
        throw Exception('CSV file is empty');
      }

      // Convert CSV to products (skip header row)
      final products = <Product>[];
      for (var i = 1; i < csvData.length; i++) {
        final row = csvData[i];
        if (row.length >= 4) {
          try {
            final product = Product(
              id: row[0].toString(),
              name: row[1].toString(),
              barcode: row[2].toString(),
              price: double.parse(row[3].toString()),
              costPrice: row.length > 4 ? double.tryParse(row[4].toString()) ?? 0.0 : 0.0,
              stock: row.length > 5 ? int.tryParse(row[5].toString()) ?? 0 : 0,
              minStockThreshold: row.length > 6 ? int.tryParse(row[6].toString()) ?? 5 : 5,
              category: row.length > 7 ? row[7].toString() : 'General',
              discountPercentage: row.length > 8 ? double.tryParse(row[8].toString()) ?? 0.0 : 0.0,
              taxPercentage: row.length > 9 ? double.tryParse(row[9].toString()) ?? 0.0 : 0.0,
              lastStockUpdate: row.length > 10 ? DateTime.tryParse(row[10].toString()) ?? DateTime.now() : DateTime.now(),
              totalSold: row.length > 11 ? int.tryParse(row[11].toString()) ?? 0 : 0,
            );
            products.add(product);
          } catch (e) {
            // Skip invalid rows
            continue;
          }
        }
      }

      return products;
    } catch (e) {
      throw Exception('Failed to import products: $e');
    }
  }

  /// Convert products list to CSV string
  static String _productsToCsv(List<Product> products, AppLocalizations l10n) {
    final headers = [
      'ID',
      l10n.productName,
      'Barcode',
      l10n.price,
      'Cost Price',
      l10n.stock,
      'Min Stock Threshold',
      l10n.category,
      'Discount Percentage',
      'Tax Percentage',
      'Last Stock Update',
      'Total Sold'
    ];

    final rows = [headers];

    for (final product in products) {
      rows.add([
        product.id,
        product.name,
        product.barcode,
        product.price.toString(),
        product.costPrice.toString(),
        product.stock.toString(),
        product.minStockThreshold.toString(),
        product.category,
        product.discountPercentage.toString(),
        product.taxPercentage.toString(),
        product.lastStockUpdate.toIso8601String(),
        product.totalSold.toString(),
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  /// Get CSV template for products
  static String getProductsTemplate(AppLocalizations l10n) {
    return _productsToCsv([
      Product(
        id: 'sample-id',
        name: 'Sample Product',
        barcode: '123456789',
        price: 10.0,
        costPrice: 7.0,
        stock: 100,
        minStockThreshold: 10,
        category: 'Sample Category',
        discountPercentage: 0.0,
        taxPercentage: 0.0,
        lastStockUpdate: DateTime.now(),
        totalSold: 0,
      )
    ], l10n);
  }
}
