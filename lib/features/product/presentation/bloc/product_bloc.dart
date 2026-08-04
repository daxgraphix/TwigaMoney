import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/product_usecases.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/error/failure.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUseCase getProductsUseCase;
  final AddProductUseCase addProductUseCase;
  final UpdateProductUseCase updateProductUseCase;
  final DeleteProductUseCase deleteProductUseCase;
  final UpdateStockUseCase updateStockUseCase;

  ProductBloc({
    required this.getProductsUseCase,
    required this.addProductUseCase,
    required this.updateProductUseCase,
    required this.deleteProductUseCase,
    required this.updateStockUseCase,
  }) : super(const ProductState()) {
    on<LoadProducts>(_onLoadProducts);
    on<AddProduct>(_onAddProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<DeleteProduct>(_onDeleteProduct);
    on<UpdateStock>(_onUpdateStock);
  }

  Future<void> _onLoadProducts(
      LoadProducts event, Emitter<ProductState> emit) async {
    emit(state.copyWith(status: ProductStatus.loading));
    
    final result = await TaskEither.tryCatch(
      () => getProductsUseCase(NoParams()),
      (error, stackTrace) => error is Failure ? error : DatabaseFailure('Failed to load products: $error'),
    ).flatMap((either) => TaskEither.fromEither(either)).run();

    result.fold(
      (failure) => emit(state.copyWith(
          status: ProductStatus.error, message: failure.message)),
      (products) => emit(
          state.copyWith(status: ProductStatus.loaded, products: products)),
    );
  }

  Future<void> _onAddProduct(
      AddProduct event, Emitter<ProductState> emit) async {
    emit(state.copyWith(status: ProductStatus.loading));
    
    final result = await TaskEither.tryCatch(
      () => addProductUseCase(event.product),
      (error, stackTrace) => error is Failure ? error : DatabaseFailure('Failed to add product: $error'),
    ).flatMap((either) => TaskEither.fromEither(either)).run();

    result.fold(
      (failure) => emit(state.copyWith(
          status: ProductStatus.error, message: failure.message)),
      (_) {
        emit(state.copyWith(
            status: ProductStatus.success,
            message: 'productAddedSuccessfully'));
        add(LoadProducts());
      },
    );
  }

  Future<void> _onUpdateProduct(
      UpdateProduct event, Emitter<ProductState> emit) async {
    emit(state.copyWith(status: ProductStatus.loading));

    final result = await TaskEither.tryCatch(
      () => updateProductUseCase(event.product),
      (error, stackTrace) => error is Failure ? error : DatabaseFailure('Failed to update product: $error'),
    ).flatMap((either) => TaskEither.fromEither(either)).run();

    result.fold(
      (failure) => emit(state.copyWith(
          status: ProductStatus.error, message: failure.message)),
      (_) {
        emit(state.copyWith(
            status: ProductStatus.success,
            message: 'productUpdatedSuccessfully'));
        add(LoadProducts());
      },
    );
  }

  Future<void> _onDeleteProduct(
      DeleteProduct event, Emitter<ProductState> emit) async {
    emit(state.copyWith(status: ProductStatus.loading));

    final result = await TaskEither.tryCatch(
      () => deleteProductUseCase(event.id),
      (error, stackTrace) => error is Failure ? error : DatabaseFailure('Failed to delete product: $error'),
    ).flatMap((either) => TaskEither.fromEither(either)).run();

    result.fold(
      (failure) => emit(state.copyWith(
          status: ProductStatus.error, message: failure.message)),
      (_) {
        emit(state.copyWith(
            status: ProductStatus.success,
            message: 'productDeletedSuccessfully'));
        add(LoadProducts());
      },
    );
  }

  Future<void> _onUpdateStock(
      UpdateStock event, Emitter<ProductState> emit) async {
    emit(state.copyWith(status: ProductStatus.loading));

    final result = await TaskEither.tryCatch(
      () => updateStockUseCase(UpdateStockParams(
        productId: event.productId,
        newStock: event.newStock,
      )),
      (error, stackTrace) => error is Failure ? error : DatabaseFailure('Failed to update stock: $error'),
    ).flatMap((either) => TaskEither.fromEither(either)).run();

    result.fold(
      (failure) => emit(state.copyWith(
          status: ProductStatus.error, message: failure.message)),
      (_) {
        emit(state.copyWith(
            status: ProductStatus.success,
            message: 'stockUpdatedSuccessfully'));
        add(LoadProducts());
      },
    );
  }
}
