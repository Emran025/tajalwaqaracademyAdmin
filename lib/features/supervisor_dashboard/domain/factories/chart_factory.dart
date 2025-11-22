// factories/student_chart_factory.dart
import 'package:intl/intl.dart';

import '../../data/models/chart_data_point.dart';
import '../../data/models/composite_performance_data.dart';
import '../../data/models/line_chart_datas.dart';
import '../entities/chart_filter_entity.dart';
import '../entities/timeline_entity.dart';

class ChartFactory {
  static LineChartDatas createLineChartData({
    required List<TimelineEntity> timelineData,
    required ChartFilterEntity filter,
  }) {
    final aggregatedData = _aggregateDataByPeriod(timelineData, filter);

    return LineChartDatas(
      actualData: aggregatedData.actualData,
      xAxisLabel: aggregatedData.xAxisLabel,
      yAxisLabel: 'عدد الطلاب',
      maxY: aggregatedData.maxY,
    );
  }

  static List<CompositePerformanceData> createCompositeData({
    required List<TimelineEntity> timelineData,
    required ChartFilterEntity filter,
  }) {
    print(timelineData.length);
    final periods = _splitIntoPeriods(timelineData, filter);

    return periods.map((periodData) {
      print(periodData.length);
      final aggregated = _aggregatePeriodData(periodData, filter);
      return CompositePerformanceData(
        performanceScores: aggregated.actualData,
        xAxisLabel: aggregated.xAxisLabel,
        yAxisLabel: 'عدد الطلاب',
        maxY: aggregated.maxY,
        // periodLabel: _getPeriodLabel(periodData, filter),
      );
    }).toList();
  }

  static ChartAggregationResult _aggregateDataByPeriod(
    List<TimelineEntity> data,
    ChartFilterEntity filter,
  ) {
    final periodData = _groupByPeriod(data, filter);
    final actualData = <ChartDataPoint>[];

    double maxY = 0;

    periodData.forEach((period, entities) {
      final totalActive = entities.last.activeStudents;
      final label = _getPeriodDisplayLabel(period, filter);

      actualData.add(
        ChartDataPoint(label: label, value: totalActive.toDouble()),
      );

      if (totalActive > maxY) maxY = totalActive.toDouble();
    });

    return ChartAggregationResult(
      actualData: actualData,
      xAxisLabel: _getXAxisLabel(filter),
      maxY: maxY * 1.1, // إضافة هامش أعلى
    );
  }

  static Map<String, List<TimelineEntity>> _groupByPeriod(
    List<TimelineEntity> data,
    ChartFilterEntity filter,
  ) {
    final grouped = <String, List<TimelineEntity>>{};

    for (final entity in data) {
      final periodKey = _getPeriodKey(entity.date, filter);
      grouped.putIfAbsent(periodKey, () => []).add(entity);
    }

    // ترتيب الفترات زمنياً
    final sortedKeys = grouped.keys.toList()..sort((a, b) => a.compareTo(b));

    final sortedMap = <String, List<TimelineEntity>>{};
    for (final key in sortedKeys) {
      sortedMap[key] = grouped[key]!..sort((a, b) => a.date.compareTo(b.date));
    }

    return sortedMap;
  }

  static String _getPeriodKey(DateTime date, ChartFilterEntity filter) {
    switch (filter.timePeriod) {
      case 'week':
        final year = date.year;
        final week = ((date.day - date.weekday + 10) / 7).floor();
        return '$year-W$week';
      case 'month':
        return '${date.year}-${date.month.toString().padLeft(2, '0')}';
      case 'quarter':
        final quarter = ((date.month - 1) / 3).floor() + 1;
        return '${date.year}-Q$quarter';
      case 'year':
        return date.year.toString();
      default:
        return date.toIso8601String().split('T').first;
    }
  }

  static String _getPeriodDisplayLabel(
    String periodKey,
    ChartFilterEntity filter,
  ) {
    switch (filter.timePeriod) {
      case 'week':
        final parts = periodKey.split('-W');
        return 'أسبوع ${parts[1]}';
      case 'month':
        final parts = periodKey.split('-');
        final monthNames = [
          '',
          'يناير',
          'فبراير',
          'مارس',
          'أبريل',
          'مايو',
          'يونيو',
          'يوليو',
          'أغسطس',
          'سبتمبر',
          'أكتوبر',
          'نوفمبر',
          'ديسمبر',
        ];
        return '${monthNames[int.parse(parts[1])]} ${parts[0]}';
      case 'quarter':
        return periodKey.replaceFirst('-', ' ');
      case 'year':
        return periodKey;
      default:
        return periodKey;
    }
  }

  static String _getXAxisLabel(ChartFilterEntity filter) {
    switch (filter.timePeriod) {
      case 'week':
        return 'الأسابيع';
      case 'month':
        return 'الأشهر';
      case 'quarter':
        return 'الأرباع السنوية';
      case 'year':
        return 'السنوات';
      default:
        return 'التواريخ';
    }
  }

  static List<List<TimelineEntity>> _splitIntoPeriods(
    List<TimelineEntity> data,
    ChartFilterEntity filter,
  ) {
    // تقسيم البيانات إلى فترات فرعية للعرض في PageView
    final grouped = _groupByPeriod(data, filter);
    return grouped.values.toList();
  }

  static ChartAggregationResult _aggregatePeriodData(
    List<TimelineEntity> periodData,
    ChartFilterEntity filter,
  ) {
    final actualData = <ChartDataPoint>[];
    double maxY = 0;

    for (int i = 0; i < periodData.length; i++) {
      final entity = periodData[i];
      final label = _getDataPointLabel(entity.date, filter, i);

      actualData.add(
        ChartDataPoint(label: label, value: entity.activeStudents.toDouble()),
      );

      if (entity.activeStudents > maxY) maxY = entity.activeStudents.toDouble();
    }

    return ChartAggregationResult(
      actualData: actualData,
      xAxisLabel: _getXAxisLabel(filter),
      maxY: maxY * 1.1,
    );
  }

  static String _getDataPointLabel(
    DateTime date,
    ChartFilterEntity filter,
    int index,
  ) {
    switch (filter.timePeriod) {
      case 'week':
      case 'month':
        return DateFormat('MMM dd').format(date);
      case 'quarter':
      case 'year':
        return DateFormat('MMM').format(date);
      default:
        return (index + 1).toString();
    }
  }

  static String _getPeriodLabel(
    List<TimelineEntity> periodData,
    ChartFilterEntity filter,
  ) {
    if (periodData.isEmpty) return '';

    final first = periodData.first.date;
    final last = periodData.last.date;

    switch (filter.timePeriod) {
      case 'week':
        return '${DateFormat('MMM dd').format(first)} - ${DateFormat('MMM dd').format(last)}';
      case 'month':
        return DateFormat('MMMM yyyy').format(first);
      case 'quarter':
        final quarter = ((first.month - 1) / 3).floor() + 1;
        return 'ربع $quarter ${first.year}';
      case 'year':
        return 'سنة ${first.year}';
      default:
        return '${DateFormat('MMM dd').format(first)} - ${DateFormat('MMM dd').format(last)}';
    }
  }
}

class ChartAggregationResult {
  final List<ChartDataPoint> actualData;
  final String xAxisLabel;
  final double maxY;

  ChartAggregationResult({
    required this.actualData,
    required this.xAxisLabel,
    required this.maxY,
  });
}
