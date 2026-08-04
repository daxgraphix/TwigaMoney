import 'package:equatable/equatable.dart';
import '../../../../core/data/sync_status.dart';

class Product extends Equatable {
  final String id; // Using barcode as ID usually, but keeping separate ID is safer
  final String name;
  final String barcode;
  final double price; // Selling price
  final double costPrice; // Cost price for margin calculations
  final int stock; // Current stock level
  final int minStockThreshold; // Minimum stock threshold for alerts
  final String category;
  final double discountPercentage;
  final double taxPercentage;
  final DateTime lastStockUpdate; // Track when stock was last updated
  final int totalSold; // Total units sold (for analytics)
  final SyncStatus syncStatus;
  final DateTime updatedAt;

  const Product({
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
    this.syncStatus = SyncStatus.pending,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        barcode,
        price,
        costPrice,
        stock,
        minStockThreshold,
        category,
        discountPercentage,
        taxPercentage,
        lastStockUpdate,
        totalSold,
        syncStatus,
        updatedAt,
      ];

  Product copyWith({
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
    SyncStatus? syncStatus,
    DateTime? updatedAt,
  }) {
    return Product(
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
      syncStatus: syncStatus ?? this.syncStatus,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Financial calculations
  double get marginPercentage {
    if (costPrice <= 0) return 0.0;
    return ((price - costPrice) / costPrice) * 100;
  }

  double get profitPerUnit => price - costPrice;

  double get turnoverRate => totalSold > 0 ? totalSold / stock : 0.0;

  bool get isLowStock => stock <= minStockThreshold;

  bool get isLowTurnover => turnoverRate < 0.1; // Less than 10% turnover

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
      'syncStatus': syncStatus.name,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      barcode: json['barcode'] as String,
      price: (json['price'] as num).toDouble(),
      costPrice: (json['costPrice'] as num?)?.toDouble() ?? 0.0,
      stock: json['stock'] as int,
      minStockThreshold: json['minStockThreshold'] as int,
      category: json['category'] as String,
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      taxPercentage: (json['taxPercentage'] as num?)?.toDouble() ?? 0.0,
      lastStockUpdate: DateTime.parse(json['lastStockUpdate'] as String),
      totalSold: json['totalSold'] as int,
      syncStatus: json['syncStatus'] != null
          ? SyncStatus.values.firstWhere((e) => e.name == json['syncStatus'], orElse: () => SyncStatus.pending)
          : SyncStatus.pending,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : DateTime.now(),
    );
  }

  factory Product.empty() {
    return Product(
      id: '',
      name: '',
      barcode: '',
      price: 0.0,
      lastStockUpdate: DateTime(0),
      updatedAt: DateTime(0),
    );
  }
}
