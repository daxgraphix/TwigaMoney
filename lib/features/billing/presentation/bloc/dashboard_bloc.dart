import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/sales_transaction.dart';
import '../../domain/repositories/sales_repository.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../../product/domain/repositories/stock_repository.dart';
import '../../../finance/domain/entities/transaction.dart' as finance;
import '../../../finance/domain/usecases/finance_usecases.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final SalesRepository salesRepository;
  final CustomerRepository customerRepository;
  final StockRepository stockRepository;
  final GetTransactionsByDateRangeUseCase getTransactionsByDateRangeUseCase;
  final GetAccountsUseCase getAccountsUseCase;

  DashboardBloc({
    required this.salesRepository,
    required this.customerRepository,
    required this.stockRepository,
    required this.getTransactionsByDateRangeUseCase,
    required this.getAccountsUseCase,
  }) : super(const DashboardState()) {
    on<LoadDashboardDataEvent>(_onLoadDashboardData);
  }

  Future<void> _onLoadDashboardData(
      LoadDashboardDataEvent event, Emitter<DashboardState> emit) async {
    if (!event.forceRefresh && state.todayRevenue > 0) {
      // Potentially skip if already loaded, but for dashboard usually we want fresh data
    }

    emit(state.copyWith(isLoading: true, error: null));

    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final results = await Future.wait([
        salesRepository.getSalesByDateRange(startOfDay, endOfDay),
        stockRepository.getLowStockAlerts(),
        customerRepository.getDebtAgingSummary(),
        getTransactionsByDateRangeUseCase(DateRangeParams(start: startOfDay, end: endOfDay)),
        getAccountsUseCase(NoParams()),
      ]);

      final todaySalesResult = results[0] as Either<Failure, List<SalesTransaction>>;
      final lowStockResult = results[1] as Either<Failure, List<String>>;
      final debtAgingResult = results[2] as Either<Failure, Map<String, double>>;
      final financeTransactionsResult = results[3] as Either<Failure, List<dynamic>>;
      final accountsResult = results[4] as Either<Failure, List<dynamic>>;

      final todaySales = todaySalesResult.getOrElse((_) => []);
      final lowStockAlerts = lowStockResult.getOrElse((_) => []);
      final debtAging = debtAgingResult.getOrElse((_) => {});
      final financeTransactions = financeTransactionsResult.getOrElse((_) => []);
      final accounts = accountsResult.getOrElse((_) => []);

      double todayRevenue = todaySales.fold<double>(
          0.0, (sum, sale) => sum + sale.totalRevenue);
      double todayProfit = todaySales.fold<double>(
          0.0, (sum, sale) => sum + sale.totalProfit);
      int todayTransactions = todaySales.length;

      // Calculate Finance KPIs (Expenses)
      double financeExpenses = financeTransactions
          .whereType<finance.Transaction>()
          .where((t) => t.type == finance.TransactionType.expense)
          .fold<double>(0.0, (sum, t) => sum + t.amount);

      double totalCashBalance = accounts
          .fold<double>(0.0, (sum, account) => sum + account.balance);

      emit(state.copyWith(
        isLoading: false,
        todayRevenue: todayRevenue,
        todayProfit: todayProfit - financeExpenses,
        todayTransactions: todayTransactions,
        lowStockAlerts: lowStockAlerts,
        totalOutstandingDebt: debtAging['total'] ?? 0.0,
        overdueDebt: (debtAging['thirtyDays'] ?? 0.0) +
            (debtAging['sixtyDays'] ?? 0.0) +
            (debtAging['ninetyDaysPlus'] ?? 0.0),
        financeExpenses: financeExpenses,
        totalCashBalance: totalCashBalance,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load dashboard: $e',
      ));
    }
  }
}
