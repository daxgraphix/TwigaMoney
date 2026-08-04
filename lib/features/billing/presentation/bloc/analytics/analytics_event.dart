part of 'analytics_bloc.dart';

abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object?> get props => [];
}

class LoadAnalyticsEvent extends AnalyticsEvent {
  final DateTime startDate;
  final DateTime endDate;
  final bool forceRefresh;

  const LoadAnalyticsEvent({
    required this.startDate,
    required this.endDate,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [startDate, endDate, forceRefresh];
}
