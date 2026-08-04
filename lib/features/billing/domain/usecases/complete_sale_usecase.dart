import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../product/domain/entities/stock_movement.dart';
import '../../../product/domain/repositories/stock_repository.dart';
import '../../../product/domain/usecases/product_usecases.dart';
import '../entities/cart_item.dart';
import '../entities/customer_transaction.dart';
import '../entities/sales_transaction.dart';
import '../repositories/customer_repository.dart';
import '../repositories/sales_repository.dart';

import '../../../../core/data/hive_database.dart';

class CompleteSaleUseCase implements UseCase<void, CompleteSaleParams> {
  final SalesRepository salesRepository;
  final StockRepository stockRepository;
  final CustomerRepository customerRepository;
  final DecrementStockUseCase decrementStockUseCase;

  CompleteSaleUseCase({
    required this.salesRepository,
    required this.stockRepository,
    required this.customerRepository,
    required this.decrementStockUseCase,
  });

  @override
  Future<Either<Failure, void>> call(CompleteSaleParams params) async {
    return TaskEither<Failure, void>(() async {
      // 1. Validation: Check credit limit if not a cash sale
      if (params.customerId != 'cash') {
        final customerResult = await customerRepository.getCustomerById(params.customerId);
        final validationResult = customerResult.flatMap((customer) {
          if (customer == null) return const Left(NotFoundFailure('Customer not found'));
          if (customer.creditLimit > 0 &&
              customer.currentBalance + params.totalAmount > customer.creditLimit) {
            return const Left(ValidationFailure('Sale would exceed customer credit limit'));
          }
          return const Right(null);
        });
        if (validationResult.isLeft()) {
          return validationResult;
        }
      }

      // 2. Process items
      double totalSaleProfit = 0;
      for (final cartItem in params.cartItems) {
        final transactionId =
            '${params.shiftId}_${cartItem.product.id}_${DateTime.now().millisecondsSinceEpoch}';

        // Record Sale
        final saleTransaction = SalesTransaction(
          id: transactionId,
          productId: cartItem.product.id,
          productName: cartItem.product.name,
          sellingPrice: cartItem.product.price,
          costPrice: cartItem.product.costPrice,
          quantity: cartItem.quantity,
          timestamp: DateTime.now(),
          shiftId: params.shiftId,
          customerId: params.customerId,
        );
        
        totalSaleProfit += saleTransaction.totalProfit;

        final saleResult = await salesRepository.recordSale(saleTransaction);
        if (saleResult.isLeft()) {
          return saleResult;
        }
        
        // ... (rest of the loop)

        // Record Stock Movement
        final stockMovement = StockMovement(
          id: '${transactionId}_movement',
          productId: cartItem.product.id,
          type: MovementType.sale,
          quantity: -cartItem.quantity,
          previousStock: cartItem.product.stock,
          newStock: cartItem.product.stock - cartItem.quantity,
          timestamp: DateTime.now(),
          reference: transactionId,
          notes: 'Sale to customer ${params.customerId}',
        );

        final movementResult = await stockRepository.recordStockMovement(stockMovement);
        if (movementResult.isLeft()) {
          return movementResult;
        }

        // Update Stock
        final stockUpdateResult = await decrementStockUseCase(
          DecrementStockParams(cartItem.product.id, cartItem.quantity),
        );
        if (stockUpdateResult.isLeft()) {
          return stockUpdateResult;
        }
      }

      // 2.5 Update current shift totals
      final shiftBox = HiveDatabase.shiftBox;
      final currentShift = shiftBox.get('current_shift');
      if (currentShift != null && currentShift.id == params.shiftId) {
        await shiftBox.put('current_shift', currentShift.copyWith(
          totalSales: currentShift.totalSales + params.totalAmount,
          totalProfit: currentShift.totalProfit + totalSaleProfit,
        ));
      }

      // 3. Record Customer Transaction for credit sales
      if (params.customerId != 'cash') {
        final customerResult = await customerRepository.getCustomerById(params.customerId);
        return await customerResult.fold(
          (failure) async => Left(failure),
          (customer) async {
            if (customer == null) return const Left(NotFoundFailure('Customer not found'));

            final customerTransaction = CustomerTransaction(
              id: '${params.shiftId}_credit_${DateTime.now().millisecondsSinceEpoch}',
              customerId: params.customerId,
              type: CustomerTransactionType.creditSale,
              amount: params.totalAmount,
              previousBalance: customer.currentBalance,
              newBalance: customer.currentBalance + params.totalAmount,
              timestamp: DateTime.now(),
              reference: params.shiftId,
              notes: 'Credit sale for shift ${params.shiftId}',
            );

            return await customerRepository.recordCustomerTransaction(customerTransaction);
          },
        );
      }

      return const Right(null);
    }).run();
  }
}

class CompleteSaleParams {
  final List<CartItem> cartItems;
  final double totalAmount;
  final String customerId;
  final String shiftId;

  CompleteSaleParams({
    required this.cartItems,
    required this.totalAmount,
    required this.customerId,
    required this.shiftId,
  });
}
