import 'package:fpdart/fpdart.dart';
import 'package:twigamoney/core/error/failure.dart';
import 'package:twigamoney/features/product/domain/entities/stock_movement.dart';

abstract class StockRepository {
  Future<Either<Failure, void>> recordStockMovement(StockMovement movement);
  Future<Either<Failure, List<StockMovement>>> getStockMovements(String productId);
  Future<Either<Failure, List<String>>> getLowStockAlerts();
  Future<Either<Failure, void>> addProcurement(String productId, int quantity, String reference);
  Future<Either<Failure, Map<String, int>>> getStockSummary();
}