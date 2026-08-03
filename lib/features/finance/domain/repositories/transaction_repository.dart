import 'package:fpdart/fpdart.dart';
import 'package:twigamoney/core/error/failure.dart';
import '../../domain/entities/transaction.dart';

abstract class TransactionRepository {
  Future<Either<Failure, List<Transaction>>> getTransactions();
  Future<Either<Failure, Transaction>> getTransactionById(String id);
  Future<Either<Failure, Transaction>> addTransaction(Transaction transaction);
  Future<Either<Failure, Transaction>> updateTransaction(Transaction transaction);
  Future<Either<Failure, void>> deleteTransaction(String id);
  Future<Either<Failure, List<Transaction>>> getTransactionsByDateRange(
      DateTime start, DateTime end);
  Future<Either<Failure, List<Transaction>>> getTransactionsByCategory(String categoryId);
  Future<Either<Failure, List<Transaction>>> getTransactionsByAccount(String accountId);
}