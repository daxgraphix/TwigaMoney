import 'package:fpdart/fpdart.dart';
import 'package:twigamoney/core/error/failure.dart';
import 'package:twigamoney/core/usecase/usecase.dart';
import 'package:twigamoney/features/billing/domain/repositories/sales_repository.dart';

class GetTopPerformingProductsUseCase implements UseCase<List<ProductAnalytics>, DateRangeParams> {
  final SalesRepository repository;

  GetTopPerformingProductsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ProductAnalytics>>> call(DateRangeParams params) {
    return repository.getTopPerformingProducts(params.startDate, params.endDate);
  }
}

class GetLowTurnoverProductsUseCase implements UseCase<List<ProductAnalytics>, NoParams> {
  final SalesRepository repository;

  GetLowTurnoverProductsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ProductAnalytics>>> call(NoParams params) {
    return repository.getLowTurnoverProducts();
  }
}

class ProductAnalytics {
  final String productId;
  final String productName;
  final double totalRevenue;
  final double totalProfit;
  final int totalSold;
  final double marginPercentage;
  final double turnoverRate;

  const ProductAnalytics({
    required this.productId,
    required this.productName,
    required this.totalRevenue,
    required this.totalProfit,
    required this.totalSold,
    required this.marginPercentage,
    required this.turnoverRate,
  });
}

class DateRangeParams {
  final DateTime startDate;
  final DateTime endDate;

  const DateRangeParams({
    required this.startDate,
    required this.endDate,
  });
}