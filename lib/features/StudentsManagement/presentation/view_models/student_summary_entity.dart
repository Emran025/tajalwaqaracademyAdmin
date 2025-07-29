
import 'package:tajalwaqaracademy/features/StudentsManagement/presentation/view_models/student_performance_metrics_entity.dart';


// من الأفضل استخدام enum للحالات المحددة
enum PerformanceStatus { ahead, onTrack, behind }

class StudentSummaryEntity  {
  final int totalPendingReports;
  final double totalDeviation;
  final PerformanceStatus status;
  final StudentPerformanceMetricsEntity studentPerformance;

  const StudentSummaryEntity({
    required this.totalPendingReports,
    required this.totalDeviation,
    required this.status,
    required this.studentPerformance,
  });

}

