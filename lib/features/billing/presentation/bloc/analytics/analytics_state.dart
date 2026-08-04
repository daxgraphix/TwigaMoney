part of 'analytics_bloc.dart';

class AnalyticsState extends Equatable {
  final bool isLoading;
  final String? error;
  final List<ProductAnalytics> topPerformingProducts;
  final List<ProductAnalytics> lowTurnoverProducts;
  final Map<String, double> dailyRevenue;
  final Map<String, double> dailyProfit;
  
  // Finance Analytics
  final List<Transaction> transactions;
  final Map<String, double> categoryDistribution;
  
  // Customer Analytics
  final Map<String, double> debtAging;
  final List<Customer> outstandingCustomers;
  
  // Advanced Analytics
  final Map<int, int> peakHours;

  const AnalyticsState({
    this.isLoading = false,
    this.error,
    this.topPerformingProducts = const [],
    this.lowTurnoverProducts = const [],
    this.dailyRevenue = const {},
    this.dailyProfit = const {},
    this.transactions = const [],
    this.categoryDistribution = const {},
    this.debtAging = const {},
    this.outstandingCustomers = const [],
    this.peakHours = const {},
  });

  AnalyticsState copyWith({
    bool? isLoading,
    String? error,
    List<ProductAnalytics>? topPerformingProducts,
    List<ProductAnalytics>? lowTurnoverProducts,
    Map<String, double>? dailyRevenue,
    Map<String, double>? dailyProfit,
    List<Transaction>? transactions,
    Map<String, double>? categoryDistribution,
    Map<String, double>? debtAging,
    List<Customer>? outstandingCustomers,
    Map<int, int>? peakHours,
  }) {
    return AnalyticsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      topPerformingProducts: topPerformingProducts ?? this.topPerformingProducts,
      lowTurnoverProducts: lowTurnoverProducts ?? this.lowTurnoverProducts,
      dailyRevenue: dailyRevenue ?? this.dailyRevenue,
      dailyProfit: dailyProfit ?? this.dailyProfit,
      transactions: transactions ?? this.transactions,
      categoryDistribution: categoryDistribution ?? this.categoryDistribution,
      debtAging: debtAging ?? this.debtAging,
      outstandingCustomers: outstandingCustomers ?? this.outstandingCustomers,
      peakHours: peakHours ?? this.peakHours,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        error,
        topPerformingProducts,
        lowTurnoverProducts,
        dailyRevenue,
        dailyProfit,
        transactions,
        categoryDistribution,
        debtAging,
        outstandingCustomers,
        peakHours,
      ];
}
