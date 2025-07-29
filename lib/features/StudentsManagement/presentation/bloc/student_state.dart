part of 'student_bloc.dart';

enum StudentStatus { initial, loading, success, failure }

enum StudentDetailsStatus { initial, loading, success, failure }

enum StudentSubmissionStatus { initial, submitting, success, failure }

enum StudentUpsertStatus { initial, submitting, success, failure }

final class StudentState extends Equatable {
  final StudentStatus status;
  final List<StudentListItemEntity> students;
  final bool hasMorePages;
  final int currentPage;
  final Failure? failure;
  final bool isLoadingMore;

  // --- Details State Properties (New) ---
  final StudentDetailsStatus detailsStatus;
  final StudentDetailEntity? selectedStudent;
  final Failure? detailsFailure;

  // --- Operation State (New) ---
  final StudentSubmissionStatus submissionStatus;
  final Failure? submissionFailure;
  // --- Operation State (New) ---
  final StudentUpsertStatus upsertStatus;
  final Failure? upsertFailure;

  const StudentState({
    this.status = StudentStatus.initial,
    this.students = const [],
    this.hasMorePages = true,
    this.currentPage = 1,
    this.failure,
    this.isLoadingMore = false,

    // New
    this.detailsStatus = StudentDetailsStatus.initial,
    this.selectedStudent,
    this.detailsFailure,

    // New
    this.submissionStatus = StudentSubmissionStatus.initial,
    this.submissionFailure,
    // New
    this.upsertStatus = StudentUpsertStatus.initial,
    this.upsertFailure,
  });

  StudentState copyWith({
    StudentStatus? status,
    List<StudentListItemEntity>? students,
    bool? hasMorePages,
    int? currentPage,
    Failure? failure,
    bool? isLoadingMore,

    // New
    StudentDetailsStatus? detailsStatus,
    StudentDetailEntity? selectedStudent,
    Failure? detailsFailure,
    // Flags to clear specific errors
    bool clearListFailure = false,
    bool clearDetailsFailure = false,

    // New
    StudentSubmissionStatus? submissionStatus,
    Failure? submissionFailure,
    bool clearSubmissionFailure = false,
    // New
    StudentUpsertStatus? upsertStatus,
    Failure? upsertFailure,
    bool clearUpsertFailure = false,
  }) {
    return StudentState(
      status: status ?? this.status,
      students: students ?? this.students,
      hasMorePages: hasMorePages ?? this.hasMorePages,
      currentPage: currentPage ?? this.currentPage,
      failure: clearListFailure ? null : failure ?? this.failure,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      // New
      detailsStatus: detailsStatus ?? this.detailsStatus,
      selectedStudent: selectedStudent ?? this.selectedStudent,
      detailsFailure: clearDetailsFailure
          ? null
          : detailsFailure ?? this.detailsFailure,

      // New
      submissionStatus: submissionStatus ?? this.submissionStatus,
      submissionFailure: clearSubmissionFailure
          ? null
          : submissionFailure ?? this.submissionFailure,
      // New
      upsertStatus: upsertStatus ?? this.upsertStatus,
      upsertFailure: clearUpsertFailure
          ? null
          : upsertFailure ?? this.upsertFailure,
    );
  }

  @override
  List<Object?> get props => [
    status, students, hasMorePages, currentPage, failure, isLoadingMore, // New
    detailsStatus,
    selectedStudent,
    detailsFailure,
    submissionStatus,
    submissionFailure,
    upsertStatus,
    upsertFailure,
  ];
}
