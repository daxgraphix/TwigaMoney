import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/error/failure.dart';
import '../../domain/usecases/finance_usecases.dart';
import '../../domain/usecases/monthly_report_usecase.dart';

import '../../domain/entities/category.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/budget.dart';
import '../../domain/entities/recurring_transaction.dart';

// Events
// ... (rest of events and states)
abstract class FinanceEvent extends Equatable {
  @override
  List<Object?> get props => [];
}



class LoadCategoriesEvent extends FinanceEvent {}

class AddCategoryEvent extends FinanceEvent {
  final Category category;
  AddCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

class UpdateCategoryEvent extends FinanceEvent {
  final Category category;
  UpdateCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

class DeleteCategoryEvent extends FinanceEvent {
  final String id;
  DeleteCategoryEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class LoadAccountsEvent extends FinanceEvent {}

class AddAccountEvent extends FinanceEvent {
  final Account account;
  AddAccountEvent(this.account);

  @override
  List<Object?> get props => [account];
}

class UpdateAccountEvent extends FinanceEvent {
  final Account account;
  UpdateAccountEvent(this.account);

  @override
  List<Object?> get props => [account];
}

class DeleteAccountEvent extends FinanceEvent {
  final String id;
  DeleteAccountEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class LoadBudgetsEvent extends FinanceEvent {}

class AddBudgetEvent extends FinanceEvent {
  final Budget budget;
  AddBudgetEvent(this.budget);

  @override
  List<Object?> get props => [budget];
}

class UpdateBudgetEvent extends FinanceEvent {
  final Budget budget;
  UpdateBudgetEvent(this.budget);

  @override
  List<Object?> get props => [budget];
}

class DeleteBudgetEvent extends FinanceEvent {
  final String id;
  DeleteBudgetEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class LoadRecurringTransactionsEvent extends FinanceEvent {}

class AddRecurringTransactionEvent extends FinanceEvent {
  final RecurringTransaction transaction;
  AddRecurringTransactionEvent(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class UpdateRecurringTransactionEvent extends FinanceEvent {
  final RecurringTransaction transaction;
  UpdateRecurringTransactionEvent(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class DeleteRecurringTransactionEvent extends FinanceEvent {
  final String id;
  DeleteRecurringTransactionEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class LoadMonthlyReportEvent extends FinanceEvent {
  final DateTime month;
  LoadMonthlyReportEvent(this.month);

  @override
  List<Object?> get props => [month];
}

// States
abstract class FinanceState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FinanceInitial extends FinanceState {}

class FinanceLoading extends FinanceState {}

// TransactionsLoaded has been moved to TransactionBloc

class CategoriesLoaded extends FinanceState {
  final List<Category> categories;
  CategoriesLoaded(this.categories);

  @override
  List<Object?> get props => [categories];
}

class AccountsLoaded extends FinanceState {
  final List<Account> accounts;
  AccountsLoaded(this.accounts);

  @override
  List<Object?> get props => [accounts];
}

class BudgetsLoaded extends FinanceState {
  final List<Budget> budgets;
  BudgetsLoaded(this.budgets);

  @override
  List<Object?> get props => [budgets];
}

class RecurringTransactionsLoaded extends FinanceState {
  final List<RecurringTransaction> transactions;
  RecurringTransactionsLoaded(this.transactions);

  @override
  List<Object?> get props => [transactions];
}

class MonthlyReportLoaded extends FinanceState {
  final MonthlyReport report;
  MonthlyReportLoaded(this.report);

  @override
  List<Object?> get props => [report];
}

class FinanceError extends FinanceState {
  final String message;
  FinanceError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class FinanceBloc extends Bloc<FinanceEvent, FinanceState> {
  // Transaction use cases moved to TransactionBloc
  // final GetTransactionsUseCase getTransactionsUseCase;
  // final AddTransactionUseCase addTransactionUseCase;
  // ...

  final GetCategoriesUseCase getCategoriesUseCase;
  final AddCategoryUseCase addCategoryUseCase;
  final UpdateCategoryUseCase updateCategoryUseCase;
  final DeleteCategoryUseCase deleteCategoryUseCase;
  final GetAccountsUseCase getAccountsUseCase;
  final AddAccountUseCase addAccountUseCase;
  final UpdateAccountUseCase updateAccountUseCase;
  final DeleteAccountUseCase deleteAccountUseCase;
  final GetBudgetsUseCase getBudgetsUseCase;
  final AddBudgetUseCase addBudgetUseCase;
  final UpdateBudgetUseCase updateBudgetUseCase;
  final DeleteBudgetUseCase deleteBudgetUseCase;
  final GetRecurringTransactionsUseCase getRecurringTransactionsUseCase;
  final AddRecurringTransactionUseCase addRecurringTransactionUseCase;
  final UpdateRecurringTransactionUseCase updateRecurringTransactionUseCase;
  final DeleteRecurringTransactionUseCase deleteRecurringTransactionUseCase;
  final GetMonthlyReportUseCase getMonthlyReportUseCase;

  FinanceBloc({
    // Transaction use cases moved to TransactionBloc
    // required this.getTransactionsUseCase,
    // required this.addTransactionUseCase,
    // ...

    required this.getCategoriesUseCase,
    required this.addCategoryUseCase,
    required this.updateCategoryUseCase,
    required this.deleteCategoryUseCase,
    required this.getAccountsUseCase,
    required this.addAccountUseCase,
    required this.updateAccountUseCase,
    required this.deleteAccountUseCase,
    required this.getBudgetsUseCase,
    required this.addBudgetUseCase,
    required this.updateBudgetUseCase,
    required this.deleteBudgetUseCase,
    required this.getRecurringTransactionsUseCase,
    required this.addRecurringTransactionUseCase,
    required this.updateRecurringTransactionUseCase,
    required this.deleteRecurringTransactionUseCase,
    required this.getMonthlyReportUseCase,
  }) : super(FinanceInitial()) {
    // Transaction events moved to TransactionBloc
    // on<LoadTransactionsEvent>(_onLoadTransactions);
    // on<AddTransactionEvent>(_onAddTransaction);
    // ...

    on<LoadCategoriesEvent>(_onLoadCategories);
    on<AddCategoryEvent>(_onAddCategory);
    on<UpdateCategoryEvent>(_onUpdateCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
    on<LoadAccountsEvent>(_onLoadAccounts);
    on<AddAccountEvent>(_onAddAccount);
    on<UpdateAccountEvent>(_onUpdateAccount);
    on<DeleteAccountEvent>(_onDeleteAccount);
    on<LoadBudgetsEvent>(_onLoadBudgets);
    on<AddBudgetEvent>(_onAddBudget);
    on<UpdateBudgetEvent>(_onUpdateBudget);
    on<DeleteBudgetEvent>(_onDeleteBudget);
    on<LoadRecurringTransactionsEvent>(_onLoadRecurringTransactions);
    on<AddRecurringTransactionEvent>(_onAddRecurringTransaction);
    on<UpdateRecurringTransactionEvent>(_onUpdateRecurringTransaction);
    on<DeleteRecurringTransactionEvent>(_onDeleteRecurringTransaction);
    on<LoadMonthlyReportEvent>(_onLoadMonthlyReport);
  }

  // Transaction handlers moved to TransactionBloc

  void _onLoadCategories(LoadCategoriesEvent event, Emitter<FinanceState> emit) async {
    emit(FinanceLoading());
    final result = await TaskEither.tryCatch(
      () => getCategoriesUseCase(NoParams()),
      (error, stackTrace) => error is Failure ? error : DatabaseFailure('Failed to load categories: $error'),
    ).flatMap((either) => TaskEither.fromEither(either)).run();

    result.fold(
      (failure) => emit(FinanceError(failure.message)),
      (categories) => emit(CategoriesLoaded(categories)),
    );
  }

  void _onAddCategory(AddCategoryEvent event, Emitter<FinanceState> emit) async {
    emit(FinanceLoading());
    final result = await TaskEither.tryCatch(
      () => addCategoryUseCase(event.category),
      (error, stackTrace) => error is Failure ? error : DatabaseFailure('Failed to add category: $error'),
    ).flatMap((either) => TaskEither.fromEither(either)).run();

    result.fold(
      (failure) => emit(FinanceError(failure.message)),
      (_) => add(LoadCategoriesEvent()),
    );
  }

  void _onUpdateCategory(UpdateCategoryEvent event, Emitter<FinanceState> emit) async {
    emit(FinanceLoading());
    final result = await TaskEither.tryCatch(
      () => updateCategoryUseCase(event.category),
      (error, stackTrace) => error is Failure ? error : DatabaseFailure('Failed to update category: $error'),
    ).flatMap((either) => TaskEither.fromEither(either)).run();

    result.fold(
      (failure) => emit(FinanceError(failure.message)),
      (_) => add(LoadCategoriesEvent()),
    );
  }

  void _onDeleteCategory(DeleteCategoryEvent event, Emitter<FinanceState> emit) async {
    emit(FinanceLoading());
    final result = await TaskEither.tryCatch(
      () => deleteCategoryUseCase(event.id),
      (error, stackTrace) => error is Failure ? error : DatabaseFailure('Failed to delete category: $error'),
    ).flatMap((either) => TaskEither.fromEither(either)).run();

    result.fold(
      (failure) => emit(FinanceError(failure.message)),
      (_) => add(LoadCategoriesEvent()),
    );
  }

  void _onLoadAccounts(LoadAccountsEvent event, Emitter<FinanceState> emit) async {
    emit(FinanceLoading());
    final result = await TaskEither.tryCatch(
      () => getAccountsUseCase(NoParams()),
      (error, stackTrace) => error is Failure ? error : DatabaseFailure('Failed to load accounts: $error'),
    ).flatMap((either) => TaskEither.fromEither(either)).run();

    result.fold(
      (failure) => emit(FinanceError(failure.message)),
      (accounts) => emit(AccountsLoaded(accounts)),
    );
  }

  void _onAddAccount(AddAccountEvent event, Emitter<FinanceState> emit) async {
    emit(FinanceLoading());
    final result = await TaskEither.tryCatch(
      () => addAccountUseCase(event.account),
      (error, stackTrace) => error is Failure ? error : DatabaseFailure('Failed to add account: $error'),
    ).flatMap((either) => TaskEither.fromEither(either)).run();

    result.fold(
      (failure) => emit(FinanceError(failure.message)),
      (_) => add(LoadAccountsEvent()),
    );
  }

  void _onUpdateAccount(UpdateAccountEvent event, Emitter<FinanceState> emit) async {
    emit(FinanceLoading());
    final result = await TaskEither.tryCatch(
      () => updateAccountUseCase(event.account),
      (error, stackTrace) => error is Failure ? error : DatabaseFailure('Failed to update account: $error'),
    ).flatMap((either) => TaskEither.fromEither(either)).run();

    result.fold(
      (failure) => emit(FinanceError(failure.message)),
      (_) => add(LoadAccountsEvent()),
    );
  }

  void _onDeleteAccount(DeleteAccountEvent event, Emitter<FinanceState> emit) async {
    emit(FinanceLoading());
    final result = await TaskEither.tryCatch(
      () => deleteAccountUseCase(event.id),
      (error, stackTrace) => error is Failure ? error : DatabaseFailure('Failed to delete account: $error'),
    ).flatMap((either) => TaskEither.fromEither(either)).run();

    result.fold(
      (failure) => emit(FinanceError(failure.message)),
      (_) => add(LoadAccountsEvent()),
    );
  }

  void _onLoadBudgets(LoadBudgetsEvent event, Emitter<FinanceState> emit) async {
    emit(FinanceLoading());
    final result = await TaskEither.tryCatch(
      () => getBudgetsUseCase(NoParams()),
      (error, stackTrace) => error is Failure ? error : DatabaseFailure('Failed to load budgets: $error'),
    ).flatMap((either) => TaskEither.fromEither(either)).run();

    result.fold(
      (failure) => emit(FinanceError(failure.message)),
      (budgets) => emit(BudgetsLoaded(budgets)),
    );
  }

  void _onAddBudget(AddBudgetEvent event, Emitter<FinanceState> emit) async {
    emit(FinanceLoading());
    final result = await TaskEither.tryCatch(
      () => addBudgetUseCase(event.budget),
      (error, stackTrace) => error is Failure ? error : DatabaseFailure('Failed to add budget: $error'),
    ).flatMap((either) => TaskEither.fromEither(either)).run();

    result.fold(
      (failure) => emit(FinanceError(failure.message)),
      (_) => add(LoadBudgetsEvent()),
    );
  }

  void _onUpdateBudget(UpdateBudgetEvent event, Emitter<FinanceState> emit) async {
    emit(FinanceLoading());
    final result = await TaskEither.tryCatch(
      () => updateBudgetUseCase(event.budget),
      (error, stackTrace) => error is Failure ? error : DatabaseFailure('Failed to update budget: $error'),
    ).flatMap((either) => TaskEither.fromEither(either)).run();

    result.fold(
      (failure) => emit(FinanceError(failure.message)),
      (_) => add(LoadBudgetsEvent()),
    );
  }

  void _onDeleteBudget(DeleteBudgetEvent event, Emitter<FinanceState> emit) async {
    emit(FinanceLoading());
    final result = await TaskEither.tryCatch(
      () => deleteBudgetUseCase(event.id),
      (error, stackTrace) => error is Failure ? error : DatabaseFailure('Failed to delete budget: $error'),
    ).flatMap((either) => TaskEither.fromEither(either)).run();

    result.fold(
      (failure) => emit(FinanceError(failure.message)),
      (_) => add(LoadBudgetsEvent()),
    );
  }

  void _onLoadRecurringTransactions(LoadRecurringTransactionsEvent event, Emitter<FinanceState> emit) async {
    emit(FinanceLoading());
    final result = await TaskEither.tryCatch(
      () => getRecurringTransactionsUseCase(NoParams()),
      (error, stackTrace) => error is Failure ? error : DatabaseFailure('Failed to load recurring transactions: $error'),
    ).flatMap((either) => TaskEither.fromEither(either)).run();

    result.fold(
      (failure) => emit(FinanceError(failure.message)),
      (transactions) => emit(RecurringTransactionsLoaded(transactions)),
    );
  }

  void _onAddRecurringTransaction(AddRecurringTransactionEvent event, Emitter<FinanceState> emit) async {
    emit(FinanceLoading());
    final result = await TaskEither.tryCatch(
      () => addRecurringTransactionUseCase(event.transaction),
      (error, stackTrace) => error is Failure ? error : DatabaseFailure('Failed to add recurring transaction: $error'),
    ).flatMap((either) => TaskEither.fromEither(either)).run();

    result.fold(
      (failure) => emit(FinanceError(failure.message)),
      (_) => add(LoadRecurringTransactionsEvent()),
    );
  }

  void _onUpdateRecurringTransaction(UpdateRecurringTransactionEvent event, Emitter<FinanceState> emit) async {
    emit(FinanceLoading());
    final result = await TaskEither.tryCatch(
      () => updateRecurringTransactionUseCase(event.transaction),
      (error, stackTrace) => error is Failure ? error : DatabaseFailure('Failed to update recurring transaction: $error'),
    ).flatMap((either) => TaskEither.fromEither(either)).run();

    result.fold(
      (failure) => emit(FinanceError(failure.message)),
      (_) => add(LoadRecurringTransactionsEvent()),
    );
  }

  void _onDeleteRecurringTransaction(DeleteRecurringTransactionEvent event, Emitter<FinanceState> emit) async {
    emit(FinanceLoading());
    final result = await TaskEither.tryCatch(
      () => deleteRecurringTransactionUseCase(event.id),
      (error, stackTrace) => error is Failure ? error : DatabaseFailure('Failed to delete recurring transaction: $error'),
    ).flatMap((either) => TaskEither.fromEither(either)).run();

    result.fold(
      (failure) => emit(FinanceError(failure.message)),
      (_) => add(LoadRecurringTransactionsEvent()),
    );
  }

  void _onLoadMonthlyReport(LoadMonthlyReportEvent event, Emitter<FinanceState> emit) async {
    emit(FinanceLoading());
    final result = await TaskEither.tryCatch(
      () => getMonthlyReportUseCase(event.month),
      (error, stackTrace) => error is Failure ? error : DatabaseFailure('Failed to load monthly report: $error'),
    ).flatMap((either) => TaskEither.fromEither(either)).run();

    result.fold(
      (failure) => emit(FinanceError(failure.message)),
      (report) => emit(MonthlyReportLoaded(report)),
    );
  }
}
