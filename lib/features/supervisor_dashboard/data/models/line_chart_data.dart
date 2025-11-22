import 'package:equatable/equatable.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/models/chart_data_point.dart';

/// نموذج بيانات لمخطط الخطوط (Line Chart)
class LineChartData extends Equatable {
  final List<ChartDataPoint> plannedData;
  final List<ChartDataPoint> actualData;

  final String xAxisLabel;
  final String yAxisLabel;
  final double maxY;
  final DateTime? periodDate; // تاريخ الفترة الزمنية

  const LineChartData({
    required this.plannedData,
    required this.actualData,

    required this.xAxisLabel,
    required this.yAxisLabel,
    this.maxY = 100,
    this.periodDate,
  });

  @override
  List<Object?> get props => [
    plannedData,
    actualData,
    xAxisLabel,
    yAxisLabel,
    maxY,
    periodDate,
  ];
}
