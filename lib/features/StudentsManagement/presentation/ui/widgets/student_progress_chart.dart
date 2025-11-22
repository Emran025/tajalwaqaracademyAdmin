import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/domain/entities/chart_filter.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/models/line_chart_data.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/models/line_chart_datas.dart';
import '../../../../../core/models/cheet_tile.dart';
import '../../../../../shared/themes/app_theme.dart';
import '../../../../supervisor_dashboard/presentation/ui/widgets/base_line_chart.dart';

/// مخطط التقدم مقابل الخطة للطالب
/// يعرض خطين: الخطة المقررة (أخضر) والتنفيذ الفعلي (أزرق)
class StudentProgressChart extends StatefulWidget {
  final List<LineChartData> progressData;
  final ChartTile tile;
  final ChartFilter filter;
  final Function(ChartFilter)? onFilterChanged;

  const StudentProgressChart({
    super.key,
    required this.progressData,
    required this.filter,
    required this.tile,
    this.onFilterChanged,
  });

  @override
  State<StudentProgressChart> createState() => _StudentProgressChartState();
}

class _StudentProgressChartState extends State<StudentProgressChart> {
  late ChartFilter _currentFilter;
  late PageController _pageController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.filter;
    // ابدأ من الفترة الأخيرة (الأحدث) - الفترة 11 (من 0 إلى 11)
    _pageController = PageController(
      initialPage: widget.progressData.length - 1,
    );
    _currentPageIndex = widget.progressData.length - 1;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTitelIndicator(widget.tile),
        // Filters Section
        const SizedBox(height: 16),
        _buildFiltersSection(),
        const SizedBox(height: 16),

        SizedBox(
          height: 350, // ارتفاع ثابت للمخطط
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: widget.progressData.length,
            itemBuilder: (context, index) {
              final chartData = widget.progressData[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: BaseLineChart(
                  chartData: LineChartDatas(
                    plannedData: chartData.plannedData,
                    actualData: chartData.actualData,
                    xAxisLabel: chartData.xAxisLabel,
                    yAxisLabel: chartData.yAxisLabel,
                    maxY: chartData.maxY,
                  ),
                  plannedLineColor: Colors.green,
                  actualLineColor: Colors.blue,
                ),
              );
            },
          ),
        ),

        // Chart
      ],
    );
  }

  Widget _buildTitelIndicator(ChartTile tile) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.lightCream12,
            shape: BoxShape.circle,
          ),
          child: Icon(tile.icon, size: 26, color: AppColors.lightCream),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tile.title,
              style: GoogleFonts.cairo(
                color: AppColors.lightCream,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              tile.subTitle,
              style: GoogleFonts.cairo(
                color: AppColors.lightCream,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String tempSelected = 'فترة زمنية';

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.mediumDark70,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المعايير',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppColors.lightCream),
          ),

          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  label: 'الفترة الزمنية',
                  value: _currentFilter.timePeriod,
                  items: const ['week', 'month', 'quarter', 'year'],
                  labels: const ['أسبوع', 'شهر', 'ربع سنة', 'سنة'],
                  onChanged: (value) {
                    setState(() {
                      _currentFilter = _currentFilter.copyWith(
                        timePeriod: value,
                      );
                      widget.onFilterChanged?.call(_currentFilter);
                    });
                  },
                ),
              ),

              const SizedBox(width: 12),
              SizedBox(
                width: MediaQuery.of(context).size.width / 4,
                child: _buildFilterDropdown(
                  label: 'نوع المسار',
                  value: _currentFilter.trackingType,
                  items: const ['memorization', 'review', 'recitation'],
                  labels: const ['حفظ', 'مراجعة', 'سرد'],
                  onChanged: (value) {
                    setState(() {
                      _currentFilter = _currentFilter.copyWith(
                        trackingType: value,
                      );
                      widget.onFilterChanged?.call(_currentFilter);
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<String> items,
    required List<String> labels,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: AppColors.lightCream70),
        ),
        const SizedBox(height: 4),
        DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.mediumDark,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.lightCream),
          items: items.asMap().entries.map((e) {
            return DropdownMenuItem(value: e.value, child: Text(labels[e.key]));
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
        ),
      ],
    );
  }
}

