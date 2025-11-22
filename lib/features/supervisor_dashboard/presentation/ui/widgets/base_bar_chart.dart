import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/models/bar_chart_datas.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/models/chart_data_point.dart';
import '../../../../../shared/themes/app_theme.dart';

/// Widget أساسي لمخطط الأعمدة (Bar Chart)
/// يوفر تمثيلاً بصرياً للبيانات على شكل أعمدة مع دعم التخصيص الكامل
class BaseBarChart extends StatefulWidget {
  final BarChartDatas chartData;
  final VoidCallback? onRefresh;
  final bool showLegend;
  final bool showGrid;
  final Color barColor;

  final Color backgroundColor;

  const BaseBarChart({
    super.key,
    required this.chartData,
    this.onRefresh,
    this.showLegend = true,
    this.showGrid = true,
    this.barColor = AppColors.accent,
    this.backgroundColor = AppColors.darkBackground70,
  });

  @override
  State<BaseBarChart> createState() => _BaseBarChartState();
}

class _BaseBarChartState extends State<BaseBarChart> {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(aspectRatio: 3 / 2, child: _buildChart());
  }

  Widget _buildChart() {
    final barGroups = widget.chartData.data
        .asMap()
        .entries
        .map(
          (e) => BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.value,
                width: 16,
                borderRadius: BorderRadius.zero,
                gradient: LinearGradient(
                  colors: [
                    widget.barColor.withOpacity(0.8),
                    widget.barColor.withOpacity(0.6),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ],
          ),
        )
        .toList();

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              barGroups: barGroups,
              maxY: widget.chartData.maxY,
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < widget.chartData.data.length) {
                        return Text(
                          widget.chartData.data[index].label,
                          style: const TextStyle(
                            color: AppColors.lightCream,
                            fontSize: 10,
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}',
                        style: const TextStyle(
                          color: AppColors.lightCream70,
                          fontSize: 10,
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
                drawVerticalLine: false,
                drawHorizontalLine: true,
                horizontalInterval: widget.chartData.maxY / 10,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: const Color.fromARGB(31, 255, 255, 255),
                    strokeWidth: 1,
                  );
                },
              ),
            ),
          ),
        ),
        _buildStatisticsSummary(),
      ],
    );
  }

  Widget _buildStatisticsSummary() {
    ChartDataPoint maxPoint = widget.chartData.data.first;
    ChartDataPoint minPoint = widget.chartData.data.first;
    double avrage = 0;
    for (ChartDataPoint a in widget.chartData.data) {
      if (a.value < minPoint.value) minPoint = a;
      if (a.value > maxPoint.value) maxPoint = a;
      avrage += a.value;
    }
    widget.chartData.data.isNotEmpty
        ? avrage /= widget.chartData.data.length
        : avrage = 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildMiniStat("المعدل", "$avrage", ''),
          _buildMiniStat("أعلى قيمة", "${maxPoint.value}", minPoint.label),
          _buildMiniStat("أقل قيمة", "${minPoint.value}", maxPoint.label),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, String valueName) {
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
          style: GoogleFonts.cairo(color: Colors.white70, fontSize: 13),
        ),
        Text(
          valueName,
          style: GoogleFonts.cairo(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }
}
