
// bloc/student_timeline_state.dart
part of 'supervisor_timeline_bloc.dart';

abstract class SupervisorTimelineState {}

class SupervisorTimelineInitial extends SupervisorTimelineState {}

class SupervisorTimelineLoading extends SupervisorTimelineState {}

class SupervisorTimelineLoaded extends SupervisorTimelineState {
  final CountsDeltaEntity countsDeltaEntity;
  final List<TimelineEntity>? timelineData;
  final List<CompositePerformanceData>? chartData;
  final ChartFilterEntity? filter;
  final DateTimeRange? availableDateRange;

  SupervisorTimelineLoaded({
    required this.countsDeltaEntity,
     this.timelineData,
     this.chartData,
     this.filter,
     this.availableDateRange,
  });

  SupervisorTimelineLoaded copyWith({
    CountsDeltaEntity? countsDeltaEntity,
    List<TimelineEntity>? timelineData,
    List<CompositePerformanceData>? chartData,
    ChartFilterEntity? filter,
    DateTimeRange? availableDateRange,
  }) {
    return SupervisorTimelineLoaded(
      countsDeltaEntity: countsDeltaEntity ?? this.countsDeltaEntity,
      timelineData: timelineData ?? this.timelineData,
      chartData: chartData ?? this.chartData,
      filter: filter ?? this.filter,
      availableDateRange: availableDateRange ?? this.availableDateRange,
    );
  }
}

class SupervisorTimelineError extends SupervisorTimelineState {
  final String message;

  SupervisorTimelineError(this.message);
}