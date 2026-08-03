import 'package:fpdart/fpdart.dart';
import 'package:twigamoney/core/error/failure.dart';
import 'package:twigamoney/core/usecase/usecase.dart';
import '../entities/transaction.dart';
import '../entities/category.dart';
import '../entities/account.dart';
import '../entities/budget.dart';
import '../entities/recurring_transaction.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/account_repository.dart';
import '../repositories/budget_repository.dart';
import '../repositories/recurring_transaction_repository.dart';

// Transaction Use Cases
class GetTransactionsUseCase implements UseCase<List<Transaction>, NoParams> {
  final TransactionRepository repository;
  GetTransactionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Transaction>>> call(NoParams params) {
    return repository.getTransactions();
  }
}

class AddTransactionUseCase implements UseCase<Transaction, Transaction> {
  final TransactionRepository repository;
  AddTransactionUseCase(this.repository);

  @override
  Future<Either<Failure, Transaction>> call(Transaction transaction) {
    return repository.addTransaction(transaction);
  }
}

class UpdateTransactionUseCase implements UseCase<Transaction, Transaction> {
  final TransactionRepository repository;
  UpdateTransactionUseCase(this.repository);

  @override
  Future<Either<Failure, Transaction>> call(Transaction transaction) {
    return repository.updateTransaction(transaction);
  }
}

class DeleteTransactionUseCase implements UseCase<void, String> {
  final TransactionRepository repository;
  DeleteTransactionUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String id) {
    return repository.deleteTransaction(id);
  }
}

class GetTransactionsByDateRangeUseCase implements UseCase<List<Transaction>, DateRangeParams> {
  final TransactionRepository repository;
  GetTransactionsByDateRangeUseCase(this.repository);

  @override
  Future<Either<Failure, List<Transaction>>> call(DateRangeParams params) {
    return repository.getTransactionsByDateRange(params.start, params.end);
  }
}

class GetTransactionsByCategoryUseCase implements UseCase<List<Transaction>, String> {
  final TransactionRepository repository;
  GetTransactionsByCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<Transaction>>> call(String categoryId) {
    return repository.getTransactionsByCategory(categoryId);
  }
}

class GetTransactionsByAccountUseCase implements UseCase<List<Transaction>, String> {
  final TransactionRepository repository;
  GetTransactionsByAccountUseCase(this.repository);

  @override
  Future<Either<Failure, List<Transaction>>> call(String accountId) {
    return repository.getTransactionsByAccount(accountId);
  }
}

// Category Use Cases
class GetCategoriesUseCase implements UseCase<List<Category>, NoParams> {
  final CategoryRepository repository;
  GetCategoriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Category>>> call(NoParams params) {
    return repository.getCategories();
  }
}

class AddCategoryUseCase implements UseCase<Category, Category> {
  final CategoryRepository repository;
  AddCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, Category>> call(Category category) {
    return repository.addCategory(category);
  }
}

class UpdateCategoryUseCase implements UseCase<Category, Category> {
  final CategoryRepository repository;
  UpdateCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, Category>> call(Category category) {
    return repository.updateCategory(category);
  }
}

class DeleteCategoryUseCase implements UseCase<void, String> {
  final CategoryRepository repository;
  DeleteCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String id) {
    return repository.deleteCategory(id);
  }
}

// Account Use Cases
class GetAccountsUseCase implements UseCase<List<Account>, NoParams> {
  final AccountRepository repository;
  GetAccountsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Account>>> call(NoParams params) {
    return repository.getAccounts();
  }
}

class AddAccountUseCase implements UseCase<Account, Account> {
  final AccountRepository repository;
  AddAccountUseCase(this.repository);

  @override
  Future<Either<Failure, Account>> call(Account account) {
    return repository.addAccount(account);
  }
}

class UpdateAccountUseCase implements UseCase<Account, Account> {
  final AccountRepository repository;
  UpdateAccountUseCase(this.repository);

  @override
  Future<Either<Failure, Account>> call(Account account) {
    return repository.updateAccount(account);
  }
}

class DeleteAccountUseCase implements UseCase<void, String> {
  final AccountRepository repository;
  DeleteAccountUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String id) {
    return repository.deleteAccount(id);
  }
}

class UpdateAccountBalanceUseCase implements UseCase<void, UpdateBalanceParams> {
  final AccountRepository repository;
  UpdateAccountBalanceUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateBalanceParams params) {
    return repository.updateAccountBalance(params.id, params.newBalance);
  }
}

// Budget Use Cases
class GetBudgetsUseCase implements UseCase<List<Budget>, NoParams> {
  final BudgetRepository repository;
  GetBudgetsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Budget>>> call(NoParams params) {
    return repository.getBudgets();
  }
}

class AddBudgetUseCase implements UseCase<Budget, Budget> {
  final BudgetRepository repository;
  AddBudgetUseCase(this.repository);

  @override
  Future<Either<Failure, Budget>> call(Budget budget) {
    return repository.addBudget(budget);
  }
}

class UpdateBudgetUseCase implements UseCase<Budget, Budget> {
  final BudgetRepository repository;
  UpdateBudgetUseCase(this.repository);

  @override
  Future<Either<Failure, Budget>> call(Budget budget) {
    return repository.updateBudget(budget);
  }
}

class DeleteBudgetUseCase implements UseCase<void, String> {
  final BudgetRepository repository;
  DeleteBudgetUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String id) {
    return repository.deleteBudget(id);
  }
}

class UpdateBudgetSpentUseCase implements UseCase<void, UpdateSpentParams> {
  final BudgetRepository repository;
  UpdateBudgetSpentUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateSpentParams params) {
    return repository.updateBudgetSpent(params.id, params.spent);
  }
}

// Recurring Transaction Use Cases
class GetRecurringTransactionsUseCase implements UseCase<List<RecurringTransaction>, NoParams> {
  final RecurringTransactionRepository repository;
  GetRecurringTransactionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<RecurringTransaction>>> call(NoParams params) {
    return repository.getRecurringTransactions();
  }
}

class AddRecurringTransactionUseCase implements UseCase<RecurringTransaction, RecurringTransaction> {
  final RecurringTransactionRepository repository;
  AddRecurringTransactionUseCase(this.repository);

  @override
  Future<Either<Failure, RecurringTransaction>> call(RecurringTransaction transaction) {
    return repository.addRecurringTransaction(transaction);
  }
}

class UpdateRecurringTransactionUseCase implements UseCase<RecurringTransaction, RecurringTransaction> {
  final RecurringTransactionRepository repository;
  UpdateRecurringTransactionUseCase(this.repository);

  @override
  Future<Either<Failure, RecurringTransaction>> call(RecurringTransaction transaction) {
    return repository.updateRecurringTransaction(transaction);
  }
}

class DeleteRecurringTransactionUseCase implements UseCase<void, String> {
  final RecurringTransactionRepository repository;
  DeleteRecurringTransactionUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String id) {
    return repository.deleteRecurringTransaction(id);
  }
}

// Parameter classes
class DateRangeParams {
  final DateTime start;
  final DateTime end;
  DateRangeParams({required this.start, required this.end});
}

class UpdateBalanceParams {
  final String id;
  final double newBalance;
  UpdateBalanceParams({required this.id, required this.newBalance});
}

class UpdateSpentParams {
  final String id;
  final double spent;
  UpdateSpentParams({required this.id, required this.spent});
}