import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/sales_transaction.dart';
import 'package:twigamoney/features/product/domain/entities/product.dart';
import 'package:twigamoney/features/product/domain/usecases/product_usecases.dart';
import '../../domain/repositories/sales_repository.dart';
import '../../../product/domain/repositories/stock_repository.dart';
import '../../../product/domain/entities/stock_movement.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../domain/entities/customer_transaction.dart';

part 'billing_event.dart';
part 'billing_state.dart';

class BillingBloc extends Bloc<BillingEvent, BillingState> {
  final GetProductByBarcodeUseCase getProductByBarcodeUseCase;
  final DecrementStockUseCase decrementStockUseCase;
  final SalesRepository salesRepository;
  final StockRepository stockRepository;
  final CustomerRepository customerRepository;

  BillingBloc({
    required this.getProductByBarcodeUseCase,
    required this.decrementStockUseCase,
    required this.salesRepository,
    required this.stockRepository,
    required this.customerRepository,
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
    // Clear error when adding
    final cleanState = state.copyWith(error: null);

    final existingIndex = cleanState.cartItems
        .indexWhere((item) => item.product.id == event.product.id);
    List<CartItem> updatedItems;
    if (existingIndex >= 0) {
      final existingItem = cleanState.cartItems[existingIndex];
      updatedItems = List<CartItem>.from(cleanState.cartItems);
      updatedItems[existingIndex] =
          existingItem.copyWith(quantity: existingItem.quantity + event.quantity);
    } else {
      final newItem = CartItem(product: event.product, quantity: event.quantity);
      updatedItems = [...cleanState.cartItems, newItem];
    }
    final newTotal = _calculateTotal(updatedItems);
    emit(cleanState.copyWith(cartItems: updatedItems, totalAmount: newTotal, error: null));
  }

  void _onRemoveProductFromCart(
      RemoveProductFromCartEvent event, Emitter<BillingState> emit) {
    final updatedList = state.cartItems
        .where((item) => item.product.id != event.productId)
        .toList();
    final newTotal = _calculateTotal(updatedList);
    emit(state.copyWith(cartItems: updatedList, totalAmount: newTotal));
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
      final items = List<CartItem>.from(state.cartItems);
      items[index] = items[index].copyWith(quantity: event.quantity);
      final newTotal = _calculateTotal(items);
      emit(state.copyWith(cartItems: items, totalAmount: newTotal));
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

    try {
      double totalSaleAmount = state.totalAmount;

      // If this is a credit sale, check customer credit limit
      if (event.customerId != 'cash') {
        final customerResult = await customerRepository.getCustomerById(event.customerId);
        customerResult.fold(
          (failure) => throw Exception('Customer not found: ${failure.message}'),
          (customer) {
            if (customer == null) {
              throw Exception('Customer not found');
            }
            if (customer.currentBalance + totalSaleAmount > customer.creditLimit && customer.creditLimit > 0) {
              throw Exception('Sale would exceed customer credit limit');
            }
          },
        );
      }

      // Record each cart item as a sales transaction
      for (final cartItem in state.cartItems) {
        final transactionId = '${event.shiftId}_${cartItem.product.id}_${DateTime.now().millisecondsSinceEpoch}';

        final transaction = SalesTransaction(
          id: transactionId,
          productId: cartItem.product.id,
          productName: cartItem.product.name,
          sellingPrice: cartItem.product.price,
          costPrice: cartItem.product.costPrice,
          quantity: cartItem.quantity,
          timestamp: DateTime.now(),
          shiftId: event.shiftId,
          customerId: event.customerId,
        );

        final result = await salesRepository.recordSale(transaction);
        result.fold(
          (failure) => throw Exception('Failed to record sale: ${failure.message}'),
          (_) => null,
        );

        // Record stock movement for sale
        final stockMovement = StockMovement(
          id: '${transactionId}_movement',
          productId: cartItem.product.id,
          type: MovementType.sale,
          quantity: -cartItem.quantity, // Negative for reduction
          previousStock: cartItem.product.stock,
          newStock: cartItem.product.stock - cartItem.quantity,
          timestamp: DateTime.now(),
          reference: transactionId,
          notes: 'Sale to customer ${event.customerId}',
        );

        final movementResult = await stockRepository.recordStockMovement(stockMovement);
        movementResult.fold(
          (failure) => throw Exception('Failed to record stock movement: ${failure.message}'),
          (_) => null,
        );

        // Decrement stock
        final stockResult = await decrementStockUseCase(
          DecrementStockParams(
            cartItem.product.id,
            cartItem.quantity,
          ),
        );

        stockResult.fold(
          (failure) => throw Exception('Failed to update stock: ${failure.message}'),
          (_) => null,
        );
      }

      // Record customer transaction for credit sales
      if (event.customerId != 'cash') {
        final customerResult = await customerRepository.getCustomerById(event.customerId);
        final customer = customerResult.getOrElse((_) => throw Exception('Customer not found'));

        final customerTransaction = CustomerTransaction(
          id: '${event.shiftId}_credit_${DateTime.now().millisecondsSinceEpoch}',
          customerId: event.customerId,
          type: CustomerTransactionType.creditSale,
          amount: totalSaleAmount,
          previousBalance: customer!.currentBalance,
          newBalance: customer.currentBalance + totalSaleAmount,
          timestamp: DateTime.now(),
          reference: event.shiftId,
          notes: 'Credit sale for shift ${event.shiftId}',
        );

        final customerTransactionResult = await customerRepository.recordCustomerTransaction(customerTransaction);
        customerTransactionResult.fold(
          (failure) => throw Exception('Failed to record customer transaction: ${failure.message}'),
          (_) => null,
        );
      }

      emit(state.copyWith(
        isProcessingSale: false,
        saleCompleted: true,
        cartItems: [],
        totalAmount: 0.0,
      ));

      // Reset sale completed flag after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        if (!isClosed) {
          add(const ClearSaleCompletedEvent());
        }
      });
    } catch (e) {
      emit(state.copyWith(
        isProcessingSale: false,
        error: 'Sale failed: $e',
      ));
    }
  }
}
