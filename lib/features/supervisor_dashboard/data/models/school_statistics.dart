import 'package:equatable/equatable.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/models/bar_chart_datas.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/models/composite_performance_data.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/models/line_chart_data.dart';

/// نموذج بيانات لإحصائيات المدرسة
class SchoolStatistics extends Equatable {
  final String schoolId;
  final String schoolName;
  final LineChartData halqasGrowth; // نمو الحلقات
  final LineChartData studentsGrowth; // نمو الطلاب
  final LineChartData teachersGrowth; // نمو المعلمين
  final CompositePerformanceData averageSchoolPerformance; // متوسط الأداء
  final BarChartDatas schoolRanking; // ترتيب المدرسة

  const SchoolStatistics({
    required this.schoolId,
    required this.schoolName,
    required this.halqasGrowth,
    required this.studentsGrowth,
    required this.teachersGrowth,
    required this.averageSchoolPerformance,
    required this.schoolRanking,
  });

  @override
  List<Object?> get props => [
    schoolId,
    schoolName,
    halqasGrowth,
    studentsGrowth,
    teachersGrowth,
    averageSchoolPerformance,
    schoolRanking,
  ];
}
