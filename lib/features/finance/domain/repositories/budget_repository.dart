import 'package:fpdart/fpdart.dart';
import 'package:twigamoney/core/error/failure.dart';
import '../../domain/entities/budget.dart';

abstract class BudgetRepository {
  Future<Either<Failure, List<Budget>>> getBudgets();
  Future<Either<Failure, Budget>> getBudgetById(String id);
  Future<Either<Failure, Budget>> addBudget(Budget budget);
  Future<Either<Failure, Budget>> updateBudget(Budget budget);
  Future<Either<Failure, void>> deleteBudget(String id);
  Future<Either<Failure, void>> updateBudgetSpent(String id, double spent);
}