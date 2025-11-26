import 'package:equatable/equatable.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/models/chart_data_point.dart';

/// نموذج بيانات لمخطط الأعمدة (Bar Chart)
class BarChartDatas extends Equatable {
  final List<ChartDataPoint> data;
  // final String title;
  final String xAxisLabel;
  final String yAxisLabel;
  final double maxY;
  final DateTime? periodDate; // تاريخ الفترة الزمنية
  final String? periodLabel;

  const BarChartDatas({
    required this.data,
    // required this.title,
    required this.xAxisLabel,
    required this.yAxisLabel,
    this.maxY = 100,
    this.periodDate,
    this.periodLabel,
  });

  @override
  List<Object?> get props =>
      [data, xAxisLabel, yAxisLabel, maxY, periodDate, periodLabel];
}



