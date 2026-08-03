import 'package:hive/hive.dart';
import 'transaction.dart';

part 'recurring_transaction.g.dart';

@HiveType(typeId: 18)
class RecurringTransaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String description;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final RecurringInterval interval;

  @HiveField(4)
  final TransactionType type;

  @HiveField(5)
  final String categoryId;

  @HiveField(6)
  final String accountId;

  @HiveField(7)
  final DateTime startDate;

  @HiveField(8)
  final DateTime? endDate;

  @HiveField(9)
  final bool isActive;

  RecurringTransaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.interval,
    required this.type,
    required this.categoryId,
    required this.accountId,
    required this.startDate,
    this.endDate,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'amount': amount,
        'interval': interval.name,
        'type': type.name,
        'categoryId': categoryId,
        'accountId': accountId,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'isActive': isActive,
      };

  factory RecurringTransaction.fromJson(Map<String, dynamic> json) =>
      RecurringTransaction(
        id: json['id'] as String,
        description: json['description'] as String,
        amount: (json['amount'] as num).toDouble(),
        interval: RecurringInterval.values.firstWhere(
          (e) => e.name == json['interval'],
          orElse: () => RecurringInterval.monthly,
        ),
        type: TransactionType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => TransactionType.expense,
        ),
        categoryId: json['categoryId'] as String,
        accountId: json['accountId'] as String,
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: json['endDate'] != null
            ? DateTime.parse(json['endDate'] as String)
            : null,
        isActive: json['isActive'] as bool? ?? true,
      );
}