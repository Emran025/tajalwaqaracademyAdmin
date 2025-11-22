import 'package:equatable/equatable.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/models/chart_data_point.dart';

/// نموذج بيانات لمخطط الخطوط (Line Chart)
class LineChartDatas extends Equatable {
  final List<ChartDataPoint>? plannedData;
  final List<ChartDataPoint> actualData;
  final String xAxisLabel;
  final String yAxisLabel;
  final double maxY;

  const LineChartDatas({
    this.plannedData,
    required this.actualData,
    required this.xAxisLabel,
    required this.yAxisLabel,
    this.maxY = 100,
  });

  @override
  List<Object?> get props => [
    plannedData,
    actualData,
    xAxisLabel,
    yAxisLabel,
    maxY,
  ];
}
