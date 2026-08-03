import 'package:fpdart/fpdart.dart';
import 'package:twigamoney/core/data/hive_database.dart';
import 'package:twigamoney/core/error/failure.dart';
import 'package:twigamoney/features/product/domain/entities/stock_movement.dart';
import 'package:twigamoney/features/product/domain/repositories/stock_repository.dart';

class StockRepositoryImpl implements StockRepository {
  const StockRepositoryImpl();

  @override
  Future<Either<Failure, void>> recordStockMovement(StockMovement movement) async {
    try {
      final box = HiveDatabase.stockMovementBox;
      await box.put(movement.id, movement);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to record stock movement: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<StockMovement>>> getStockMovements(String productId) async {
    try {
      final box = HiveDatabase.stockMovementBox;
      final movements = box.values.where((m) => m.productId == productId).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Most recent first
      return Right(movements);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get stock movements: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getLowStockAlerts() async {
    try {
      final productBox = HiveDatabase.productBox;
      final lowStockProducts = <String>[];

      for (final productModel in productBox.values) {
        final product = productModel.toEntity();
        if (product.isLowStock) {
          lowStockProducts.add('${product.name} (${product.stock}/${product.minStockThreshold})');
        }
      }

      return Right(lowStockProducts);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get low stock alerts: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> addProcurement(String productId, int quantity, String reference) async {
    try {
      final productBox = HiveDatabase.productBox;
      final productModel = productBox.get(productId);

       if (productModel == null) {
         return const Left(NotFoundFailure('Product not found'));
       }

      final product = productModel.toEntity();
      final previousStock = product.stock;
      final newStock = previousStock + quantity;

      final movement = StockMovement(
        id: '${productId}_procurement_${DateTime.now().millisecondsSinceEpoch}',
        productId: productId,
        type: MovementType.procurement,
        quantity: quantity,
        previousStock: previousStock,
        newStock: newStock,
        timestamp: DateTime.now(),
        reference: reference,
        notes: 'Procurement added $quantity units',
      );

      // Record movement
      await recordStockMovement(movement);

      // Update product stock
      final updatedProduct = product.copyWith(
        stock: newStock,
        lastStockUpdate: DateTime.now(),
      );

      await productBox.put(productId, productModel.copyWith(
        stock: updatedProduct.stock,
        lastStockUpdate: updatedProduct.lastStockUpdate,
      ));

      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to add procurement: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getStockSummary() async {
    try {
      final productBox = HiveDatabase.productBox;
      int totalProducts = 0;
      int lowStockCount = 0;
      int outOfStockCount = 0;
      int totalStockValue = 0;

      for (final productModel in productBox.values) {
        final product = productModel.toEntity();
        totalProducts++;
        totalStockValue += (product.stock * product.costPrice).round();

        if (product.stock <= 0) {
          outOfStockCount++;
        } else if (product.isLowStock) {
          lowStockCount++;
        }
      }

      return Right({
        'totalProducts': totalProducts,
        'lowStockCount': lowStockCount,
        'outOfStockCount': outOfStockCount,
        'totalStockValue': totalStockValue,
      });
    } catch (e) {
      return Left(DatabaseFailure('Failed to get stock summary: ${e.toString()}'));
    }
  }
}