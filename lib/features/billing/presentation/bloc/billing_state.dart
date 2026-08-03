part of 'billing_bloc.dart';

class BillingState extends Equatable {
  final List<CartItem> cartItems;
  final double totalAmount;
  final String? error;
  final bool isProcessingSale;
  final bool saleCompleted;

  const BillingState({
    this.cartItems = const [],
    this.totalAmount = 0.0,
    this.error,
    this.isProcessingSale = false,
    this.saleCompleted = false,
  });

  BillingState copyWith({
    List<CartItem>? cartItems,
    double? totalAmount,
    String? error,
    bool clearError = false,
    bool? isProcessingSale,
    bool? saleCompleted,
  }) {
    return BillingState(
      cartItems: cartItems ?? this.cartItems,
      totalAmount: totalAmount ?? this.totalAmount,
      error: clearError ? null : (error ?? this.error),
      isProcessingSale: isProcessingSale ?? this.isProcessingSale,
      saleCompleted: saleCompleted ?? this.saleCompleted,
    );
  }

  @override
  List<Object?> get props => [
        cartItems,
        totalAmount,
        error,
        isProcessingSale,
        saleCompleted,
      ];
}
