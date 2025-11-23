// bloc/student_timeline_event.dart
part of 'supervisor_bloc.dart';

abstract class SupervisorEvent {}

class LoadCountsDeltaEntity extends SupervisorEvent {
  LoadCountsDeltaEntity();
}

class LoadTimeline extends SupervisorEvent {
  final ChartFilterEntity filter;

  LoadTimeline({required this.filter});
}

class UpdateChartFilter extends SupervisorEvent {
  final ChartFilterEntity filter;

  UpdateChartFilter({required this.filter});
}

/// Dispatched to fetch student applications specifically
// student_event.dart
final class ApplicationsFetched extends SupervisorEvent {
  final int page;
  final UserRole entityType;
  ApplicationsFetched({this.page = 1 ,required this.entityType});
}

/// Dispatched to load more applications when reaching end of list
final class MoreApplicationsLoaded extends SupervisorEvent {
  MoreApplicationsLoaded();
}
