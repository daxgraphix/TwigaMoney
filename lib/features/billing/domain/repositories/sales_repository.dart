import 'package:fpdart/fpdart.dart';
import 'package:twigamoney/core/error/failure.dart';
import 'package:twigamoney/features/billing/domain/entities/sales_transaction.dart';
import 'package:twigamoney/features/billing/domain/usecases/analytics_usecases.dart';

abstract class SalesRepository {
  Future<Either<Failure, void>> recordSale(SalesTransaction transaction);
  Future<Either<Failure, List<SalesTransaction>>> getSalesByDateRange(DateTime start, DateTime end);
  Future<Either<Failure, List<SalesTransaction>>> getCustomerTransactions(String customerId);
  Future<Either<Failure, List<ProductAnalytics>>> getTopPerformingProducts(DateTime start, DateTime end);
  Future<Either<Failure, List<ProductAnalytics>>> getLowTurnoverProducts();
  Future<Either<Failure, Map<String, double>>> getDailyRevenue(DateTime start, DateTime end);
  Future<Either<Failure, Map<String, double>>> getDailyProfit(DateTime start, DateTime end);
}