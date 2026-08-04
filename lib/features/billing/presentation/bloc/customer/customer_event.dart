part of 'customer_bloc.dart';

abstract class CustomerEvent extends Equatable {
  const CustomerEvent();

  @override
  List<Object?> get props => [];
}

class LoadCustomersEvent extends CustomerEvent {}

class SearchCustomersEvent extends CustomerEvent {
  final String query;
  const SearchCustomersEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class AddCustomerEvent extends CustomerEvent {
  final Customer customer;
  const AddCustomerEvent(this.customer);

  @override
  List<Object?> get props => [customer];
}

class UpdateCustomerEvent extends CustomerEvent {
  final Customer customer;
  const UpdateCustomerEvent(this.customer);

  @override
  List<Object?> get props => [customer];
}

class DeleteCustomerEvent extends CustomerEvent {
  final String customerId;
  const DeleteCustomerEvent(this.customerId);

  @override
  List<Object?> get props => [customerId];
}
