import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';

// Events
abstract class BudgetEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadBudgetsEvent extends BudgetEvent {}

class AddBudgetEvent extends BudgetEvent {
  final Budget budget;
  AddBudgetEvent(this.budget);
  @override
  List<Object?> get props => [budget];
}

class UpdateBudgetEvent extends BudgetEvent {
  final Budget budget;
  UpdateBudgetEvent(this.budget);
  @override
  List<Object?> get props => [budget];
}

class DeleteBudgetEvent extends BudgetEvent {
  final String id;
  DeleteBudgetEvent(this.id);
  @override
  List<Object?> get props => [id];
}

// State
abstract class BudgetState extends Equatable {
  final List<Budget> budgets;
  final bool isLoading;
  final String? error;

  const BudgetState({
    this.budgets = const [],
    this.isLoading = false,
    this.error,
  });

  @override
  List<Object?> get props => [budgets, isLoading, error];
}

class BudgetInitial extends BudgetState {
  const BudgetInitial();
}

class BudgetLoading extends BudgetState {
  const BudgetLoading({List<Budget> budgets = const []})
      : super(budgets: budgets, isLoading: true);
}

class BudgetLoaded extends BudgetState {
  const BudgetLoaded(List<Budget> budgets)
      : super(budgets: budgets, isLoading: false);
}

class BudgetError extends BudgetState {
  const BudgetError(String message, {List<Budget> budgets = const []})
      : super(budgets: budgets, isLoading: false, error: message);
}

// Cubit
class BudgetCubit extends Cubit<BudgetState> {
  final BudgetRepository repository;

  BudgetCubit({required this.repository}) : super(const BudgetInitial());

  Future<void> loadBudgets() async {
    emit(BudgetLoading(budgets: state.budgets));
    final result = await repository.getBudgets();
    result.fold(
      (failure) => emit(BudgetError(failure.message, budgets: state.budgets)),
      (budgets) => emit(BudgetLoaded(budgets)),
    );
  }

  Future<void> addBudget(Budget budget) async {
    final result = await repository.addBudget(budget);
    result.fold(
      (failure) => emit(BudgetError(failure.message, budgets: state.budgets)),
      (newBudget) {
        final updated = [...state.budgets, newBudget];
        emit(BudgetLoaded(updated));
      },
    );
  }

  Future<void> updateBudget(Budget budget) async {
    final result = await repository.updateBudget(budget);
    result.fold(
      (failure) => emit(BudgetError(failure.message, budgets: state.budgets)),
      (_) {
        final updated = state.budgets
            .map((b) => b.id == budget.id ? budget : b)
            .toList();
        emit(BudgetLoaded(updated));
      },
    );
  }

  Future<void> deleteBudget(String id) async {
    final result = await repository.deleteBudget(id);
    result.fold(
      (failure) => emit(BudgetError(failure.message, budgets: state.budgets)),
      (_) {
        final updated = state.budgets.where((b) => b.id != id).toList();
        emit(BudgetLoaded(updated));
      },
    );
  }
}
