import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 10)
enum TransactionType {
  @HiveField(0)
  expense,
  @HiveField(1)
  income,
  @HiveField(2)
  stock,
  @HiveField(3)
  fundTransfer,
}

@HiveType(typeId: 11)
enum RecurringInterval {
  @HiveField(0)
  daily,
  @HiveField(1)
  weekly,
  @HiveField(2)
  monthly,
  @HiveField(3)
  yearly,
}

@HiveType(typeId: 12)
class Transaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String description;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String categoryId;

  @HiveField(5)
  final String accountId;

  @HiveField(6)
  final TransactionType type;

  @HiveField(7)
  final bool isRecurring;

  @HiveField(8)
  final RecurringInterval? recurringInterval;
  @HiveField(9)
  final String? fromAccountId;
  @HiveField(10)
  final String? toAccountId;
  @HiveField(11)
  final String? productId;
  @HiveField(12)
  final int? stockQuantity;

  Transaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.categoryId,
    required this.accountId,
    required this.type,
    this.isRecurring = false,
    this.recurringInterval,
    this.fromAccountId,
    this.toAccountId,
    this.productId,
    this.stockQuantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      'categoryId': categoryId,
      'accountId': accountId,
      'type': type.name,
      'isRecurring': isRecurring,
      'recurringInterval': recurringInterval?.name,
      'fromAccountId': fromAccountId,
      'toAccountId': toAccountId,
      'productId': productId,
      'stockQuantity': stockQuantity,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      categoryId: json['categoryId'] as String,
      accountId: json['accountId'] as String,
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.expense,
      ),
      isRecurring: json['isRecurring'] as bool? ?? false,
      recurringInterval: json['recurringInterval'] != null
          ? RecurringInterval.values.firstWhere(
              (e) => e.name == json['recurringInterval'],
              orElse: () => RecurringInterval.monthly,
            )
          : null,
      fromAccountId: json['fromAccountId'] as String?,
      toAccountId: json['toAccountId'] as String?,
      productId: json['productId'] as String?,
      stockQuantity: json['stockQuantity'] as int?,
    );
  }
}