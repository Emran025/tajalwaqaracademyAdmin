part of 'student_bloc.dart';

sealed class StudentEvent extends Equatable {
  const StudentEvent();
  @override
  List<Object> get props => [];
}

/// Dispatched to initialize the BLoC and start watching the student list.
/// Should be called once when the feature is first accessed.
final class WatchStudentsStarted extends StudentEvent {
  const WatchStudentsStarted();
}

/// Dispatched by the user via a pull-to-refresh gesture to force a sync.
final class StudentsRefreshed extends StudentEvent {
  const StudentsRefreshed();
}

/// Dispatched when the user scrolls to the end of the list to load more data.
final class MoreStudentsLoaded extends StudentEvent {
  const MoreStudentsLoaded();
}

/// Dispatched when the user performs an action to add or update a student.
final class StudentUpserted extends StudentEvent {
  final StudentDetailEntity student;
  const StudentUpserted(this.student);
  @override
  List<Object> get props => [student];
}

/// Dispatched when the user performs an action to add or update a student.
final class FilteredStudents extends StudentEvent {
   final ActiveStatus? status;
 final int? halaqaId;
 final DateTime? trackDate;
 final Frequency? frequencyCode;

  const FilteredStudents({
    this.status,
    this.halaqaId,
    this.trackDate,
    this.frequencyCode,
  });
  
}

/// Internal event used to push updates from the data stream into the BLoC.
final class _StudentsStreamUpdated extends StudentEvent {
  final Either<Failure, List<StudentListItemEntity>> update;
  const _StudentsStreamUpdated(this.update);
  @override
  List<Object> get props => [update];
}

/// Dispatched when the user navigates to a student's profile screen
/// to fetch their detailed information.
final class StudentDetailsFetched extends StudentEvent {
  final String studentId;
  const StudentDetailsFetched(this.studentId);

  @override
  List<Object> get props => [studentId];
}

/// Dispatched when the user confirms the deletion of a student.
final class StudentDeleted extends StudentEvent {
  final String studentId;
  const StudentDeleted(this.studentId);
  @override
  List<Object> get props => [studentId];
}

// --- Custom Status Change Events ---

/// Dispatched to change a student's status (e.g., accept or suspend).
final class StudentStatusChanged extends StudentEvent {
  final String studentId;
  final ActiveStatus newStatus;
  const StudentStatusChanged(this.studentId, this.newStatus);
  @override
  List<Object> get props => [studentId, newStatus];
}


/// Dispatched when the user navigates to a student's profile screen
/// to fetch their detailed information.
final class FollowUpReportFetched extends StudentEvent {
  final String studentId;
  const FollowUpReportFetched(this.studentId);

  @override
  List<Object> get props => [studentId];
}