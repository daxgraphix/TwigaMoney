import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:twigamoney/core/error/failure.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/usecases/complete_sale_usecase.dart';
import 'package:twigamoney/features/product/domain/entities/product.dart';
import 'package:twigamoney/features/product/domain/usecases/product_usecases.dart';

part 'billing_event.dart';
part 'billing_state.dart';

class BillingBloc extends Bloc<BillingEvent, BillingState> {
  final GetProductByBarcodeUseCase getProductByBarcodeUseCase;
  final CompleteSaleUseCase completeSaleUseCase;

  BillingBloc({
    required this.getProductByBarcodeUseCase,
    required this.completeSaleUseCase,
  }) : super(const BillingState()) {
    on<AddProductToCartEvent>(_onAddProductToCart);
    on<RemoveProductFromCartEvent>(_onRemoveProductFromCart);
    on<UpdateQuantityEvent>(_onUpdateQuantity);
    on<ClearCartEvent>(_onClearCart);
    on<CompleteSaleEvent>(_onCompleteSale);
    on<ClearSaleCompletedEvent>(_onClearSaleCompleted);
  }

  double _calculateTotal(List<CartItem> cartItems) {
    return cartItems.fold(0.0, (sum, item) => sum + item.total);
  }

  void _onAddProductToCart(
      AddProductToCartEvent event, Emitter<BillingState> emit) {
    final existingIndex = state.cartItems
        .indexWhere((item) => item.product.id == event.product.id);
    
    int currentInCart = 0;
    if (existingIndex >= 0) {
      currentInCart = state.cartItems[existingIndex].quantity;
    }

    if (event.product.stock < currentInCart + event.quantity) {
      emit(state.copyWith(
        error: 'Insufficient stock for ${event.product.name}. Available: ${event.product.stock}, In Cart: $currentInCart',
      ));
      return;
    }

    List<CartItem> updatedItems;
    if (existingIndex >= 0) {
      final existingItem = state.cartItems[existingIndex];
      updatedItems = List<CartItem>.from(state.cartItems);
      updatedItems[existingIndex] =
          existingItem.copyWith(quantity: existingItem.quantity + event.quantity);
    } else {
      final newItem = CartItem(product: event.product, quantity: event.quantity);
      updatedItems = [...state.cartItems, newItem];
    }
    
    emit(state.copyWith(
      cartItems: updatedItems, 
      totalAmount: _calculateTotal(updatedItems), 
      error: null,
    ));
  }

  void _onRemoveProductFromCart(
      RemoveProductFromCartEvent event, Emitter<BillingState> emit) {
    final updatedItems = state.cartItems
        .where((item) => item.product.id != event.productId)
        .toList();
    emit(state.copyWith(
      cartItems: updatedItems,
      totalAmount: _calculateTotal(updatedItems),
      error: null,
    ));
  }

  void _onUpdateQuantity(
      UpdateQuantityEvent event, Emitter<BillingState> emit) {
    if (event.quantity <= 0) {
      add(RemoveProductFromCartEvent(event.productId));
      return;
    }

    final index = state.cartItems
        .indexWhere((item) => item.product.id == event.productId);
    
    if (index >= 0) {
      final product = state.cartItems[index].product;
      
      if (product.stock < event.quantity) {
        emit(state.copyWith(
          error: 'Cannot update quantity. Only ${product.stock} available for ${product.name}.',
        ));
        return;
      }

      final items = List<CartItem>.from(state.cartItems);
      items[index] = items[index].copyWith(quantity: event.quantity);
      emit(state.copyWith(
        cartItems: items, 
        totalAmount: _calculateTotal(items), 
        error: null,
      ));
    }
  }

  void _onClearCart(ClearCartEvent event, Emitter<BillingState> emit) {
    emit(const BillingState());
  }

  void _onClearSaleCompleted(
      ClearSaleCompletedEvent event, Emitter<BillingState> emit) {
    emit(state.copyWith(saleCompleted: false));
  }

  Future<void> _onCompleteSale(
      CompleteSaleEvent event, Emitter<BillingState> emit) async {
    if (state.cartItems.isEmpty) {
      emit(state.copyWith(error: 'Cart is empty'));
      return;
    }

    emit(state.copyWith(isProcessingSale: true, error: null));

    final result = await TaskEither<Failure, void>(() => completeSaleUseCase(CompleteSaleParams(
      cartItems: state.cartItems,
      totalAmount: state.totalAmount,
      customerId: event.customerId,
      shiftId: event.shiftId,
    ))).run();

    result.fold(
      (failure) => emit(state.copyWith(
        isProcessingSale: false,
        error: failure.message,
      )),
      (_) {
        emit(state.copyWith(
          isProcessingSale: false,
          saleCompleted: true,
          cartItems: [],
          totalAmount: 0.0,
        ));

        Future.delayed(const Duration(seconds: 2), () {
          if (!isClosed) {
            add(const ClearSaleCompletedEvent());
          }
        });
      },
    );
  }
}
