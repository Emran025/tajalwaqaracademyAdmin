// bloc/student_timeline_event.dart
part of 'supervisor_timeline_bloc.dart';

abstract class SupervisorTimelineEvent {}

class LoadCountsDeltaEntity extends SupervisorTimelineEvent {
  LoadCountsDeltaEntity();
}

class LoadTimeline extends SupervisorTimelineEvent {
  final ChartFilterEntity filter;

  LoadTimeline({required this.filter});
}

class UpdateChartFilter extends SupervisorTimelineEvent {
  final ChartFilterEntity filter;

  UpdateChartFilter({required this.filter});
}
