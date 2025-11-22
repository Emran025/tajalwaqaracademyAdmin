import 'package:equatable/equatable.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/models/chart_data_point.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/models/composite_performance_data.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/models/line_chart_data.dart';

/// نموذج بيانات لإحصائيات الطالب
class StudentStatistics extends Equatable {
  final String studentId;
  final String studentName;
  final List<ChartDataPoint> errorCounts; // أنواع الأخطاء
  final LineChartData progressData; // التقدم مقابل الخطة
  final CompositePerformanceData qualityData; // جودة الإتقان
  final CompositePerformanceData overallPerformance; // الأداء العام المركب

  const StudentStatistics({
    required this.studentId,
    required this.studentName,
    required this.errorCounts,
    required this.progressData,
    required this.qualityData,
    required this.overallPerformance,
  });

  @override
  List<Object?> get props => [
    studentId,
    studentName,
    errorCounts,
    progressData,
    qualityData,
    overallPerformance,
  ];
}
