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

  final List<ApplicantEntity> applicants;
  final int applicantsCurrentPage;
  final bool applicantsHasMorePages;

  final bool isLoadingMoreApplicants;
  final ApplicantProfileEntity? applicantProfile;
  SupervisorLoaded({
    this.countsDeltaEntity,
    this.timelineData,
    this.chartData,
    this.filter,
    this.availableDateRange,
    this.applicantProfile,
    // New properties for applicants
    this.applicants = const [],
    this.applicantsCurrentPage = 1,
    this.applicantsHasMorePages = true,
    this.isLoadingMoreApplicants = false,
  });

  SupervisorLoaded copyWith({
    CountsDeltaEntity? countsDeltaEntity,
    List<TimelineEntity>? timelineData,
    List<CompositePerformanceData>? chartData,
    ChartFilterEntity? filter,
    DateTimeRange? availableDateRange,
    List<ApplicantEntity>? applicants,
    int? applicantsCurrentPage,
    bool? applicantsHasMorePages,
    bool? isLoadingMoreApplicants,
    ApplicantProfileEntity? applicantProfile,
    bool clearApplicants = false,
  }) {
    return SupervisorLoaded(
      countsDeltaEntity: countsDeltaEntity ?? this.countsDeltaEntity,
      timelineData: timelineData ?? this.timelineData,
      chartData: chartData ?? this.chartData,
      filter: filter ?? this.filter,
      availableDateRange: availableDateRange ?? this.availableDateRange,
      applicantProfile: applicantProfile ?? this.applicantProfile,
      // Applicants
      applicants: clearApplicants ? const [] : applicants ?? this.applicants,
      applicantsCurrentPage:
          applicantsCurrentPage ?? this.applicantsCurrentPage,
      applicantsHasMorePages:
          applicantsHasMorePages ?? this.applicantsHasMorePages,
      isLoadingMoreApplicants:
          isLoadingMoreApplicants ?? this.isLoadingMoreApplicants,
    );
  }
}

class SupervisorError extends SupervisorState {
  final String message;

  SupervisorError({required this.message});
}
