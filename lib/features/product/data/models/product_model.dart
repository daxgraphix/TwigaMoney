import 'package:hive/hive.dart';
import '../../domain/entities/product.dart';

part 'product_model.g.dart'; // Hive generator

@HiveType(typeId: 0)
class ProductModel extends Product {
  @override
  @HiveField(0)
  final String id; // ignore: overridden_fields

  @override
  @HiveField(1)
  final String name; // ignore: overridden_fields

  @override
  @HiveField(2)
  final String barcode; // ignore: overridden_fields

  @override
  @HiveField(3)
  final double price; // ignore: overridden_fields

  @override
  @HiveField(4)
  final double costPrice; // ignore: overridden_fields

  @override
  @HiveField(5)
  final int stock; // ignore: overridden_fields

  @override
  @HiveField(6)
  final int minStockThreshold; // ignore: overridden_fields

  @override
  @HiveField(7)
  final String category; // ignore: overridden_fields

  @override
  @HiveField(8)
  final double discountPercentage; // ignore: overridden_fields

  @override
  @HiveField(9)
  final double taxPercentage; // ignore: overridden_fields

  @override
  @HiveField(10)
  final DateTime lastStockUpdate; // ignore: overridden_fields

  @override
  @HiveField(11)
  final int totalSold; // ignore: overridden_fields

  const ProductModel({
    required this.id,
    required this.name,
    required this.barcode,
    required this.price,
    this.costPrice = 0.0,
    this.stock = 0,
    this.minStockThreshold = 5,
    this.category = 'General',
    this.discountPercentage = 0.0,
    this.taxPercentage = 0.0,
    required this.lastStockUpdate,
    this.totalSold = 0,
  }) : super(
             id: id,
             name: name,
             barcode: barcode,
             price: price,
             costPrice: costPrice,
             stock: stock,
             minStockThreshold: minStockThreshold,
             category: category,
             discountPercentage: discountPercentage,
             taxPercentage: taxPercentage,
             lastStockUpdate: lastStockUpdate,
             totalSold: totalSold,
           );

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      barcode: product.barcode,
      price: product.price,
      costPrice: product.costPrice,
      stock: product.stock,
      minStockThreshold: product.minStockThreshold,
      category: product.category,
      discountPercentage: product.discountPercentage,
      taxPercentage: product.taxPercentage,
      lastStockUpdate: product.lastStockUpdate,
      totalSold: product.totalSold,
    );
  }

  Product toEntity() {
    return Product(
      id: id,
      name: name,
      barcode: barcode,
      price: price,
      costPrice: costPrice,
      stock: stock,
      minStockThreshold: minStockThreshold,
      category: category,
      discountPercentage: discountPercentage,
      taxPercentage: taxPercentage,
      lastStockUpdate: lastStockUpdate,
      totalSold: totalSold,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'barcode': barcode,
      'price': price,
      'costPrice': costPrice,
      'stock': stock,
      'minStockThreshold': minStockThreshold,
      'category': category,
      'discountPercentage': discountPercentage,
      'taxPercentage': taxPercentage,
      'lastStockUpdate': lastStockUpdate.toIso8601String(),
      'totalSold': totalSold,
    };
  }

    factory ProductModel.fromJson(Map<String, dynamic> json) {
      return ProductModel(
        id: json['id'] as String,
        name: json['name'] as String,
        barcode: json['barcode'] as String,
        price: (json['price'] as num).toDouble(),
        costPrice: (json['costPrice'] as num?)?.toDouble() ?? 0.0,
        stock: json['stock'] as int? ?? 0,
        minStockThreshold: json['minStockThreshold'] as int? ?? 5,
        category: json['category'] as String? ?? 'General',
        discountPercentage: (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
        taxPercentage: (json['taxPercentage'] as num?)?.toDouble() ?? 0.0,
        lastStockUpdate: json['lastStockUpdate'] != null
            ? DateTime.parse(json['lastStockUpdate'] as String)
            : DateTime.now(),
        totalSold: json['totalSold'] as int? ?? 0,
      );
    }

  @override
  ProductModel copyWith({
    String? id,
    String? name,
    String? barcode,
    double? price,
    double? costPrice,
    int? stock,
    int? minStockThreshold,
    String? category,
    double? discountPercentage,
    double? taxPercentage,
    DateTime? lastStockUpdate,
    int? totalSold,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      stock: stock ?? this.stock,
      minStockThreshold: minStockThreshold ?? this.minStockThreshold,
      category: category ?? this.category,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      taxPercentage: taxPercentage ?? this.taxPercentage,
      lastStockUpdate: lastStockUpdate ?? this.lastStockUpdate,
      totalSold: totalSold ?? this.totalSold,
    );
  }
}
