import 'package:fpdart/fpdart.dart';
import 'package:twigamoney/core/error/failure.dart';
import 'package:twigamoney/core/usecase/usecase.dart';
import '../entities/transaction.dart';
import 'finance_usecases.dart';

class GetMonthlyReportUseCase implements UseCase<MonthlyReport, DateTime> {
  final GetTransactionsByDateRangeUseCase getTransactionsByDateRangeUseCase;

  GetMonthlyReportUseCase(this.getTransactionsByDateRangeUseCase);

  @override
  Future<Either<Failure, MonthlyReport>> call(DateTime month) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0);
    return getTransactionsByDateRangeUseCase(DateRangeParams(start: start, end: end)).then(
      (result) => result.fold(
        (failure) => Left(failure),
        (transactions) {
          final income = transactions.where((t) => t.type == TransactionType.income).fold(0.0, (sum, t) => sum + t.amount);
          final expenses = transactions.where((t) => t.type == TransactionType.expense).fold(0.0, (sum, t) => sum + t.amount);
          return Right(MonthlyReport(
            month: month,
            totalIncome: income,
            totalExpenses: expenses,
            netIncome: income - expenses,
            transactions: transactions,
          ));
        },
      ),
    );
  }
}

class MonthlyReport {
  final DateTime month;
  final double totalIncome;
  final double totalExpenses;
  final double netIncome;
  final List<Transaction> transactions;

  MonthlyReport({
    required this.month,
    required this.totalIncome,
    required this.totalExpenses,
    required this.netIncome,
    required this.transactions,
  });
}