import 'package:equatable/equatable.dart';

/// Represents a currency for multi-currency support
class Currency extends Equatable {
  final String code; // e.g., 'USD', 'EUR'
  final String symbol; // e.g., '$', '€'
  final double exchangeRate; // Rate relative to base currency (e.g., INR)

  const Currency({
    required this.code,
    required this.symbol,
    required this.exchangeRate,
  });

  @override
  List<Object?> get props => [code, symbol, exchangeRate];

  Currency copyWith({
    String? code,
    String? symbol,
    double? exchangeRate,
  }) {
    return Currency(
      code: code ?? this.code,
      symbol: symbol ?? this.symbol,
      exchangeRate: exchangeRate ?? this.exchangeRate,
    );
  }
}