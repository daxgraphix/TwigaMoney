import 'package:fpdart/fpdart.dart';
import '../../../../core/data/hive_database.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/account.dart';
import '../../domain/repositories/account_repository.dart';

class AccountRepositoryImpl implements AccountRepository {
  const AccountRepositoryImpl();

  @override
  Future<Either<Failure, List<Account>>> getAccounts() async {
    try {
      final box = HiveDatabase.accountBox;
      final accounts = box.values.toList();
      return Right(accounts);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get accounts: ${e.toString()}'));
    }
  }

   @override
   Future<Either<Failure, Account>> getAccountById(String id) async {
     try {
       final box = HiveDatabase.accountBox;
       final account = box.get(id);
       if (account == null) {
         return const Left(NotFoundFailure('Account not found'));
       }
       return Right(account);
     } catch (e) {
       return Left(DatabaseFailure('Failed to get account: ${e.toString()}'));
     }
   }

  @override
  Future<Either<Failure, Account>> addAccount(Account account) async {
    try {
      final box = HiveDatabase.accountBox;
      await box.put(account.id, account);
      return Right(account);
    } catch (e) {
      return Left(DatabaseFailure('Failed to add account: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Account>> updateAccount(Account account) async {
    try {
      final box = HiveDatabase.accountBox;
      await box.put(account.id, account);
      return Right(account);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update account: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount(String id) async {
    try {
      final box = HiveDatabase.accountBox;
      await box.delete(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete account: ${e.toString()}'));
    }
  }

   @override
   Future<Either<Failure, void>> updateAccountBalance(String id, double newBalance) async {
     try {
       final box = HiveDatabase.accountBox;
       final account = box.get(id);
       if (account == null) {
         return const Left(NotFoundFailure('Account not found'));
       }
      final updatedAccount = Account(
        id: account.id,
        name: account.name,
        type: account.type,
        balance: newBalance,
        currency: account.currency,
      );
      await box.put(id, updatedAccount);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update account balance: ${e.toString()}'));
    }
  }
}