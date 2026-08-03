import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/account.dart';
import '../../domain/repositories/account_repository.dart';

// Events
abstract class AccountEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadAccountsEvent extends AccountEvent {}

class AddAccountEvent extends AccountEvent {
  final Account account;
  AddAccountEvent(this.account);
  @override
  List<Object?> get props => [account];
}

class UpdateAccountEvent extends AccountEvent {
  final Account account;
  UpdateAccountEvent(this.account);
  @override
  List<Object?> get props => [account];
}

class DeleteAccountEvent extends AccountEvent {
  final String id;
  DeleteAccountEvent(this.id);
  @override
  List<Object?> get props => [id];
}

// State
abstract class AccountState extends Equatable {
  final List<Account> accounts;
  final bool isLoading;
  final String? error;

  const AccountState({
    this.accounts = const [],
    this.isLoading = false,
    this.error,
  });

  @override
  List<Object?> get props => [accounts, isLoading, error];
}

class AccountInitial extends AccountState {
  const AccountInitial();
}

class AccountLoading extends AccountState {
  const AccountLoading({List<Account> accounts = const []})
      : super(accounts: accounts, isLoading: true);
}

class AccountLoaded extends AccountState {
  const AccountLoaded(List<Account> accounts)
      : super(accounts: accounts, isLoading: false);
}

class AccountError extends AccountState {
  const AccountError(String message, {List<Account> accounts = const []})
      : super(accounts: accounts, isLoading: false, error: message);
}

// Cubit
class AccountCubit extends Cubit<AccountState> {
  final AccountRepository repository;

  AccountCubit({required this.repository}) : super(const AccountInitial());

  Future<void> loadAccounts() async {
    emit(AccountLoading(accounts: state.accounts));
    final result = await repository.getAccounts();
    result.fold(
      (failure) => emit(AccountError(failure.message, accounts: state.accounts)),
      (accounts) => emit(AccountLoaded(accounts)),
    );
  }

  Future<void> addAccount(Account account) async {
    final result = await repository.addAccount(account);
    result.fold(
      (failure) => emit(AccountError(failure.message, accounts: state.accounts)),
      (newAccount) {
        final updated = [...state.accounts, newAccount];
        emit(AccountLoaded(updated));
      },
    );
  }

  Future<void> updateAccount(Account account) async {
    final result = await repository.updateAccount(account);
    result.fold(
      (failure) => emit(AccountError(failure.message, accounts: state.accounts)),
      (_) {
        final updated = state.accounts
            .map((a) => a.id == account.id ? account : a)
            .toList();
        emit(AccountLoaded(updated));
      },
    );
  }

  Future<void> deleteAccount(String id) async {
    final result = await repository.deleteAccount(id);
    result.fold(
      (failure) => emit(AccountError(failure.message, accounts: state.accounts)),
      (_) {
        final updated = state.accounts.where((a) => a.id != id).toList();
        emit(AccountLoaded(updated));
      },
    );
  }
}
