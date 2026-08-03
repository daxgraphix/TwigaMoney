import 'package:equatable/equatable.dart';

/// Represents a cashier shift
class Shift extends Equatable {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final String cashierId;
  final double totalSales;

  const Shift({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.cashierId,
    this.totalSales = 0.0,
  });

  @override
  List<Object?> get props => [id, startTime, endTime, cashierId, totalSales];

  Shift copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    String? cashierId,
    double? totalSales,
  }) {
    return Shift(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      cashierId: cashierId ?? this.cashierId,
      totalSales: totalSales ?? this.totalSales,
    );
  }
}