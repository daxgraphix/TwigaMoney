import 'package:hive/hive.dart';

part 'account.g.dart';

@HiveType(typeId: 14)
enum AccountType {
  @HiveField(0)
  checking,
  @HiveField(1)
  savings,
  @HiveField(2)
  credit,
  @HiveField(3)
  investment,
}

@HiveType(typeId: 15)
class Account extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final AccountType type;

  @HiveField(3)
  final double balance;

  @HiveField(4)
  final String currency;

  Account({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    this.currency = 'TZS',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.name,
        'balance': balance,
        'currency': currency,
      };

  factory Account.fromJson(Map<String, dynamic> json) => Account(
        id: json['id'] as String,
        name: json['name'] as String,
        type: AccountType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => AccountType.checking,
        ),
        balance: (json['balance'] as num).toDouble(),
        currency: json['currency'] as String? ?? 'TZS',
      );
}