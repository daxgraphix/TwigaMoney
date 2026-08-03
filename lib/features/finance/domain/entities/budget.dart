import 'package:hive/hive.dart';

part 'budget.g.dart';

@HiveType(typeId: 16)
enum BudgetPeriod {
  @HiveField(0)
  weekly,
  @HiveField(1)
  monthly,
  @HiveField(2)
  yearly,
  @HiveField(3)
  custom,
}

@HiveType(typeId: 17)
class Budget extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String categoryId;

  @HiveField(4)
  final BudgetPeriod period;

  @HiveField(5)
  final DateTime startDate;

  @HiveField(6)
  final DateTime? endDate;

  @HiveField(7)
  final double spent;

  @HiveField(8)
  final double limitAlertThreshold; // e.g., 0.8 for 80%

  Budget({
    required this.id,
    required this.name,
    required this.amount,
    required this.categoryId,
    required this.period,
    required this.startDate,
    this.endDate,
    this.spent = 0.0,
    this.limitAlertThreshold = 0.9,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
        'categoryId': categoryId,
        'period': period.name,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'spent': spent,
        'limitAlertThreshold': limitAlertThreshold,
      };

  factory Budget.fromJson(Map<String, dynamic> json) => Budget(
        id: json['id'] as String,
        name: json['name'] as String,
        amount: (json['amount'] as num).toDouble(),
        categoryId: json['categoryId'] as String,
        period: BudgetPeriod.values.firstWhere(
          (e) => e.name == json['period'],
          orElse: () => BudgetPeriod.monthly,
        ),
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: json['endDate'] != null
            ? DateTime.parse(json['endDate'] as String)
            : null,
        spent: (json['spent'] as num?)?.toDouble() ?? 0.0,
        limitAlertThreshold: (json['limitAlertThreshold'] as num?)?.toDouble() ?? 0.9,
      );

  factory Budget.empty() {
    return Budget(
      id: '',
      name: '',
      amount: 0.0,
      categoryId: '',
      period: BudgetPeriod.monthly,
      startDate: DateTime.now(),
      spent: 0.0,
    );
  }

  double get remaining => amount - spent;

  bool get isOverBudget => spent > amount;

  bool get shouldAlert => spent / amount >= limitAlertThreshold;
}