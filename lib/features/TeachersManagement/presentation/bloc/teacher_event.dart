part of 'teacher_bloc.dart';

sealed class TeacherEvent extends Equatable {
  const TeacherEvent();
  @override
  List<Object> get props => [];
}

/// Dispatched to initialize the BLoC and start watching the teacher list.
/// Should be called once when the feature is first accessed.
final class WatchTeachersStarted extends TeacherEvent {
  const WatchTeachersStarted();
}

/// Dispatched by the user via a pull-to-refresh gesture to force a sync.
final class TeachersRefreshed extends TeacherEvent {
  const TeachersRefreshed();
}

/// Dispatched when the user scrolls to the end of the list to load more data.
final class MoreTeachersLoaded extends TeacherEvent {
  const MoreTeachersLoaded();
}

/// Dispatched when the user performs an action to add or update a teacher.
final class TeacherUpserted extends TeacherEvent {
  final TeacherDetailEntity teacher;
  const TeacherUpserted(this.teacher);
  @override
  List<Object> get props => [teacher];
}



/// Internal event used to push updates from the data stream into the BLoC.
final class _TeachersStreamUpdated extends TeacherEvent {
  final Either<Failure, List<TeacherListItemEntity>> update;
  const _TeachersStreamUpdated(this.update);
  @override
  List<Object> get props => [update];
}



/// Dispatched when the user navigates to a teacher's profile screen
/// to fetch their detailed information.
final class TeacherDetailsFetched extends TeacherEvent {
  final String teacherId;
  const TeacherDetailsFetched(this.teacherId);

  @override
  List<Object> get props => [teacherId];
}

/// Dispatched when the user confirms the deletion of a teacher.
final class TeacherDeleted extends TeacherEvent {
  final String teacherId;
  const TeacherDeleted(this.teacherId);
  @override
  List<Object> get props => [teacherId];
}




// --- Custom Status Change Events ---

/// Dispatched to change a teacher's status (e.g., accept or suspend).
final class TeacherStatusChanged extends TeacherEvent {
  final String teacherId;
  final ActiveStatus newStatus;
  const TeacherStatusChanged(this.teacherId, this.newStatus);
  @override
  List<Object> get props => [teacherId, newStatus];
}