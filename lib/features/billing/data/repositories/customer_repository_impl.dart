import 'package:fpdart/fpdart.dart';
import 'package:twigamoney/core/data/hive_database.dart';
import 'package:twigamoney/core/error/failure.dart';
import 'package:twigamoney/features/billing/domain/entities/customer.dart';
import 'package:twigamoney/features/billing/domain/entities/customer_transaction.dart';
import 'package:twigamoney/features/billing/domain/repositories/customer_repository.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  const CustomerRepositoryImpl();

  @override
  Future<Either<Failure, List<Customer>>> getCustomers() async {
    try {
      final box = HiveDatabase.customerBox;
      final customers = box.values.toList();
      return Right(customers);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get customers: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Customer?>> getCustomerById(String id) async {
    try {
      final box = HiveDatabase.customerBox;
      final customer = box.get(id);
      return Right(customer);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get customer: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Customer>> addCustomer(Customer customer) async {
    try {
      final box = HiveDatabase.customerBox;
      await box.put(customer.id, customer);
      return Right(customer);
    } catch (e) {
      return Left(DatabaseFailure('Failed to add customer: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Customer>> updateCustomer(Customer customer) async {
    try {
      final box = HiveDatabase.customerBox;
      await box.put(customer.id, customer);
      return Right(customer);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update customer: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCustomer(String id) async {
    try {
      final box = HiveDatabase.customerBox;
      await box.delete(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete customer: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> recordCustomerTransaction(CustomerTransaction transaction) async {
    try {
      final customerBox = HiveDatabase.customerBox;
      final transactionBox = HiveDatabase.customerTransactionBox;

      // Record the transaction
      await transactionBox.put(transaction.id, transaction);

      // Update customer's balance and last transaction
      final customer = customerBox.get(transaction.customerId);
      if (customer != null) {
        final updatedCustomer = customer.copyWith(
          currentBalance: transaction.newBalance,
          lastTransaction: transaction.timestamp,
        );
        await customerBox.put(customer.id, updatedCustomer);
      }

      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to record customer transaction: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<CustomerTransaction>>> getCustomerTransactions(String customerId) async {
    try {
      final box = HiveDatabase.customerTransactionBox;
      final transactions = box.values
          .where((t) => t.customerId == customerId)
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Most recent first
      return Right(transactions);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get customer transactions: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, double>>> getDebtAgingSummary() async {
    try {
      final customerBox = HiveDatabase.customerBox;
      final transactionBox = HiveDatabase.customerTransactionBox;

      final now = DateTime.now();
      double current = 0.0; // 0-30 days
      double thirtyDays = 0.0; // 31-60 days
      double sixtyDays = 0.0; // 61-90 days
      double ninetyDaysPlus = 0.0; // 90+ days

      for (final customer in customerBox.values) {
        if (customer.currentBalance > 0) {
          // Get the date of the last payment or credit transaction
          final transactions = transactionBox.values
              .where((t) => t.customerId == customer.id)
              .toList()
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

          DateTime? lastActivityDate;
          if (transactions.isNotEmpty) {
            lastActivityDate = transactions.first.timestamp;
          } else {
            lastActivityDate = customer.createdAt;
          }

          final daysDiff = now.difference(lastActivityDate).inDays;

          if (daysDiff <= 30) {
            current += customer.currentBalance;
          } else if (daysDiff <= 60) {
            thirtyDays += customer.currentBalance;
          } else if (daysDiff <= 90) {
            sixtyDays += customer.currentBalance;
          } else {
            ninetyDaysPlus += customer.currentBalance;
          }
        }
      }

      return Right({
        'current': current,
        'thirtyDays': thirtyDays,
        'sixtyDays': sixtyDays,
        'ninetyDaysPlus': ninetyDaysPlus,
        'total': current + thirtyDays + sixtyDays + ninetyDaysPlus,
      });
    } catch (e) {
      return Left(DatabaseFailure('Failed to get debt aging summary: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Customer>>> getCustomersWithOutstandingBalances() async {
    try {
      final box = HiveDatabase.customerBox;
      final customersWithBalances = box.values
          .where((customer) => customer.hasOutstandingBalance)
          .toList()
        ..sort((a, b) => b.currentBalance.compareTo(a.currentBalance)); // Highest balance first
      return Right(customersWithBalances);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get customers with outstanding balances: ${e.toString()}'));
    }
  }
}