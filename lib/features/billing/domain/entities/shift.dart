import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'shift.g.dart';

/// Represents a cashier shift
@HiveType(typeId: 21)
class Shift extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final DateTime startTime;
  @HiveField(2)
  final DateTime? endTime;
  @HiveField(3)
  final String cashierId;
  @HiveField(4)
  final double totalSales;
  @HiveField(5)
  final double totalProfit;
  @HiveField(6)
  final double cashDrop;

  const Shift({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.cashierId,
    this.totalSales = 0.0,
    this.totalProfit = 0.0,
    this.cashDrop = 0.0,
  });

  @override
  List<Object?> get props => [id, startTime, endTime, cashierId, totalSales, totalProfit, cashDrop];

  Shift copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    String? cashierId,
    double? totalSales,
    double? totalProfit,
    double? cashDrop,
  }) {
    return Shift(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      cashierId: cashierId ?? this.cashierId,
      totalSales: totalSales ?? this.totalSales,
      totalProfit: totalProfit ?? this.totalProfit,
      cashDrop: cashDrop ?? this.cashDrop,
    );
  }
}
