part of 'customer_bloc.dart';

abstract class CustomerState extends Equatable {
  const CustomerState();
  
  @override
  List<Object?> get props => [];
}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

class CustomerLoaded extends CustomerState {
  final List<Customer> customers;
  final List<Customer> filteredCustomers;
  final String searchQuery;

  const CustomerLoaded({
    required this.customers,
    this.filteredCustomers = const [],
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [customers, filteredCustomers, searchQuery];

  CustomerLoaded copyWith({
    List<Customer>? customers,
    List<Customer>? filteredCustomers,
    String? searchQuery,
  }) {
    return CustomerLoaded(
      customers: customers ?? this.customers,
      filteredCustomers: filteredCustomers ?? this.filteredCustomers,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class CustomerError extends CustomerState {
  final String message;
  const CustomerError(this.message);

  @override
  List<Object?> get props => [message];
}

class CustomerOperationSuccess extends CustomerState {
  final String message;
  const CustomerOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
