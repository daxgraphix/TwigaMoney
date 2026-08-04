import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';

// Events
// ... (events remain same)
abstract class TransactionEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadTransactionsEvent extends TransactionEvent {}

class AddTransactionEvent extends TransactionEvent {
  final Transaction transaction;
  AddTransactionEvent(this.transaction);
  @override
  List<Object?> get props => [transaction];
}

class UpdateTransactionEvent extends TransactionEvent {
  final Transaction transaction;
  UpdateTransactionEvent(this.transaction);
  @override
  List<Object?> get props => [transaction];
}

class DeleteTransactionEvent extends TransactionEvent {
  final String id;
  DeleteTransactionEvent(this.id);
  @override
  List<Object?> get props => [id];
}

// State
abstract class TransactionState extends Equatable {
  final List<Transaction> transactions;
  final bool isLoading;
  final String? error;

  const TransactionState({
    this.transactions = const [],
    this.isLoading = false,
    this.error,
  });

  @override
  List<Object?> get props => [transactions, isLoading, error];
}

class TransactionInitial extends TransactionState {
  const TransactionInitial() : super();
}

class TransactionLoading extends TransactionState {
  const TransactionLoading({List<Transaction> transactions = const []})
      : super(transactions: transactions, isLoading: true);
}

class TransactionLoaded extends TransactionState {
  const TransactionLoaded(List<Transaction> transactions)
      : super(transactions: transactions, isLoading: false);
}

class TransactionError extends TransactionState {
  const TransactionError(String message, {List<Transaction> transactions = const []})
      : super(transactions: transactions, isLoading: false, error: message);
}

// Bloc
class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository repository;

  TransactionBloc({required this.repository}) : super(const TransactionInitial()) {
    on<LoadTransactionsEvent>(_onLoadTransactions);
    on<AddTransactionEvent>(_onAddTransaction);
    on<UpdateTransactionEvent>(_onUpdateTransaction);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
  }

  Future<void> _onLoadTransactions(
    LoadTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading(transactions: state.transactions));
    
    final result = await TaskEither.tryCatch(
      () => repository.getTransactions(),
      (error, stackTrace) => error is Failure ? error : DatabaseFailure('Failed to load transactions: $error'),
    ).flatMap((either) => TaskEither.fromEither(either)).run();

    result.fold(
      (failure) => emit(TransactionError(failure.message, transactions: state.transactions)),
      (transactions) => emit(TransactionLoaded(transactions)),
    );
  }

  Future<void> _onAddTransaction(
    AddTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    final result = await TaskEither.tryCatch(
      () => repository.addTransaction(event.transaction),
      (error, stackTrace) => error is Failure ? error : DatabaseFailure('Failed to add transaction: $error'),
    ).flatMap((either) => TaskEither.fromEither(either)).run();

    result.fold(
      (failure) => emit(TransactionError(failure.message, transactions: state.transactions)),
      (newTransaction) {
        final updated = [...state.transactions, newTransaction];
        emit(TransactionLoaded(updated));
      },
    );
  }

  Future<void> _onUpdateTransaction(
    UpdateTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    final result = await TaskEither.tryCatch(
      () => repository.updateTransaction(event.transaction),
      (error, stackTrace) => error is Failure ? error : DatabaseFailure('Failed to update transaction: $error'),
    ).flatMap((either) => TaskEither.fromEither(either)).run();

    result.fold(
      (failure) => emit(TransactionError(failure.message, transactions: state.transactions)),
      (_) {
        final updated = state.transactions
            .map((t) => t.id == event.transaction.id ? event.transaction : t)
            .toList();
        emit(TransactionLoaded(updated));
      },
    );
  }

  Future<void> _onDeleteTransaction(
    DeleteTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    final result = await TaskEither.tryCatch(
      () => repository.deleteTransaction(event.id),
      (error, stackTrace) => error is Failure ? error : DatabaseFailure('Failed to delete transaction: $error'),
    ).flatMap((either) => TaskEither.fromEither(either)).run();

    result.fold(
      (failure) => emit(TransactionError(failure.message, transactions: state.transactions)),
      (_) {
        final updated = state.transactions.where((t) => t.id != event.id).toList();
        emit(TransactionLoaded(updated));
      },
    );
  }
}
