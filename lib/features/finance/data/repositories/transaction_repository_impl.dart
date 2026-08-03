import 'package:fpdart/fpdart.dart';
import '../../../../core/data/hive_database.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  const TransactionRepositoryImpl();

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions() async {
    try {
      final box = HiveDatabase.transactionBox;
      final transactions = box.values.toList();
      return Right(transactions);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get transactions: ${e.toString()}'));
    }
  }

   @override
   Future<Either<Failure, Transaction>> getTransactionById(String id) async {
     try {
       final box = HiveDatabase.transactionBox;
       final transaction = box.get(id);
       if (transaction == null) {
         return const Left(NotFoundFailure('Transaction not found'));
       }
       return Right(transaction);
     } catch (e) {
       return Left(DatabaseFailure('Failed to get transaction: ${e.toString()}'));
     }
   }

  @override
  Future<Either<Failure, Transaction>> addTransaction(Transaction transaction) async {
    try {
      final box = HiveDatabase.transactionBox;
      await box.put(transaction.id, transaction);
      return Right(transaction);
    } catch (e) {
      return Left(DatabaseFailure('Failed to add transaction: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Transaction>> updateTransaction(Transaction transaction) async {
    try {
      final box = HiveDatabase.transactionBox;
      await box.put(transaction.id, transaction);
      return Right(transaction);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update transaction: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(String id) async {
    try {
      final box = HiveDatabase.transactionBox;
      await box.delete(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete transaction: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getTransactionsByDateRange(
      DateTime start, DateTime end) async {
    try {
      final box = HiveDatabase.transactionBox;
      final transactions = box.values.where((t) =>
          t.date.isAfter(start.subtract(const Duration(days: 1))) &&
          t.date.isBefore(end.add(const Duration(days: 1)))).toList();
      return Right(transactions);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get transactions by date range: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getTransactionsByCategory(String categoryId) async {
    try {
      final box = HiveDatabase.transactionBox;
      final transactions = box.values.where((t) => t.categoryId == categoryId).toList();
      return Right(transactions);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get transactions by category: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getTransactionsByAccount(String accountId) async {
    try {
      final box = HiveDatabase.transactionBox;
      final transactions = box.values.where((t) => t.accountId == accountId).toList();
      return Right(transactions);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get transactions by account: ${e.toString()}'));
    }
  }
}