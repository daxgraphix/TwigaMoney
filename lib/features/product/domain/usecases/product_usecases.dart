import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProductsUseCase implements UseCase<List<Product>, NoParams> {
  final ProductRepository repository;

  GetProductsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Product>>> call(NoParams params) {
    return repository.getProducts();
  }
}

class AddProductUseCase implements UseCase<void, Product> {
  final ProductRepository repository;

  AddProductUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(Product params) {
    return repository.addProduct(params);
  }
}

class UpdateProductUseCase implements UseCase<void, Product> {
  final ProductRepository repository;

  UpdateProductUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(Product params) {
    return repository.updateProduct(params);
  }
}

class DeleteProductUseCase implements UseCase<void, String> {
  final ProductRepository repository;

  DeleteProductUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) {
    return repository.deleteProduct(params);
  }
}

class GetProductByBarcodeUseCase implements UseCase<Product, String> {
  final ProductRepository repository;

  GetProductByBarcodeUseCase(this.repository);

  @override
  Future<Either<Failure, Product>> call(String params) {
    return repository.getProductByBarcode(params);
  }
}

class UpdateStockUseCase implements UseCase<void, UpdateStockParams> {
  final ProductRepository repository;

  UpdateStockUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateStockParams params) {
    return repository.updateStock(params.productId, params.newStock, params.totalSoldIncrement);
  }
}

class UpdateStockParams {
  final String productId;
  final int newStock;
  final int totalSoldIncrement;

  UpdateStockParams({
    required this.productId,
    required this.newStock,
    this.totalSoldIncrement = 0,
  });
}

class DecrementStockUseCase implements UseCase<void, DecrementStockParams> {
  final ProductRepository repository;

  DecrementStockUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DecrementStockParams params) {
    return repository.decrementStock(params.productId, params.quantity);
  }
}

class DecrementStockParams {
  final String productId;
  final int quantity;

  DecrementStockParams(this.productId, this.quantity);
}
