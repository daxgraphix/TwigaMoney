import 'package:fpdart/fpdart.dart';
import '../../../../core/data/hive_database.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  const BudgetRepositoryImpl();

  @override
  Future<Either<Failure, List<Budget>>> getBudgets() async {
    try {
      final box = HiveDatabase.budgetBox;
      final budgets = box.values.toList();
      return Right(budgets);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get budgets: ${e.toString()}'));
    }
  }

   @override
   Future<Either<Failure, Budget>> getBudgetById(String id) async {
     try {
       final box = HiveDatabase.budgetBox;
       final budget = box.get(id);
       if (budget == null) {
         return const Left(NotFoundFailure('Budget not found'));
       }
       return Right(budget);
     } catch (e) {
       return Left(DatabaseFailure('Failed to get budget: ${e.toString()}'));
     }
   }

  @override
  Future<Either<Failure, Budget>> addBudget(Budget budget) async {
    try {
      final box = HiveDatabase.budgetBox;
      await box.put(budget.id, budget);
      return Right(budget);
    } catch (e) {
      return Left(DatabaseFailure('Failed to add budget: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Budget>> updateBudget(Budget budget) async {
    try {
      final box = HiveDatabase.budgetBox;
      await box.put(budget.id, budget);
      return Right(budget);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update budget: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBudget(String id) async {
    try {
      final box = HiveDatabase.budgetBox;
      await box.delete(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete budget: ${e.toString()}'));
    }
  }

   @override
   Future<Either<Failure, void>> updateBudgetSpent(String id, double spent) async {
     try {
       final box = HiveDatabase.budgetBox;
       final budget = box.get(id);
       if (budget == null) {
         return const Left(NotFoundFailure('Budget not found'));
       }
      final updatedBudget = Budget(
        id: budget.id,
        name: budget.name,
        amount: budget.amount,
        categoryId: budget.categoryId,
        period: budget.period,
        startDate: budget.startDate,
        endDate: budget.endDate,
        spent: spent,
        limitAlertThreshold: budget.limitAlertThreshold,
      );
      await box.put(id, updatedBudget);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update budget spent: ${e.toString()}'));
    }
  }
}