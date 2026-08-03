import 'package:fpdart/fpdart.dart';
import 'package:twigamoney/core/error/failure.dart';
import 'package:twigamoney/core/usecase/usecase.dart';
import 'package:twigamoney/features/finance/domain/entities/transaction.dart';
import 'package:twigamoney/features/finance/domain/repositories/transaction_repository.dart';
import 'package:twigamoney/features/billing/domain/repositories/sales_repository.dart';
import 'package:twigamoney/features/billing/domain/repositories/customer_repository.dart';
import 'package:twigamoney/features/product/domain/repositories/stock_repository.dart';
import 'package:twigamoney/features/billing/domain/usecases/analytics_usecases.dart';

class GetComprehensiveBusinessReportUseCase implements UseCase<BusinessReport, ReportParams> {
  final TransactionRepository transactionRepository;
  final SalesRepository salesRepository;
  final CustomerRepository customerRepository;
  final StockRepository stockRepository;

  GetComprehensiveBusinessReportUseCase(
    this.transactionRepository,
    this.salesRepository,
    this.customerRepository,
    this.stockRepository,
  );

  @override
  Future<Either<Failure, BusinessReport>> call(ReportParams params) async {
    try {
      final startDate = params.startDate;
      final endDate = params.endDate;

      // Get financial transactions
      final transactionsResult = await transactionRepository.getTransactionsByDateRange(startDate, endDate);
      final transactions = transactionsResult.getOrElse((_) => []);

      // Get sales data
      final salesResult = await salesRepository.getSalesByDateRange(startDate, endDate);
      final sales = salesResult.getOrElse((_) => []);

      // Get daily revenue and profit
      final revenueResult = await salesRepository.getDailyRevenue(startDate, endDate);
      final dailyRevenue = revenueResult.getOrElse((_) => {});

      final profitResult = await salesRepository.getDailyProfit(startDate, endDate);
      final dailyProfit = profitResult.getOrElse((_) => {});

      // Get top products
      final topProductsResult = await salesRepository.getTopPerformingProducts(startDate, endDate);
      final topProducts = topProductsResult.getOrElse((_) => []);

      // Get low turnover products
      final lowTurnoverResult = await salesRepository.getLowTurnoverProducts();
      final lowTurnoverProducts = lowTurnoverResult.getOrElse((_) => []);

      // Get customer debt summary
      final debtAgingResult = await customerRepository.getDebtAgingSummary();
      final debtAging = debtAgingResult.getOrElse((_) => {});

      // Get stock summary
      final stockSummaryResult = await stockRepository.getStockSummary();
      final stockSummary = stockSummaryResult.getOrElse((_) => {});

      // Calculate totals
      double totalRevenue = sales.fold(0.0, (sum, sale) => sum + sale.totalRevenue);
      double totalCost = sales.fold(0.0, (sum, sale) => sum + sale.totalCost);
      double totalProfit = sales.fold(0.0, (sum, sale) => sum + sale.totalProfit);

      double totalExpenses = transactions
          .where((t) => t.type == TransactionType.expense)
          .fold(0.0, (sum, t) => sum + t.amount);

      double totalIncome = transactions
          .where((t) => t.type == TransactionType.income)
          .fold(0.0, (sum, t) => sum + t.amount);

      double netProfit = totalProfit + totalIncome - totalExpenses;

      // Improved Forecasting (Exponential Moving Average or Weighted Average)
      double projectedRevenue = 0;
      double projectedProfit = 0;
      
      if (dailyRevenue.isNotEmpty) {
        final sortedDates = dailyRevenue.keys.toList()..sort();
        double weightedRevenueSum = 0;
        double weightedProfitSum = 0;
        double weightSum = 0;
        
        // Give more weight to more recent days (linear weighting)
        for (int i = 0; i < sortedDates.length; i++) {
          double weight = (i + 1).toDouble();
          weightedRevenueSum += (dailyRevenue[sortedDates[i]] ?? 0.0) * weight;
          weightedProfitSum += (dailyProfit[sortedDates[i]] ?? 0.0) * weight;
          weightSum += weight;
        }
        
        double weightedAvgRevenue = weightedRevenueSum / weightSum;
        double weightedAvgProfit = weightedProfitSum / weightSum;
        
        // Project for the remainder of the month or next 30 days
        projectedRevenue = weightedAvgRevenue * 30;
        projectedProfit = weightedAvgProfit * 30;
      }

      return Right(BusinessReport(
        period: DateRange(startDate, endDate),
        totalRevenue: totalRevenue,
        totalCost: totalCost,
        totalProfit: totalProfit,
        totalExpenses: totalExpenses,
        totalIncome: totalIncome,
        netProfit: netProfit,
        dailyRevenue: dailyRevenue,
        dailyProfit: dailyProfit,
        topProducts: topProducts,
        lowTurnoverProducts: lowTurnoverProducts,
        debtAging: debtAging,
        stockSummary: stockSummary,
        projectedRevenue: projectedRevenue,
        projectedProfit: projectedProfit,
      ));
    } catch (e) {
      return Left(DatabaseFailure('Failed to generate business report: ${e.toString()}'));
    }
  }
}

class BusinessReport {
  final DateRange period;
  final double totalRevenue;
  final double totalCost;
  final double totalProfit;
  final double totalExpenses;
  final double totalIncome;
  final double netProfit;
  final Map<String, double> dailyRevenue;
  final Map<String, double> dailyProfit;
  final List<ProductAnalytics> topProducts;
  final List<ProductAnalytics> lowTurnoverProducts;
  final Map<String, double> debtAging;
  final Map<String, int> stockSummary;
  final double projectedRevenue;
  final double projectedProfit;

  const BusinessReport({
    required this.period,
    required this.totalRevenue,
    required this.totalCost,
    required this.totalProfit,
    required this.totalExpenses,
    required this.totalIncome,
    required this.netProfit,
    required this.dailyRevenue,
    required this.dailyProfit,
    required this.topProducts,
    required this.lowTurnoverProducts,
    required this.debtAging,
    required this.stockSummary,
    this.projectedRevenue = 0.0,
    this.projectedProfit = 0.0,
  });

  double get grossMargin => totalCost > 0 ? (totalProfit / totalRevenue) * 100 : 0.0;
}

class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange(this.start, this.end);

  @override
  String toString() => '${start.toString().split(' ')[0]} to ${end.toString().split(' ')[0]}';
}

class ReportParams {
  final DateTime startDate;
  final DateTime endDate;

  const ReportParams({
    required this.startDate,
    required this.endDate,
  });
}