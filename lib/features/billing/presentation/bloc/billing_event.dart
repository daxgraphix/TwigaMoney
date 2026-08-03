part of 'billing_bloc.dart';

abstract class BillingEvent extends Equatable {
  const BillingEvent();

  @override
  List<Object?> get props => [];
}

class ScanBarcodeEvent extends BillingEvent {
  final String barcode;
  const ScanBarcodeEvent(this.barcode);
  @override
  List<Object> get props => [barcode];
}

class AddProductToCartEvent extends BillingEvent {
  final Product product;
  final int quantity;
  const AddProductToCartEvent(this.product, {this.quantity = 1});
  @override
  List<Object> get props => [product, quantity];
}

class RemoveProductFromCartEvent extends BillingEvent {
  final String productId;
  const RemoveProductFromCartEvent(this.productId);
  @override
  List<Object> get props => [productId];
}

class UpdateQuantityEvent extends BillingEvent {
  final String productId;
  final int quantity;
  const UpdateQuantityEvent(this.productId, this.quantity);
  @override
  List<Object> get props => [productId, quantity];
}

class ClearCartEvent extends BillingEvent {}

class CompleteSaleEvent extends BillingEvent {
  final String shiftId;
  final String customerId;

  const CompleteSaleEvent({
    required this.shiftId,
    this.customerId = 'cash',
  });

  @override
  List<Object> get props => [shiftId, customerId];
}

class ClearSaleCompletedEvent extends BillingEvent {
  const ClearSaleCompletedEvent();
}
