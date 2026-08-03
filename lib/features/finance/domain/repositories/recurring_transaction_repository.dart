import 'package:fpdart/fpdart.dart';
import 'package:twigamoney/core/error/failure.dart';
import '../../domain/entities/recurring_transaction.dart';

abstract class RecurringTransactionRepository {
  Future<Either<Failure, List<RecurringTransaction>>> getRecurringTransactions();
  Future<Either<Failure, RecurringTransaction>> getRecurringTransactionById(String id);
  Future<Either<Failure, RecurringTransaction>> addRecurringTransaction(RecurringTransaction transaction);
  Future<Either<Failure, RecurringTransaction>> updateRecurringTransaction(RecurringTransaction transaction);
  Future<Either<Failure, void>> deleteRecurringTransaction(String id);
  Future<Either<Failure, List<RecurringTransaction>>> getActiveRecurringTransactions();
}