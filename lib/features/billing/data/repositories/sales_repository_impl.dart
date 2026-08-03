import 'package:fpdart/fpdart.dart';
import 'package:twigamoney/core/data/hive_database.dart';
import 'package:twigamoney/core/error/failure.dart';
import 'package:twigamoney/features/billing/domain/entities/sales_transaction.dart';
import 'package:twigamoney/features/billing/domain/repositories/sales_repository.dart';
import 'package:twigamoney/features/billing/domain/usecases/analytics_usecases.dart';

class SalesRepositoryImpl implements SalesRepository {
  const SalesRepositoryImpl();

  @override
  Future<Either<Failure, void>> recordSale(SalesTransaction transaction) async {
    try {
      final box = HiveDatabase.salesTransactionBox;
      await box.put(transaction.id, transaction);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to record sale: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<SalesTransaction>>> getSalesByDateRange(DateTime start, DateTime end) async {
    try {
      final box = HiveDatabase.salesTransactionBox;
      final transactions = box.values.where((t) =>
          t.timestamp.isAfter(start.subtract(const Duration(days: 1))) &&
          t.timestamp.isBefore(end.add(const Duration(days: 1)))).toList();
      return Right(transactions);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get sales by date range: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<SalesTransaction>>> getCustomerTransactions(String customerId) async {
    try {
      final box = HiveDatabase.salesTransactionBox;
      final transactions = box.values.where((t) => t.customerId == customerId).toList();
      return Right(transactions);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get customer transactions: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ProductAnalytics>>> getTopPerformingProducts(DateTime start, DateTime end) async {
    try {
      final salesResult = await getSalesByDateRange(start, end);
      return salesResult.fold(
        (failure) => Left(failure),
        (transactions) {
          final productMap = <String, Map<String, dynamic>>{};

          for (final transaction in transactions) {
            if (!productMap.containsKey(transaction.productId)) {
              productMap[transaction.productId] = {
                'name': transaction.productName,
                'revenue': 0.0,
                'profit': 0.0,
                'sold': 0,
                'margin': 0.0,
              };
            }

            final data = productMap[transaction.productId]!;
            data['revenue'] += transaction.totalRevenue;
            data['profit'] += transaction.totalProfit;
            data['sold'] += transaction.quantity;
            data['margin'] = transaction.marginPercentage;
          }

          final analytics = productMap.entries.map((entry) {
            final data = entry.value;
            final currentStock = _getCurrentStock(entry.key);
            final turnoverRate = currentStock > 0 ? data['sold'] / currentStock : 0.0;

            return ProductAnalytics(
              productId: entry.key,
              productName: data['name'],
              totalRevenue: data['revenue'],
              totalProfit: data['profit'],
              totalSold: data['sold'],
              marginPercentage: data['margin'],
              turnoverRate: turnoverRate,
            );
          }).toList();

          analytics.sort((a, b) => b.totalProfit.compareTo(a.totalProfit));
          return Right(analytics.take(10).toList()); // Top 10 products
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Failed to get top performing products: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ProductAnalytics>>> getLowTurnoverProducts() async {
    try {
      final productBox = HiveDatabase.productBox;
      final lowTurnoverProducts = <ProductAnalytics>[];

      for (final productModel in productBox.values) {
        final product = productModel.toEntity();
        if (product.isLowTurnover && product.stock > 0) {
          lowTurnoverProducts.add(ProductAnalytics(
            productId: product.id,
            productName: product.name,
            totalRevenue: 0.0, // Would need sales data for this
            totalProfit: 0.0,
            totalSold: product.totalSold,
            marginPercentage: product.marginPercentage,
            turnoverRate: product.turnoverRate,
          ));
        }
      }

      lowTurnoverProducts.sort((a, b) => a.turnoverRate.compareTo(b.turnoverRate));
      return Right(lowTurnoverProducts.take(10).toList());
    } catch (e) {
      return Left(DatabaseFailure('Failed to get low turnover products: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, double>>> getDailyRevenue(DateTime start, DateTime end) async {
    try {
      final salesResult = await getSalesByDateRange(start, end);
      return salesResult.fold(
        (failure) => Left(failure),
        (transactions) {
          final dailyRevenue = <String, double>{};

          for (final transaction in transactions) {
            final dateKey = _formatDateKey(transaction.timestamp);
            dailyRevenue[dateKey] = (dailyRevenue[dateKey] ?? 0.0) + transaction.totalRevenue;
          }

          return Right(dailyRevenue);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Failed to get daily revenue: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, double>>> getDailyProfit(DateTime start, DateTime end) async {
    try {
      final salesResult = await getSalesByDateRange(start, end);
      return salesResult.fold(
        (failure) => Left(failure),
        (transactions) {
          final dailyProfit = <String, double>{};

          for (final transaction in transactions) {
            final dateKey = _formatDateKey(transaction.timestamp);
            dailyProfit[dateKey] = (dailyProfit[dateKey] ?? 0.0) + transaction.totalProfit;
          }

          return Right(dailyProfit);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Failed to get daily profit: ${e.toString()}'));
    }
  }

  int _getCurrentStock(String productId) {
    final productBox = HiveDatabase.productBox;
    final productModel = productBox.get(productId);
    return productModel?.stock ?? 0;
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}