import 'package:equatable/equatable.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/models/bar_chart_datas.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/models/chart_data_point.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/models/composite_performance_data.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/models/line_chart_data.dart';

/// نموذج بيانات لإحصائيات الحلقة
class HalqaStatistics extends Equatable {
  final String halqaId;
  final String halqaName;
  final List<ChartDataPoint> averageErrorCounts; // متوسط الأخطاء
  final LineChartData averageProgressData; // متوسط التقدم
  final CompositePerformanceData averageQualityData; // متوسط الجودة
  final CompositePerformanceData teacherCommitmentData; // التزام المعلم
  final BarChartDatas graduatesData; // عدد الحفاظ

  const HalqaStatistics({
    required this.halqaId,
    required this.halqaName,
    required this.averageErrorCounts,
    required this.averageProgressData,
    required this.averageQualityData,
    required this.teacherCommitmentData,
    required this.graduatesData,
  });

  @override
  List<Object?> get props => [
    halqaId,
    halqaName,
    averageErrorCounts,
    averageProgressData,
    averageQualityData,
    teacherCommitmentData,
    graduatesData,
  ];
}
