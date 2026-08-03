import 'package:fpdart/fpdart.dart';
import '../../../../core/data/hive_database.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl();

  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    try {
      final box = HiveDatabase.productBox;
      final products = box.values.toList();
      return Right(products);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Product>> getProductByBarcode(String barcode) async {
    try {
      final box = HiveDatabase.productBox;
      final product = box.values.firstWhere(
        (element) => element.barcode == barcode,
        orElse: () => throw Exception('Product not found'),
      );
      return Right(product);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addProduct(Product product) async {
    try {
      final box = HiveDatabase.productBox;
      // You can use add() or put()
      final model = ProductModel.fromEntity(product);
      await box.put(model.id, model); // Using ID as key
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateProduct(Product product) async {
    try {
      final box = HiveDatabase.productBox;
      final model = ProductModel.fromEntity(product);
      await box.put(model.id, model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async {
    try {
      final box = HiveDatabase.productBox;
      await box.delete(id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

   @override
   Future<Either<Failure, void>> updateStock(String productId, int newStock, [int totalSoldIncrement = 0]) async {
     try {
       final box = HiveDatabase.productBox;
       final product = box.get(productId);
       if (product == null) {
         return const Left(CacheFailure('Product not found'));
       }
      final updatedProduct = ProductModel(
        id: product.id,
        name: product.name,
        barcode: product.barcode,
        price: product.price,
        costPrice: product.costPrice,
        stock: newStock,
        minStockThreshold: product.minStockThreshold,
        category: product.category,
        discountPercentage: product.discountPercentage,
        taxPercentage: product.taxPercentage,
        lastStockUpdate: DateTime.now(),
        totalSold: product.totalSold + totalSoldIncrement,
      );
      await box.put(productId, updatedProduct);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> decrementStock(String productId, int quantity) async {
    try {
      final box = HiveDatabase.productBox;
      final product = box.get(productId);
      if (product == null) {
        return const Left(CacheFailure('Product not found'));
      }
      if (product.stock < quantity) {
        return const Left(CacheFailure('Insufficient stock'));
      }
      final newStock = product.stock - quantity;
      final updatedProduct = ProductModel(
        id: product.id,
        name: product.name,
        barcode: product.barcode,
        price: product.price,
        costPrice: product.costPrice,
        stock: newStock,
        minStockThreshold: product.minStockThreshold,
        category: product.category,
        discountPercentage: product.discountPercentage,
        taxPercentage: product.taxPercentage,
        lastStockUpdate: DateTime.now(),
        totalSold: product.totalSold + quantity,
      );
      await box.put(productId, updatedProduct);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
