import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/finance_usecases.dart';
import '../../domain/usecases/monthly_report_usecase.dart';

import '../../domain/entities/category.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/budget.dart';
import '../../domain/entities/recurring_transaction.dart';

// Events
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
    final result = await getCategoriesUseCase(NoParams());
    result.fold(
      (failure) => emit(FinanceError(failure.message)),
      (categories) => emit(CategoriesLoaded(categories)),
    );
  }

  void _onAddCategory(AddCategoryEvent event, Emitter<FinanceState> emit) async {
    emit(FinanceLoading());
    final result = await addCategoryUseCase(event.category);
    result.fold(
      (failure) => emit(FinanceError(failure.message)),
      (_) => add(LoadCategoriesEvent()),
    );
  }

  void _onUpdateCategory(UpdateCategoryEvent event, Emitter<FinanceState> emit) async {
    emit(FinanceLoading());
    final result = await updateCategoryUseCase(event.category);
    result.fold(
      (failure) => emit(FinanceError(failure.message)),
      (_) => add(LoadCategoriesEvent()),
    );
  }

  void _onDeleteCategory(DeleteCategoryEvent event, Emitter<FinanceState> emit) async {
    emit(FinanceLoading());
    final result = await deleteCategoryUseCase(event.id);
    result.fold(
      (failure) => emit(FinanceError(failure.message)),
      (_) => add(LoadCategoriesEvent()),
    );
  }

  void _onLoadAccounts(LoadAccountsEvent event, Emitter<FinanceState> emit) async {
    emit(FinanceLoading());
    final result = await getAccountsUseCase(NoParams());
    result.fold(
      (failure) => emit(FinanceError(failure.message)),
      (accounts) => emit(AccountsLoaded(accounts)),
    );
  }

  void _onAddAccount(AddAccountEvent event, Emitter<FinanceState> emit) async {
    emit(FinanceLoading());
    final result = await addAccountUseCase(event.account);
    result.fold(
      (failure) => emit(FinanceError(failure.message)),
      (_) => add(LoadAccountsEvent()),
    );
  }

  void _onUpdateAccount(UpdateAccountEvent event, Emitter<FinanceState> emit) async {
    emit(FinanceLoading());
    final result = await updateAccountUseCase(event.account);
    result.fold(
      (failure) => emit(FinanceError(failure.message)),
      (_) => add(LoadAccountsEvent()),
    );
  }

  void _onDeleteAccount(DeleteAccountEvent event, Emitter<FinanceState> emit) async {
    emit(FinanceLoading());
    final result = await deleteAccountUseCase(event.id);
    result.fold(
      (failure) => emit(FinanceError(failure.message)),
      (_) => add(LoadAccountsEvent()),
    );
  }

  void _onLoadBudgets(LoadBudgetsEvent event, Emitter<FinanceState> emit) async {
    emit(FinanceLoading());
    final result = await getBudgetsUseCase(NoParams());
    result.fold(
      (failure) => emit(FinanceError(failure.message)),
      (budgets) => emit(BudgetsLoaded(budgets)),
    );
  }

  void _onAddBudget(AddBudgetEvent event, Emitter<FinanceState> emit) async {
    emit(FinanceLoading());
    final result = await addBudgetUseCase(event.budget);
    result.fold(
      (failure) => emit(FinanceError(failure.message)),
      (_) => add(LoadBudgetsEvent()),
    );
  }

  void _onUpdateBudget(UpdateBudgetEvent event, Emitter<FinanceState> emit) async {
    emit(FinanceLoading());
    final result = await updateBudgetUseCase(event.budget);
    result.fold(
      (failure) => emit(FinanceError(failure.message)),
      (_) => add(LoadBudgetsEvent()),
    );
  }

  void _onDeleteBudget(DeleteBudgetEvent event, Emitter<FinanceState> emit) async {
    emit(FinanceLoading());
    final result = await deleteBudgetUseCase(event.id);
    result.fold(
      (failure) => emit(FinanceError(failure.message)),
      (_) => add(LoadBudgetsEvent()),
    );
  }

  void _onLoadRecurringTransactions(LoadRecurringTransactionsEvent event, Emitter<FinanceState> emit) async {
    emit(FinanceLoading());
    final result = await getRecurringTransactionsUseCase(NoParams());
    result.fold(
      (failure) => emit(FinanceError(failure.message)),
      (transactions) => emit(RecurringTransactionsLoaded(transactions)),
    );
  }

  void _onAddRecurringTransaction(AddRecurringTransactionEvent event, Emitter<FinanceState> emit) async {
    emit(FinanceLoading());
    final result = await addRecurringTransactionUseCase(event.transaction);
    result.fold(
      (failure) => emit(FinanceError(failure.message)),
      (_) => add(LoadRecurringTransactionsEvent()),
    );
  }

  void _onUpdateRecurringTransaction(UpdateRecurringTransactionEvent event, Emitter<FinanceState> emit) async {
    emit(FinanceLoading());
    final result = await updateRecurringTransactionUseCase(event.transaction);
    result.fold(
      (failure) => emit(FinanceError(failure.message)),
      (_) => add(LoadRecurringTransactionsEvent()),
    );
  }

  void _onDeleteRecurringTransaction(DeleteRecurringTransactionEvent event, Emitter<FinanceState> emit) async {
    emit(FinanceLoading());
    final result = await deleteRecurringTransactionUseCase(event.id);
    result.fold(
      (failure) => emit(FinanceError(failure.message)),
      (_) => add(LoadRecurringTransactionsEvent()),
    );
  }

  void _onLoadMonthlyReport(LoadMonthlyReportEvent event, Emitter<FinanceState> emit) async {
    emit(FinanceLoading());
    final result = await getMonthlyReportUseCase(event.month);
    result.fold(
      (failure) => emit(FinanceError(failure.message)),
      (report) => emit(MonthlyReportLoaded(report)),
    );
  }
}