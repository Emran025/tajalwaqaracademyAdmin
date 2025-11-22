import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/models/bar_chart_datas.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/models/chart_data_point.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/models/composite_performance_data.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/models/line_chart_data.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/models/line_chart_datas.dart';

import '../../core/models/mistake_type.dart';

/// بيانات وهمية (Mock Data) لتشغيل واختبار المخططات البيانية.

// =============================================================================
// 1. بيانات مخطط تحليل الأخطاء (Bar Chart)
//    (يستخدم في StudentErrorAnalysisChart)
// =============================================================================

final List<ChartDataPoint> mockErrorData = const [
  ChartDataPoint(value: 15, label: 'تجويد'),
  ChartDataPoint(value: 25, label: 'نسيان'),
  ChartDataPoint(value: 10, label: 'وقف'),
  ChartDataPoint(value: 5, label: 'حركة'),
  ChartDataPoint(value: 18, label: 'مد'),
  ChartDataPoint(value: 12, label: 'إدغام'),
];

// =============================================================================
// 2. بيانات مخطط التقدم مقابل الخطة (Line Chart)
//    (يستخدم في StudentProgressChart)
// =============================================================================

final LineChartDatas mockProgressData = LineChartDatas(

  xAxisLabel: 'الأسبوع',
  yAxisLabel: 'عدد الصفحات',
  maxY: 100,
  plannedData: const [
    ChartDataPoint(value: 10, label: 'أ1'),
    ChartDataPoint(value: 20, label: 'أ2'),
    ChartDataPoint(value: 30, label: 'أ3'),
    ChartDataPoint(value: 40, label: 'أ4'),
    ChartDataPoint(value: 50, label: 'أ5'),
    ChartDataPoint(value: 60, label: 'أ6'),
  ],
  actualData: const [
    ChartDataPoint(value: 8, label: 'أ1'),
    ChartDataPoint(value: 25, label: 'أ2'),
    ChartDataPoint(value: 28, label: 'أ3'),
    ChartDataPoint(value: 35, label: 'أ4'),
    ChartDataPoint(value: 55, label: 'أ5'),
    ChartDataPoint(value: 62, label: 'أ6'),
  ],
);

// =============================================================================
// 3. بيانات مخطط تقييم جودة الإتقان (Composite Performance Chart)
//    (يستخدم في StudentQualityAssessmentChart)
// =============================================================================

final CompositePerformanceData mockQualityData = CompositePerformanceData(
  // title: 'تقييم جودة الإتقان (شهري)',
  xAxisLabel: 'الشهر',
  yAxisLabel: 'الدرجة (0-100)',
  maxY: 100,
  performanceScores: const [
    ChartDataPoint(value: 85, label: 'ش1'),
    ChartDataPoint(value: 92, label: 'ش2'),
    ChartDataPoint(value: 78, label: 'ش3'),
    ChartDataPoint(value: 95, label: 'ش4'),
    ChartDataPoint(value: 88, label: 'ش5'),
    ChartDataPoint(value: 90, label: 'ش6'),
  ],
);

// =============================================================================
// 4. بيانات مخطط الأداء العام المركب (Composite Performance Chart)
//    (يستخدم في مخطط StudentOverallPerformanceChart - لم يتم إنشاؤه بعد)
// =============================================================================

final CompositePerformanceData mockOverallPerformanceData =
    CompositePerformanceData(
      // title: 'مؤشر الأداء العام المركب (ربع سنوي)',
      xAxisLabel: 'الربع',
      yAxisLabel: 'المؤشر (0-100)',
      maxY: 100,
      performanceScores: const [
        ChartDataPoint(value: 75, label: 'ر1'),
        ChartDataPoint(value: 82, label: 'ر2'),
        ChartDataPoint(value: 88, label: 'ر3'),
        ChartDataPoint(value: 91, label: 'ر4'),
      ],
    );

// =============================================================================
// 5. بيانات مخطط عدد الحفاظ (Bar Chart)
//    (يستخدم في HalqaGraduatesChart - لم يتم إنشاؤه بعد)
// =============================================================================

final BarChartDatas mockGraduatesData = BarChartDatas(
   // title: 'عدد الحفاظ المتخرجين (سنوي)',
  xAxisLabel: 'السنة',
  yAxisLabel: 'العدد',
  maxY: 50,
  data: const [
    ChartDataPoint(value: 15, label: '2021'),
    ChartDataPoint(value: 22, label: '2022'),
    ChartDataPoint(value: 30, label: '2023'),
    ChartDataPoint(value: 45, label: '2024'),
  ],
);

/// بيانات وهمية (Mock Data) لتشغيل واختبار المخططات البيانية
/// توفر 12 فترة زمنية (شهر) من البيانات لكل مخطط

// =============================================================================
// دالة مساعدة لإنشاء تاريخ الفترة الزمنية
// =============================================================================

DateTime _getPeriodDate(int monthsAgo) {
  final now = DateTime.now();
  return DateTime(now.year, now.month - monthsAgo, 1);
}

// =============================================================================
// 1. بيانات مخطط تحليل الأخطاء (12 فترة شهرية)
// =============================================================================

final List<BarChartDatas> mockErrorDataPeriods = List.generate(
  12,
  (index) => BarChartDatas(
    data: [
      ChartDataPoint(
        value: 25 - (index * 1),
        label: MistakeType.pronunciation.labelAr,
      ),
      ChartDataPoint(
        value: 15 + (index * 2),
        label: MistakeType.timing.labelAr,
      ),
      ChartDataPoint(
        value: 5 + (index * 0.5),
        label: MistakeType.grammar.labelAr,
      ),
      ChartDataPoint(
        value: 18 - (index * 0.8),
        label: MistakeType.memory.labelAr,
      ),
    ],
    xAxisLabel: 'نوع الخطأ',
    yAxisLabel: 'عدد الأخطاء',
    maxY: 50,
    periodDate: _getPeriodDate(11 - index), // من الشهر الأقدم إلى الأحدث
  ),
);

// =============================================================================
// 2. بيانات مخطط التقدم مقابل الخطة (12 فترة شهرية)
// =============================================================================

final List<LineChartData> mockProgressDataPeriods = List.generate(
  12,
  (index) => LineChartData(
    
    xAxisLabel: 'الأسبوع',
    yAxisLabel: 'عدد الصفحات',
    maxY: 100,
    plannedData: const [
      ChartDataPoint(value: 10, label: 'أ1'),
      ChartDataPoint(value: 20, label: 'أ2'),
      ChartDataPoint(value: 30, label: 'أ3'),
      ChartDataPoint(value: 40, label: 'أ4'),
    ],
    actualData: [
      ChartDataPoint(value: 8 + (index * 0.5), label: 'أ1'),
      ChartDataPoint(value: 25 + (index * 0.3), label: 'أ2'),
      ChartDataPoint(value: 28 + (index * 0.8), label: 'أ3'),
      ChartDataPoint(value: 35 + (index * 1.2), label: 'أ4'),
    ],
    periodDate: _getPeriodDate(11 - index),
  ),
);

// =============================================================================
// 3. بيانات مخطط تقييم جودة الإتقان (12 فترة شهرية)
// =============================================================================

final List<CompositePerformanceData> mockQualityDataPeriods = List.generate(
  12,
  (index) => CompositePerformanceData(
    // title: 'تقييم جودة الإتقان',
    xAxisLabel: 'الشهر',
    yAxisLabel: 'الدرجة (0-100)',
    maxY: 100,
    performanceScores: [
      ChartDataPoint(value: 85 + (index * 0.5), label: 'ش1'),
      ChartDataPoint(value: 92 + (index * 0.3), label: 'ش2'),
      ChartDataPoint(value: 78 + (index * 1.2), label: 'ش3'),
      ChartDataPoint(value: 95 - (index * 0.2), label: 'ش4'),
    ],
    periodDate: _getPeriodDate(11 - index),
  ),
);

// =============================================================================
// بيانات إضافية (اختيارية)
// =============================================================================
