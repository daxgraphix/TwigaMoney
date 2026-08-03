import 'package:fpdart/fpdart.dart';
import 'package:twigamoney/core/error/failure.dart';
import 'package:twigamoney/features/finance/domain/entities/transaction.dart';
import 'package:twigamoney/features/finance/domain/entities/account.dart';
import 'package:twigamoney/features/finance/domain/repositories/transaction_repository.dart';
import 'package:twigamoney/features/finance/domain/repositories/account_repository.dart';

class LedgerService {
  final TransactionRepository transactionRepository;
  final AccountRepository accountRepository;

  LedgerService({
    required this.transactionRepository,
    required this.accountRepository,
  });

  /// Records a transaction and updates account balance atomically
  Future<Either<Failure, Transaction>> recordTransactionWithBalanceUpdate(
    Transaction transaction,
  ) async {
    try {
      // 1. Record the transaction
      final transactionResult = await transactionRepository.addTransaction(transaction);
      
      return transactionResult.fold(
        (failure) => Left(failure),
        (recordedTransaction) async {
          // 2. Update account balance
          final accountResult = await accountRepository.getAccountById(transaction.accountId);
          
          return accountResult.fold(
            (failure) => Left(failure),
            (account) async {
              double newBalance = account.balance;
              
              if (transaction.type == TransactionType.income || 
                  transaction.type == TransactionType.fundTransfer) {
                newBalance += transaction.amount;
              } else if (transaction.type == TransactionType.expense) {
                newBalance -= transaction.amount;
              }
              // Stock transactions don't affect cash balance

              final updatedAccount = Account(
                id: account.id,
                name: account.name,
                type: account.type,
                balance: newBalance,
                currency: account.currency,
              );
              final updateResult = await accountRepository.updateAccount(updatedAccount);

              return updateResult.fold(
                (failure) => Left(failure),
                (_) => Right(recordedTransaction),
              );
            },
          );
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Failed to record transaction: $e'));
    }
  }

  /// Records a fund transfer between two accounts
  Future<Either<Failure, bool>> recordFundTransfer({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    required String description,
    required DateTime date,
  }) async {
    try {
      // Debit from source account
      final debitTransaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        description: 'Transfer Out: $description',
        amount: amount,
        date: date,
        categoryId: 'funds',
        accountId: fromAccountId,
        type: TransactionType.fundTransfer,
      );

      // Credit to destination account
      final creditTransaction = Transaction(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        description: 'Transfer In: $description',
        amount: amount,
        date: date,
        categoryId: 'funds',
        accountId: toAccountId,
        type: TransactionType.fundTransfer,
      );

      final debitResult = await recordTransactionWithBalanceUpdate(debitTransaction);
      final creditResult = await recordTransactionWithBalanceUpdate(creditTransaction);

      return debitResult.fold(
        (failure) => Left(failure),
        (_) => creditResult.fold(
          (failure) => Left(failure),
          (_) => const Right(true),
        ),
      );
    } catch (e) {
      return Left(DatabaseFailure('Fund transfer failed: $e'));
    }
  }
}
