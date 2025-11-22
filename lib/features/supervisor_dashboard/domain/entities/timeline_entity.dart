// repository/student_timeline_repository.dart


import '../../../../core/models/user_role.dart';
import '../../data/models/student_summary_delta.dart';

class TimelineEntity {
  final DateTime date;
  final UserRole entityType;
  final int activeStudents;
  final int newAdditions;
  final int deletions;

  TimelineEntity({
    required this.date,
    required this.entityType,
    required this.activeStudents,
    required this.newAdditions,
    required this.deletions,
  });

  factory TimelineEntity.fromSummaryDelta(SummaryDelta delta) {
    return TimelineEntity(
      date: delta.date,
      entityType: delta.entityType,
      activeStudents: delta.activeCount,
      newAdditions: delta.additions,
      deletions: delta.deletions,
    );
  }
}
