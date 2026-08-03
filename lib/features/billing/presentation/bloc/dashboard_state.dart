part of 'dashboard_bloc.dart';

class DashboardState extends Equatable {
  final bool isLoading;
  final double todayRevenue;
  final double todayProfit;
  final int todayTransactions;
  final List<String> lowStockAlerts;
  final double totalOutstandingDebt;
  final double overdueDebt;
  final double financeExpenses;
  final double totalCashBalance;
  final String? error;

  const DashboardState({
    this.isLoading = false,
    this.todayRevenue = 0.0,
    this.todayProfit = 0.0,
    this.todayTransactions = 0,
    this.lowStockAlerts = const [],
    this.totalOutstandingDebt = 0.0,
    this.overdueDebt = 0.0,
    this.financeExpenses = 0.0,
    this.totalCashBalance = 0.0,
    this.error,
  });

  DashboardState copyWith({
    bool? isLoading,
    double? todayRevenue,
    double? todayProfit,
    int? todayTransactions,
    List<String>? lowStockAlerts,
    double? totalOutstandingDebt,
    double? overdueDebt,
    double? financeExpenses,
    double? totalCashBalance,
    String? error,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      todayRevenue: todayRevenue ?? this.todayRevenue,
      todayProfit: todayProfit ?? this.todayProfit,
      todayTransactions: todayTransactions ?? this.todayTransactions,
      lowStockAlerts: lowStockAlerts ?? this.lowStockAlerts,
      totalOutstandingDebt: totalOutstandingDebt ?? this.totalOutstandingDebt,
      overdueDebt: overdueDebt ?? this.overdueDebt,
      financeExpenses: financeExpenses ?? this.financeExpenses,
      totalCashBalance: totalCashBalance ?? this.totalCashBalance,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        todayRevenue,
        todayProfit,
        todayTransactions,
        lowStockAlerts,
        totalOutstandingDebt,
        overdueDebt,
        financeExpenses,
        totalCashBalance,
        error,
      ];
}
