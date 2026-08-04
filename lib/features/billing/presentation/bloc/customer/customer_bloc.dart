import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:twigamoney/core/usecase/usecase.dart';
import '../../../domain/entities/customer.dart';
import '../../../domain/usecases/customer_usecases.dart';

part 'customer_event.dart';
part 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final GetCustomersUseCase getCustomersUseCase;
  final AddCustomerUseCase addCustomerUseCase;
  final UpdateCustomerUseCase updateCustomerUseCase;
  final DeleteCustomerUseCase deleteCustomerUseCase;

  CustomerBloc({
    required this.getCustomersUseCase,
    required this.addCustomerUseCase,
    required this.updateCustomerUseCase,
    required this.deleteCustomerUseCase,
  }) : super(CustomerInitial()) {
    on<LoadCustomersEvent>(_onLoadCustomers);
    on<SearchCustomersEvent>(_onSearchCustomers);
    on<AddCustomerEvent>(_onAddCustomer);
    on<UpdateCustomerEvent>(_onUpdateCustomer);
    on<DeleteCustomerEvent>(_onDeleteCustomer);
  }

  Future<void> _onLoadCustomers(
      LoadCustomersEvent event, Emitter<CustomerState> emit) async {
    emit(CustomerLoading());
    
    final result = await getCustomersUseCase(NoParams());

    result.fold(
      (failure) => emit(CustomerError(failure.message)),
      (customers) => emit(CustomerLoaded(
        customers: customers,
        filteredCustomers: customers,
      )),
    );
  }

  void _onSearchCustomers(
      SearchCustomersEvent event, Emitter<CustomerState> emit) {
    if (state is CustomerLoaded) {
      final currentState = state as CustomerLoaded;
      final query = event.query.toLowerCase();
      
      final filtered = currentState.customers.where((customer) {
        return customer.name.toLowerCase().contains(query) ||
               customer.phone.toLowerCase().contains(query) ||
               customer.email.toLowerCase().contains(query);
      }).toList();

      emit(currentState.copyWith(
        filteredCustomers: filtered,
        searchQuery: event.query,
      ));
    }
  }

  Future<void> _onAddCustomer(
      AddCustomerEvent event, Emitter<CustomerState> emit) async {
    final result = await addCustomerUseCase(event.customer);

    result.fold(
      (failure) => emit(CustomerError(failure.message)),
      (_) {
        emit(const CustomerOperationSuccess('Customer added successfully'));
        add(LoadCustomersEvent());
      },
    );
  }

  Future<void> _onUpdateCustomer(
      UpdateCustomerEvent event, Emitter<CustomerState> emit) async {
    final result = await updateCustomerUseCase(event.customer);

    result.fold(
      (failure) => emit(CustomerError(failure.message)),
      (_) {
        emit(const CustomerOperationSuccess('Customer updated successfully'));
        add(LoadCustomersEvent());
      },
    );
  }

  Future<void> _onDeleteCustomer(
      DeleteCustomerEvent event, Emitter<CustomerState> emit) async {
    final result = await deleteCustomerUseCase(event.customerId);

    result.fold(
      (failure) => emit(CustomerError(failure.message)),
      (_) {
        emit(const CustomerOperationSuccess('Customer deleted successfully'));
        add(LoadCustomersEvent());
      },
    );
  }
}
