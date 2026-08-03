import 'package:fpdart/fpdart.dart';
import '../../../../core/data/hive_database.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/recurring_transaction.dart';
import '../../domain/repositories/recurring_transaction_repository.dart';

class RecurringTransactionRepositoryImpl implements RecurringTransactionRepository {
  const RecurringTransactionRepositoryImpl();

  @override
  Future<Either<Failure, List<RecurringTransaction>>> getRecurringTransactions() async {
    try {
      final box = HiveDatabase.recurringTransactionBox;
      final transactions = box.values.toList();
      return Right(transactions);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get recurring transactions: ${e.toString()}'));
    }
  }

   @override
   Future<Either<Failure, RecurringTransaction>> getRecurringTransactionById(String id) async {
     try {
       final box = HiveDatabase.recurringTransactionBox;
       final recurringTransaction = box.get(id);
       if (recurringTransaction == null) {
         return const Left(NotFoundFailure('Recurring transaction not found'));
       }
       return Right(recurringTransaction);
     } catch (e) {
       return Left(DatabaseFailure('Failed to get recurring transaction: ${e.toString()}'));
     }
   }

   @override
   Future<Either<Failure, RecurringTransaction>> addRecurringTransaction(RecurringTransaction transaction) async {
    try {
      final box = HiveDatabase.recurringTransactionBox;
      await box.put(transaction.id, transaction);
      return Right(transaction);
    } catch (e) {
      return Left(DatabaseFailure('Failed to add recurring transaction: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, RecurringTransaction>> updateRecurringTransaction(RecurringTransaction transaction) async {
    try {
      final box = HiveDatabase.recurringTransactionBox;
      await box.put(transaction.id, transaction);
      return Right(transaction);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update recurring transaction: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRecurringTransaction(String id) async {
    try {
      final box = HiveDatabase.recurringTransactionBox;
      await box.delete(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete recurring transaction: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<RecurringTransaction>>> getActiveRecurringTransactions() async {
    try {
      final box = HiveDatabase.recurringTransactionBox;
      final transactions = box.values.where((t) => t.isActive).toList();
      return Right(transactions);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get active recurring transactions: ${e.toString()}'));
    }
  }
}