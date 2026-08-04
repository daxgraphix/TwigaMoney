import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/repositories/transaction_repository.dart';
import '../../domain/usecases/monthly_report_usecase.dart';
import '../../domain/usecases/comprehensive_report_usecase.dart';

enum ReportPeriod { daily, weekly, biweekly, monthly, yearly }

// Events
abstract class ReportEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadMonthlyReportEvent extends ReportEvent {
  final DateTime month;
  LoadMonthlyReportEvent(this.month);
  @override
  List<Object?> get props => [month];
}

class LoadComprehensiveReportEvent extends ReportEvent {
  final DateTime startDate;
  final DateTime endDate;
  LoadComprehensiveReportEvent(this.startDate, this.endDate);
  @override
  List<Object?> get props => [startDate, endDate];
}

// State
abstract class ReportState extends Equatable {
  final dynamic reportData;
  final bool isLoading;
  final String? error;

  const ReportState({
    this.reportData,
    this.isLoading = false,
    this.error,
  });

  dynamic get report => reportData;

  @override
  List<Object?> get props => [reportData, isLoading, error];
}

class ReportInitial extends ReportState {
  const ReportInitial();
}

class ReportLoading extends ReportState {
  const ReportLoading() : super(isLoading: true);
}

class ReportLoaded extends ReportState {
  const ReportLoaded(dynamic report)
      : super(reportData: report, isLoading: false);
}

class ReportError extends ReportState {
  const ReportError(String message) : super(isLoading: false, error: message);
}

// Cubit
class ReportCubit extends Cubit<ReportState> {
  final TransactionRepository transactionRepository;
  final GetMonthlyReportUseCase monthlyReportUseCase;
  final GetComprehensiveBusinessReportUseCase comprehensiveReportUseCase;

  ReportCubit({
    required this.transactionRepository,
    required this.monthlyReportUseCase,
    required this.comprehensiveReportUseCase,
  }) : super(const ReportInitial());

  Future<void> loadMonthlyReport(DateTime month) async {
    emit(ReportLoading());
    final result = await monthlyReportUseCase(month);
    result.fold(
      (failure) => emit(ReportError(failure.message)),
      (data) => emit(ReportLoaded(data)),
    );
  }

  Future<void> loadComprehensiveReport(DateTime start, DateTime end) async {
    emit(ReportLoading());
    final result = await comprehensiveReportUseCase(
        ReportParams(startDate: start, endDate: end));
    result.fold(
      (failure) => emit(ReportError(failure.message)),
      (data) => emit(ReportLoaded(data)),
    );
  }

  Future<void> loadDailyReport() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    await loadComprehensiveReport(today, tomorrow);
  }

  Future<void> loadWeeklyReport() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    await loadComprehensiveReport(startOfWeek, endOfWeek);
  }

  Future<void> loadBiweeklyReport() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(const Duration(days: 13));
    await loadComprehensiveReport(start, today);
  }

  Future<void> loadYearlyReport() async {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    await loadComprehensiveReport(startOfYear, now);
  }

  Future<void> loadReportByPeriod(ReportPeriod period) async {
    switch (period) {
      case ReportPeriod.daily:
        await loadDailyReport();
      case ReportPeriod.weekly:
        await loadWeeklyReport();
      case ReportPeriod.biweekly:
        await loadBiweeklyReport();
      case ReportPeriod.monthly:
        await loadMonthlyReport(DateTime.now());
      case ReportPeriod.yearly:
        await loadYearlyReport();
    }
  }
}
