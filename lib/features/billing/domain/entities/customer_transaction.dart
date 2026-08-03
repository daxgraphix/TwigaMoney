import 'package:hive/hive.dart';

part 'customer_transaction.g.dart';

@HiveType(typeId: 24)
enum CustomerTransactionType {
  @HiveField(0)
  creditSale, // Sale on credit
  @HiveField(1)
  payment, // Customer payment
  @HiveField(2)
  adjustment, // Manual adjustment
  @HiveField(3)
  writeOff, // Debt write-off
}

@HiveType(typeId: 25)
class CustomerTransaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String customerId;

  @HiveField(2)
  final CustomerTransactionType type;

  @HiveField(3)
  final double amount; // Positive for credits/charges, negative for payments

  @HiveField(4)
  final double previousBalance;

  @HiveField(5)
  final double newBalance;

  @HiveField(6)
  final DateTime timestamp;

  @HiveField(7)
  final String reference; // Sale ID, payment receipt, etc.

  @HiveField(8)
  final String notes;

  CustomerTransaction({
    required this.id,
    required this.customerId,
    required this.type,
    required this.amount,
    required this.previousBalance,
    required this.newBalance,
    required this.timestamp,
    required this.reference,
    this.notes = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerId': customerId,
        'type': type.name,
        'amount': amount,
        'previousBalance': previousBalance,
        'newBalance': newBalance,
        'timestamp': timestamp.toIso8601String(),
        'reference': reference,
        'notes': notes,
      };

  factory CustomerTransaction.fromJson(Map<String, dynamic> json) =>
      CustomerTransaction(
        id: json['id'] as String,
        customerId: json['customerId'] as String,
        type: CustomerTransactionType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => CustomerTransactionType.creditSale,
        ),
        amount: (json['amount'] as num).toDouble(),
        previousBalance: (json['previousBalance'] as num).toDouble(),
        newBalance: (json['newBalance'] as num).toDouble(),
        timestamp: DateTime.parse(json['timestamp'] as String),
        reference: json['reference'] as String,
        notes: json['notes'] as String? ?? '',
      );

  @override
  String toString() {
    return 'CustomerTransaction(id: $id, customer: $customerId, type: $type, amount: $amount, balance: $newBalance)';
  }
}