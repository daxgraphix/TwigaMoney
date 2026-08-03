import 'package:fpdart/fpdart.dart';
import 'package:twigamoney/core/error/failure.dart';
import '../../domain/entities/account.dart';

abstract class AccountRepository {
  Future<Either<Failure, List<Account>>> getAccounts();
  Future<Either<Failure, Account>> getAccountById(String id);
  Future<Either<Failure, Account>> addAccount(Account account);
  Future<Either<Failure, Account>> updateAccount(Account account);
  Future<Either<Failure, void>> deleteAccount(String id);
  Future<Either<Failure, void>> updateAccountBalance(String id, double newBalance);
}