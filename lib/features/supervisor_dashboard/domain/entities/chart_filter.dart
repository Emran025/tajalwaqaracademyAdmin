import 'package:equatable/equatable.dart';

/// نموذج بيانات للفلاتر (المعايير القابلة للتعديل)
/// تم إزالة currentPeriodIndex لأن التنقل سيتم عبر PageView
class ChartFilter extends Equatable {
  final String timePeriod; // 'week', 'month', 'quarter', 'year'
  final String quantityUnit; // 'page', 'hizb', 'juz', 'full_quran'
  final String trackingType; // 'memorization', 'review', 'recitation'
  final DateTime? startDate;
  final DateTime? endDate;

  const ChartFilter({
    this.timePeriod = 'month',
    this.startDate,
    this.endDate,
    this.quantityUnit = 'juz',
    this.trackingType = 'memorization',
  });

  @override
  List<Object?> get props => [timePeriod, quantityUnit, trackingType];

  /// دالة مساعدة لإنشاء نسخة معدلة من الفلتر
  ChartFilter copyWith({
    String? timePeriod,
    String? quantityUnit,
    String? trackingType,
  }) {
    return ChartFilter(
      timePeriod: timePeriod ?? this.timePeriod,
      quantityUnit: quantityUnit ?? this.quantityUnit,
      trackingType: trackingType ?? this.trackingType,
    );
  }
}
