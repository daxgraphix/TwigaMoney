import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:twigamoney/core/error/failure.dart';
import 'package:twigamoney/core/usecase/usecase.dart';
import 'package:twigamoney/features/billing/domain/repositories/sales_repository.dart';
import 'package:twigamoney/features/billing/domain/usecases/analytics_usecases.dart';
import 'package:twigamoney/features/finance/domain/repositories/transaction_repository.dart';
import 'package:twigamoney/features/finance/domain/entities/transaction.dart';
import 'package:twigamoney/features/billing/domain/repositories/customer_repository.dart';
import 'package:twigamoney/features/billing/domain/entities/sales_transaction.dart';
import 'package:twigamoney/features/billing/domain/entities/customer.dart';

part 'analytics_event.dart';
part 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final GetTopPerformingProductsUseCase getTopPerformingProductsUseCase;
  final GetLowTurnoverProductsUseCase getLowTurnoverProductsUseCase;
  final SalesRepository salesRepository;
  final TransactionRepository transactionRepository;
  final CustomerRepository customerRepository;

  AnalyticsBloc({
    required this.getTopPerformingProductsUseCase,
    required this.getLowTurnoverProductsUseCase,
    required this.salesRepository,
    required this.transactionRepository,
    required this.customerRepository,
  }) : super(const AnalyticsState()) {
    on<LoadAnalyticsEvent>(_onLoadAnalytics);
  }

  Future<void> _onLoadAnalytics(
      LoadAnalyticsEvent event, Emitter<AnalyticsState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));

    final TaskEither<Failure, Map<String, dynamic>> task = TaskEither.tryCatch(() async {
      // Fetch all required raw data in parallel
      final results = await Future.wait([
        salesRepository.getSalesTransactionsByDateRange(event.startDate, event.endDate),
        getLowTurnoverProductsUseCase(NoParams()),
        transactionRepository.getTransactionsByDateRange(event.startDate, event.endDate),
        customerRepository.getDebtAgingSummary(),
        customerRepository.getCustomersWithOutstandingBalances(),
      ]);
      return results;
    }, (error, stackTrace) => DatabaseFailure('Failed to load analytics: $error')).flatMap((results) {
      final salesTransactionsResult = results[0] as Either<Failure, List<SalesTransaction>>;
      final lowTurnoverResult = results[1] as Either<Failure, List<ProductAnalytics>>;
      final transactionsResult = results[2] as Either<Failure, List<Transaction>>;
      final debtAgingResult = results[3] as Either<Failure, Map<String, double>>;
      final outstandingCustomersResult = results[4] as Either<Failure, List<Customer>>;

      return TaskEither.fromEither(Either.fromOption(
        Option.of({
          'salesTransactions': salesTransactionsResult.getOrElse((_) => []),
          'lowTurnover': lowTurnoverResult.getOrElse((_) => []),
          'transactions': transactionsResult.getOrElse((_) => []),
          'debtAging': debtAgingResult.getOrElse((_) => {}),
          'outstandingCustomers': outstandingCustomersResult.getOrElse((_) => []),
        }),
        () => const DatabaseFailure('Processing failure'),
      ));
    });

    final result = await task.run();

    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
      (data) {
        final salesTransactions = data['salesTransactions'] as List<SalesTransaction>;
        final transactions = data['transactions'] as List<Transaction>;

        // Process Sales Analytics in one pass
        final dailyRevenue = <String, double>{};
        final dailyProfit = <String, double>{};
        final peakHours = <int, int>{};
        final productStats = <String, _ProductStat>{};

        for (final sale in salesTransactions) {
          // Time-based aggregation
          final dateKey = _formatDateKey(sale.timestamp);
          dailyRevenue[dateKey] = (dailyRevenue[dateKey] ?? 0.0) + sale.totalRevenue;
          dailyProfit[dateKey] = (dailyProfit[dateKey] ?? 0.0) + sale.totalProfit;

          final hour = sale.timestamp.hour;
          peakHours[hour] = (peakHours[hour] ?? 0) + 1;

          // Product-based aggregation
          if (!productStats.containsKey(sale.productId)) {
            productStats[sale.productId] = _ProductStat(
              name: sale.productName,
              revenue: 0.0,
              profit: 0.0,
              sold: 0,
              margin: sale.marginPercentage,
            );
          }
          final stat = productStats[sale.productId]!;
          stat.revenue += sale.totalRevenue;
          stat.profit += sale.totalProfit;
          stat.sold += sale.quantity;
        }

        // Convert product stats to ProductAnalytics entities
        final topProducts = productStats.entries.map((e) => ProductAnalytics(
          productId: e.key,
          productName: e.value.name,
          totalRevenue: e.value.revenue,
          totalProfit: e.value.profit,
          totalSold: e.value.sold,
          marginPercentage: e.value.margin,
          turnoverRate: 0.0, // Calculated primarily in low turnover usecase
        )).toList();
        
        topProducts.sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));

        // Process Category Distribution in one pass
        final categoryDist = <String, double>{};
        for (final tx in transactions) {
          if (tx.type == TransactionType.expense) {
             categoryDist[tx.categoryId] = (categoryDist[tx.categoryId] ?? 0) + tx.amount;
          }
        }

        emit(state.copyWith(
          isLoading: false,
          topPerformingProducts: topProducts.take(10).toList(),
          lowTurnoverProducts: data['lowTurnover'] as List<ProductAnalytics>,
          dailyRevenue: dailyRevenue,
          dailyProfit: dailyProfit,
          transactions: transactions,
          categoryDistribution: categoryDist,
          debtAging: data['debtAging'] as Map<String, double>,
          outstandingCustomers: data['outstandingCustomers'] as List<Customer>,
          peakHours: peakHours,
          error: null,
        ));
      },
    );
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _ProductStat {
  final String name;
  double revenue;
  double profit;
  int sold;
  final double margin;

  _ProductStat({
    required this.name,
    required this.revenue,
    required this.profit,
    required this.sold,
    required this.margin,
  });
}
