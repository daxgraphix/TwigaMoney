import 'package:hive/hive.dart';
import '../../../../core/data/sync_status.dart';

part 'sales_transaction.g.dart';

enum TransactionStatus {
  pending,
  paid,
  cancelled,
}

@HiveType(typeId: 20)
class SalesTransaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String productId;

  @HiveField(2)
  final String productName;

  @HiveField(3)
  final double sellingPrice;

  @HiveField(4)
  final double costPrice;

  @HiveField(5)
  final int quantity;

  @HiveField(6)
  final double totalRevenue; // sellingPrice * quantity

  @HiveField(7)
  final double totalCost; // costPrice * quantity

  @HiveField(8)
  final double totalProfit; // totalRevenue - totalCost

  @HiveField(9)
  final double marginPercentage; // ((sellingPrice - costPrice) / costPrice) * 100

  @HiveField(10)
  final DateTime timestamp;

  @HiveField(11)
  final String shiftId;

  @HiveField(12)
  final String customerId; // Optional, can be 'cash' for cash sales

  @HiveField(13)
  final TransactionStatus status;

  @HiveField(14)
  final List<String> items; // List of product names or ids

  @HiveField(15)
  final DateTime createdAt;

  @HiveField(16)
  final SyncStatus syncStatus;

  @HiveField(17)
  final DateTime updatedAt;

  SalesTransaction({
    required this.id,
    required this.productId,
    required this.productName,
    required this.sellingPrice,
    required this.costPrice,
    required this.quantity,
    required this.timestamp,
    required this.shiftId,
    this.customerId = 'cash',
    this.status = TransactionStatus.pending,
    this.items = const [],
    DateTime? createdAt,
    this.syncStatus = SyncStatus.pending,
    DateTime? updatedAt,
  })  : totalRevenue = sellingPrice * quantity,
        totalCost = costPrice * quantity,
        totalProfit = (sellingPrice * quantity) - (costPrice * quantity),
        marginPercentage = costPrice > 0 ? (((sellingPrice - costPrice) / costPrice) * 100) : 0.0,
        createdAt = createdAt ?? timestamp,
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'sellingPrice': sellingPrice,
      'costPrice': costPrice,
      'quantity': quantity,
      'totalRevenue': totalRevenue,
      'totalCost': totalCost,
      'totalProfit': totalProfit,
      'marginPercentage': marginPercentage,
      'timestamp': timestamp.toIso8601String(),
      'shiftId': shiftId,
      'customerId': customerId,
      'status': status.name,
      'items': items,
      'createdAt': createdAt.toIso8601String(),
      'syncStatus': syncStatus.name,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory SalesTransaction.fromJson(Map<String, dynamic> json) {
    return SalesTransaction(
      id: json['id'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      sellingPrice: (json['sellingPrice'] as num).toDouble(),
      costPrice: (json['costPrice'] as num).toDouble(),
      quantity: json['quantity'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      shiftId: json['shiftId'] as String,
      customerId: json['customerId'] as String? ?? 'cash',
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TransactionStatus.pending,
      ),
      items: (json['items'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      syncStatus: json['syncStatus'] != null
          ? SyncStatus.values.firstWhere((e) => e.name == json['syncStatus'], orElse: () => SyncStatus.pending)
          : SyncStatus.pending,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  SalesTransaction copyWith({
    String? id,
    String? productId,
    String? productName,
    double? sellingPrice,
    double? costPrice,
    int? quantity,
    DateTime? timestamp,
    String? shiftId,
    String? customerId,
    TransactionStatus? status,
    List<String>? items,
    DateTime? createdAt,
    SyncStatus? syncStatus,
    DateTime? updatedAt,
  }) {
    return SalesTransaction(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      costPrice: costPrice ?? this.costPrice,
      quantity: quantity ?? this.quantity,
      timestamp: timestamp ?? this.timestamp,
      shiftId: shiftId ?? this.shiftId,
      customerId: customerId ?? this.customerId,
      status: status ?? this.status,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'SalesTransaction(id: $id, product: $productName, quantity: $quantity, profit: $totalProfit)';
  }
}