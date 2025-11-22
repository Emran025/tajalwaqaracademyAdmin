// repository/student_timeline_repository.dart

import '../../../../core/models/user_role.dart';

class ChartFilterEntity {
  final String timePeriod; // 'week', 'month', 'quarter', 'year'
  final UserRole entityType;
  final DateTime startDate;
  final DateTime endDate;

  ChartFilterEntity({
    this.timePeriod = 'month',
    this.entityType = UserRole.student,
    required this.startDate,
    required this.endDate,
  });

  ChartFilterEntity copyWith({
    String? timePeriod,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return ChartFilterEntity(
      timePeriod: timePeriod ?? this.timePeriod,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}
