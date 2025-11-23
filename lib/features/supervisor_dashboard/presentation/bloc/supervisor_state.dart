// bloc/student_timeline_state.dart
part of 'supervisor_bloc.dart';

abstract class SupervisorState {}

class SupervisorInitial extends SupervisorState {}

class SupervisorLoading extends SupervisorState {}

class SupervisorLoaded extends SupervisorState {
  final CountsDeltaEntity? countsDeltaEntity;
  final List<TimelineEntity>? timelineData;
  final List<CompositePerformanceData>? chartData;
  final ChartFilterEntity? filter;
  final DateTimeRange? availableDateRange;
  // New

  final List<ApplicationEntity> applications;
  final int applicationsCurrentPage;
  final bool applicationsHasMorePages;
  final bool isLoadingMoreApplications;
  SupervisorLoaded({
    this.countsDeltaEntity,
    this.timelineData,
    this.chartData,
    this.filter,
    this.availableDateRange,

    // New properties for applications
    this.applications = const [],
    this.applicationsCurrentPage = 1,
    this.applicationsHasMorePages = true,
    this.isLoadingMoreApplications = false,
  });

  SupervisorLoaded copyWith({
    CountsDeltaEntity? countsDeltaEntity,
    List<TimelineEntity>? timelineData,
    List<CompositePerformanceData>? chartData,
    ChartFilterEntity? filter,
    DateTimeRange? availableDateRange,
    List<ApplicationEntity>? applications,
    int? applicationsCurrentPage,
    bool? applicationsHasMorePages,
    bool? isLoadingMoreApplications,
    bool clearApplications = false,
  }) {
    return SupervisorLoaded(
      countsDeltaEntity: countsDeltaEntity ?? this.countsDeltaEntity,
      timelineData: timelineData ?? this.timelineData,
      chartData: chartData ?? this.chartData,
      filter: filter ?? this.filter,
      availableDateRange: availableDateRange ?? this.availableDateRange,

      // Applications
      applications: clearApplications
          ? const []
          : applications ?? this.applications,
      applicationsCurrentPage:
          applicationsCurrentPage ?? this.applicationsCurrentPage,
      applicationsHasMorePages:
          applicationsHasMorePages ?? this.applicationsHasMorePages,
      isLoadingMoreApplications:
          isLoadingMoreApplications ?? this.isLoadingMoreApplications,
    );
  }
}

class SupervisorError extends SupervisorState {
  final String message;

  SupervisorError({required this.message});
}
