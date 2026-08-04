import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'shift.g.dart';

/// Represents a cashier shift
@HiveType(typeId: 26)
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'cashierId': cashierId,
      'totalSales': totalSales,
      'totalProfit': totalProfit,
      'cashDrop': cashDrop,
    };
  }

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      id: json['id'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
      cashierId: json['cashierId'] as String,
      totalSales: (json['totalSales'] as num).toDouble(),
      totalProfit: (json['totalProfit'] as num).toDouble(),
      cashDrop: (json['cashDrop'] as num).toDouble(),
    );
  }

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
