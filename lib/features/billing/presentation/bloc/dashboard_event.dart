part of 'dashboard_bloc.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboardDataEvent extends DashboardEvent {
  final bool forceRefresh;
  const LoadDashboardDataEvent({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}
