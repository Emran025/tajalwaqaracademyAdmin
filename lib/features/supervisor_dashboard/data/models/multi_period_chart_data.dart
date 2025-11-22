import 'package:equatable/equatable.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/models/bar_chart_datas.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/models/composite_performance_data.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/models/line_chart_data.dart';

/// نموذج بيانات لمجموعة بيانات متعددة الفترات الزمنية
/// يحتوي على 12 فترة زمنية من البيانات
class MultiPeriodChartData extends Equatable {
  final List<BarChartDatas> barChartPeriods; // 12 فترة لمخطط الأعمدة
  final List<LineChartData> lineChartPeriods; // 12 فترة لمخطط الخطوط
  final List<CompositePerformanceData>
  compositeChartPeriods; // 12 فترة للأداء المركب

  const MultiPeriodChartData({
    required this.barChartPeriods,
    required this.lineChartPeriods,
    required this.compositeChartPeriods,
  });

  @override
  List<Object?> get props => [
    barChartPeriods,
    lineChartPeriods,
    compositeChartPeriods,
  ];
}
