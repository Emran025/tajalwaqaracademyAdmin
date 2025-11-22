import 'package:equatable/equatable.dart';

/// نموذج بيانات أساسي لتمثيل نقطة بيانات في المخطط
class ChartDataPoint extends Equatable {
  final double value;
  final String label;
  final DateTime? date;

  const ChartDataPoint({required this.value, required this.label, this.date});

  @override
  List<Object?> get props => [value, label, date];
}
