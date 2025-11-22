import 'package:equatable/equatable.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/models/chart_data_point.dart';

/// نموذج بيانات لمخطط الأداء المركب
class CompositePerformanceData extends Equatable {
  final List<ChartDataPoint> performanceScores;
  final String xAxisLabel;
  final String yAxisLabel;
  final double maxY;
  final DateTime? periodDate; // تاريخ الفترة الزمنية

  const CompositePerformanceData({
    required this.performanceScores,
    required this.xAxisLabel,
    required this.yAxisLabel,
    this.maxY = 100,
    this.periodDate,
  });

  @override
  List<Object?> get props => [
    performanceScores,
    xAxisLabel,
    yAxisLabel,
    maxY,
    periodDate,
  ];
}
