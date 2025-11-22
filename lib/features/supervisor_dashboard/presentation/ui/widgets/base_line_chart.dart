import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/models/line_chart_datas.dart';
import '../../../../../shared/themes/app_theme.dart';

/// Widget أساسي لمخطط الخطوط (Line Chart)
/// يوفر تمثيلاً بصرياً للبيانات على شكل خطوط مع دعم مقارنة خطين (مخطط ومنفذ)
class BaseLineChart extends StatefulWidget {
  final LineChartDatas chartData;
  final VoidCallback? onRefresh;
  final bool showLegend;
  final bool showGrid;
  final Color? plannedLineColor;
  final Color actualLineColor;
  final Color backgroundColor;

  const BaseLineChart({
    super.key,
    required this.chartData,
    this.onRefresh,
    this.showLegend = true,
    this.showGrid = true,
    this.plannedLineColor,
    this.actualLineColor = Colors.blue,
    this.backgroundColor = AppColors.darkBackground70,
  });

  @override
  State<BaseLineChart> createState() => _BaseLineChartState();
}

class _BaseLineChartState extends State<BaseLineChart> {
  // دالة لحساب horizontalInterval بشكل آمن
  double _getSafeHorizontalInterval() {
    final maxY = widget.chartData.maxY;

    // إذا كان maxY صفر أو أقل، نستخدم قيمة افتراضية
    if (maxY <= 0) return 1.0;

    // نقسم إلى 5 أجزاء مع ضمان أن النتيجة ليست صفر
    final interval = maxY / 5;
    return interval > 0 ? interval : 1.0;
  }

  // دالة لحساب maxY آمن للرسم البياني
  double _getSafeMaxY() {
    final maxY = widget.chartData.maxY;
    // إذا كان maxY صفر، نستخدم قيمة افتراضية لمنع الأخطاء
    return maxY > 0 ? maxY : 5.0;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          // Legend
          if (widget.showLegend && widget.chartData.plannedData != null) ...[
            _buildLegend(),
            const SizedBox(height: 16),
          ],

          // Chart
          AspectRatio(aspectRatio: 3 / 2, child: _buildChart()),

          const SizedBox(height: 24),

          // Statistics Summary
          _buildStatisticsSummary(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (widget.plannedLineColor != null &&
            widget.chartData.plannedData != null)
          _buildLegendItem('المخطط', widget.plannedLineColor!),
        const SizedBox(width: 24),
        _buildLegendItem('المنفذ الفعلي', widget.actualLineColor),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: AppColors.lightCream),
        ),
      ],
    );
  }

  Widget _buildChart() {
    final plannedSpots =
        (widget.plannedLineColor != null &&
            widget.chartData.plannedData != null)
        ? widget.chartData.plannedData!
              .asMap()
              .entries
              .map((e) => FlSpot(e.key.toDouble(), e.value.value))
              .toList()
        : <FlSpot>[];

    final actualSpots = widget.chartData.actualData
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.value))
        .toList();

    // التحقق من وجود بيانات فعلية
    final hasActualData = actualSpots.isNotEmpty;
    final hasPlannedData = plannedSpots.isNotEmpty;

    // إذا لم توجد بيانات، نعرض رسالة أو مخطط فارغ
    if (!hasActualData && !hasPlannedData) {
      return Center(
        child: Text(
          'لا توجد بيانات متاحة',
          style: TextStyle(color: AppColors.lightCream),
        ),
      );
    }

    return LineChart(
      LineChartData(
        lineBarsData: [
          // Planned Line (Green)
          if (hasPlannedData)
            LineChartBarData(
              spots: plannedSpots,
              isCurved: true,
              barWidth: 3,
              color: widget.plannedLineColor,
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    widget.plannedLineColor!.withOpacity(0.3),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                      radius: 4,
                      color: widget.plannedLineColor!,
                      strokeWidth: 1,
                      strokeColor: AppColors.lightCream,
                    ),
              ),
            ),
          // Actual Line (Blue)
          if (hasActualData)
            LineChartBarData(
              spots: actualSpots,
              isCurved: true,
              barWidth: 3,
              color: widget.actualLineColor,
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    widget.actualLineColor.withOpacity(0.3),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                      radius: 4,
                      color: widget.actualLineColor,
                      strokeWidth: 1,
                      strokeColor: AppColors.lightCream,
                    ),
              ),
            ),
        ],
        // استخدام maxY آمن
        maxY: _getSafeMaxY(),
        minY: 0, // تحديد قيمة دنيا لمنع الأخطاء

        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                // استخدام البيانات المتاحة
                final dataList =
                    widget.chartData.plannedData ?? widget.chartData.actualData;
                if (index >= 0 && index < dataList.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      dataList[index].label,
                      style: const TextStyle(
                        color: AppColors.lightCream,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
              reservedSize: 40, // مساحة مخصصة للعناوين
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    '${value.toInt()}',
                    style: const TextStyle(
                      color: AppColors.lightCream70,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),

        borderData: FlBorderData(show: false),

        gridData: FlGridData(
          show: widget.showGrid,
          drawHorizontalLine: true,
          // استخدام horizontalInterval آمن
          horizontalInterval: _getSafeHorizontalInterval(),
          getDrawingHorizontalLine: (value) {
            return FlLine(color: AppColors.lightCream12, strokeWidth: 1);
          },
          drawVerticalLine: false, // إخفاء الخطوط العمودية لتقليل الفوضى
        ),

        // إعدادات إضافية لتحسين المظهر
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            // tooltipBgColor: AppColors.darkBackground,
            // tooltipRoundedRadius: 8,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((touchedSpot) {
                return LineTooltipItem(
                  '${touchedSpot.y.toInt()}',
                  const TextStyle(color: AppColors.lightCream),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsSummary() {
    final plannedValues =
        (widget.plannedLineColor != null &&
            widget.chartData.plannedData != null)
        ? widget.chartData.plannedData!.map((e) => e.value).toList()
        : <double>[];
    final actualValues = widget.chartData.actualData
        .map((e) => e.value)
        .toList();

    final plannedAverage = plannedValues.isEmpty
        ? 0.0
        : plannedValues.reduce((a, b) => a + b) / plannedValues.length;
    final actualAverage = actualValues.isEmpty
        ? 0.0
        : actualValues.reduce((a, b) => a + b) / actualValues.length;

    final variance = (actualAverage - plannedAverage).abs();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildMiniStat('متوسط المخطط', '${plannedAverage.toStringAsFixed(1)}'),
        _buildMiniStat('متوسط المنفذ', '${actualAverage.toStringAsFixed(1)}'),
        _buildMiniStat('معدل الانحراف', '${variance.toStringAsFixed(1)}'),
      ],
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.cairo(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
