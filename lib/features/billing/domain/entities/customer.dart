import 'package:hive/hive.dart';

part 'customer.g.dart';

@HiveType(typeId: 23)
class Customer extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String phone;

  @HiveField(3)
  final String email;

  @HiveField(4)
  final double creditLimit;

  @HiveField(5)
  final double currentBalance; // Outstanding balance

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime lastTransaction;

  @HiveField(8)
  final String address;

  @HiveField(9)
  final bool isActive;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.email = '',
    this.address = '',
    this.creditLimit = 0.0,
    this.currentBalance = 0.0,
    DateTime? createdAt,
    DateTime? lastTransaction,
    this.isActive = true,
  })  : createdAt = createdAt ?? DateTime.now(),
        lastTransaction = lastTransaction ?? DateTime.now();

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    double? creditLimit,
    double? currentBalance,
    DateTime? createdAt,
    DateTime? lastTransaction,
    bool? isActive,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      creditLimit: creditLimit ?? this.creditLimit,
      currentBalance: currentBalance ?? this.currentBalance,
      createdAt: createdAt ?? this.createdAt,
      lastTransaction: lastTransaction ?? this.lastTransaction,
      isActive: isActive ?? this.isActive,
    );
  }

  // Computed properties
  double get availableCredit => creditLimit - currentBalance;

  bool get hasOutstandingBalance => currentBalance > 0;

  bool get isOverCreditLimit => currentBalance > creditLimit && creditLimit > 0;

  DebtStatus get debtStatus {
    if (currentBalance <= 0) return DebtStatus.paid;
    if (currentBalance <= creditLimit * 0.8) return DebtStatus.good;
    if (currentBalance <= creditLimit) return DebtStatus.warning;
    return DebtStatus.overdue;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'creditLimit': creditLimit,
      'currentBalance': currentBalance,
      'createdAt': createdAt.toIso8601String(),
      'lastTransaction': lastTransaction.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String? ?? '',
      address: json['address'] as String? ?? '',
      creditLimit: (json['creditLimit'] as num?)?.toDouble() ?? 0.0,
      currentBalance: (json['currentBalance'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      lastTransaction: json['lastTransaction'] != null ? DateTime.parse(json['lastTransaction'] as String) : null,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  factory Customer.empty() {
    return Customer(
      id: '',
      name: '',
      phone: '',
      email: '',
      address: '',
      creditLimit: 0.0,
      currentBalance: 0.0,
      isActive: true,
    );
  }

  @override
  String toString() {
    return 'Customer(id: $id, name: $name, balance: $currentBalance, limit: $creditLimit)';
  }
}

enum DebtStatus {
  paid,
  good,
  warning,
  overdue,
}