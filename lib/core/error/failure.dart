import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? code;
  const Failure(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code});
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, {super.code});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, {super.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});
}

class ValidationFailure extends Failure {
  final Map<String, dynamic>? errors;
  const ValidationFailure(super.message, {super.code, this.errors});

  @override
  List<Object?> get props => [message, code, errors];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

class PermissionFailure extends Failure {
  const PermissionFailure(super.message, {super.code = 403});
}

extension FailureExtensions on Failure {
  String get userFriendlyMessage {
    if (this is NetworkFailure) {
      return 'No internet connection. Please check your network and try again.';
    }
    if (this is AuthFailure) {
      return 'Authentication failed. Please log in again.';
    }
    if (this is PermissionFailure) {
      return 'You don\'t have permission to perform this action.';
    }
    if (this is ValidationFailure) {
      return 'Please check your input and try again.';
    }
    if (this is NotFoundFailure) {
      return 'The requested item was not found.';
    }
    return message;
  }
}
