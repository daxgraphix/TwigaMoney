import 'package:fpdart/fpdart.dart';
import 'package:twigamoney/core/error/failure.dart';
import 'package:twigamoney/features/billing/domain/entities/customer.dart';
import 'package:twigamoney/features/billing/domain/entities/customer_transaction.dart';

abstract class CustomerRepository {
  Future<Either<Failure, List<Customer>>> getCustomers();
  Future<Either<Failure, Customer?>> getCustomerById(String id);
  Future<Either<Failure, Customer>> addCustomer(Customer customer);
  Future<Either<Failure, Customer>> updateCustomer(Customer customer);
  Future<Either<Failure, void>> deleteCustomer(String id);
  Future<Either<Failure, void>> recordCustomerTransaction(CustomerTransaction transaction);
  Future<Either<Failure, List<CustomerTransaction>>> getCustomerTransactions(String customerId);
  Future<Either<Failure, Map<String, double>>> getDebtAgingSummary();
  Future<Either<Failure, List<Customer>>> getCustomersWithOutstandingBalances();
}