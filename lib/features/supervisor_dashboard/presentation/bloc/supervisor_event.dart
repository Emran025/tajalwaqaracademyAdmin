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

/// Dispatched to fetch student applicants specifically
// student_event.dart
final class ApplicantsFetched extends SupervisorEvent {
  final int page;
  final UserRole entityType;
  ApplicantsFetched({this.page = 1, required this.entityType});
}

/// Dispatched to load more applicants when reaching end of list
final class MoreApplicantsLoaded extends SupervisorEvent {
  MoreApplicantsLoaded();
}
/// Dispatched to fetch student applicants specifically
// student_event.dart
final class ApplicantDetailsFetched extends SupervisorEvent {
  
  final UserRole applicantId;
  ApplicantDetailsFetched({ required this.applicantId});
}
