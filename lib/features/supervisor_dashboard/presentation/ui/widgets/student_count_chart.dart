import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/models/composite_performance_data.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/models/line_chart_datas.dart';
import '../../../../../core/models/cheet_tile.dart';
import '../../../../../shared/themes/app_theme.dart';
import '../../../../supervisor_dashboard/presentation/ui/widgets/base_line_chart.dart';
import '../../../domain/entities/chart_filter_entity.dart';

class StudentCountChart extends StatefulWidget {
  final List<CompositePerformanceData> qualityData;
  final ChartFilterEntity filter; // تغيير من ChartFilter إلى ChartFilterEntity
  final ChartTile tile;
  final Function(ChartFilterEntity)? onFilterChanged; // تحديث نوع الدالة

  const StudentCountChart({
    super.key,
    required this.qualityData,
    required this.filter,
    required this.tile,
    this.onFilterChanged,
  });

  @override
  State<StudentCountChart> createState() => _StudentCountChartState();
}

class _StudentCountChartState extends State<StudentCountChart> {
  late ChartFilterEntity _currentFilter;
  late PageController _pageController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _currentFilter = widget.filter;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(StudentCountChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filter != oldWidget.filter) {
      setState(() {
        _currentFilter = widget.filter;
      });
    }
  }

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المعايير',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: AppColors.lightCream),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                child: _buildFilterDropdown(
                  label: 'الفترة الزمنية',
                  value: _currentFilter.timePeriod,
                  items: const ['week', 'month', 'quarter', 'year'],
                  labels: const ['أسبوع', 'شهر', 'ربع سنة', 'سنة'],
                  onChanged: (value) {
                    final newFilter = _currentFilter.copyWith(
                      timePeriod: value,
                    );
                    setState(() {
                      _currentFilter = newFilter;
                      widget.onFilterChanged?.call(newFilter);
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

  /// Handles page change events and updates the date filter accordingly
  ///
  /// [Technical Specification]:
  /// - Calculates temporal offset based on page navigation direction
  /// - Maintains temporal integrity across year/month boundaries
  /// - Supports multiple time period granularities (year/quarter/month/week)
  /// - Implements proper date arithmetic with overflow handling
  void _onPageChanged(int index) {
    // Calculate temporal displacement before state update
    final int temporalOffset = index - _currentPageIndex;

    // Update current page state
    setState(() {
      _currentPageIndex = index;
    });

    // Calculate new temporal boundaries
    final DateTime newStartDate = _calculateTemporalOffset(
      referenceDate: widget.filter.startDate,
      offset: temporalOffset,
      period: widget.filter.timePeriod,
    );

    final DateTime newEndDate = _calculatePeriodEnd(
      startDate: newStartDate,
      period: widget.filter.timePeriod,
    );

    // Propagate filter changes upstream
    setState(() {
      widget.onFilterChanged?.call(
        widget.filter.copyWith(startDate: newStartDate, endDate: newEndDate),
      );
    });
  }

  /// Calculates temporal offset while maintaining calendar integrity
  ///
  /// [Parameters]:
  /// - referenceDate: The baseline date for calculations
  /// - offset: Number of periods to offset (positive = future, negative = past)
  /// - period: Temporal granularity ('year', 'quarter', 'month', 'week')
  ///
  /// [Returns]: DateTime adjusted by the specified offset
  DateTime _calculateTemporalOffset({
    required DateTime referenceDate,
    required int offset,
    required String period,
  }) {
    switch (period) {
      case 'year':
        return DateTime(
          referenceDate.year - offset,
          referenceDate.month,
          referenceDate.day,
        );

      case 'quarter':
        return _calculateMonthOffset(
          referenceDate: referenceDate,
          monthOffset: 3 * offset,
        );

      case 'month':
        return _calculateMonthOffset(
          referenceDate: referenceDate,
          monthOffset: offset,
        );

      case 'week':
        return referenceDate.subtract(Duration(days: 7 * offset));

      default:
        return referenceDate;
    }
  }

  /// Handles month arithmetic with automatic year adjustment
  ///
  /// [Algorithm]:
  /// 1. Calculate total month displacement
  /// 2. Compute resulting year and month with overflow handling
  /// 3. Maintain day consistency (handles month-end edge cases)
  DateTime _calculateMonthOffset({
    required DateTime referenceDate,
    required int monthOffset,
  }) {
    // Calculate total months from epoch for precise arithmetic
    final int totalMonths =
        referenceDate.year * 12 + referenceDate.month - 1 + monthOffset;

    // Reconstruct date with proper year/month calculation
    final int targetYear = totalMonths ~/ 12;
    final int targetMonth = (totalMonths % 12) + 1;

    // Handle day overflow (e.g., Jan 31 → Feb 28/29)
    final int lastDayOfMonth = DateTime(targetYear, targetMonth + 1, 0).day;
    final int targetDay = referenceDate.day > lastDayOfMonth
        ? lastDayOfMonth
        : referenceDate.day;

    return DateTime(targetYear, targetMonth, targetDay);
  }

  /// Calculates period end date based on start date and period type
  ///
  /// [Business Logic]:
  /// - Year: Exactly one year duration
  /// - Quarter: 3-month duration
  /// - Month: Calendar month duration
  /// - Week: 7-day duration
  DateTime _calculatePeriodEnd({
    required DateTime startDate,
    required String period,
  }) {
    switch (period) {
      case 'year':
        return DateTime(
          startDate.year + 1,
          startDate.month,
          startDate.day,
        ).subtract(const Duration(days: 1));

      case 'quarter':
        return DateTime(
          startDate.year,
          startDate.month + 3,
          startDate.day,
        ).subtract(const Duration(days: 1));

      case 'month':
        return DateTime(
          startDate.year,
          startDate.month + 1,
          startDate.day,
        ).subtract(const Duration(days: 1));

      case 'week':
        return startDate.add(const Duration(days: 6));

      default:
        return startDate.add(const Duration(days: 30));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTitelIndicator(widget.tile),

        const SizedBox(height: 16),
        _buildFiltersSection(),
        const SizedBox(height: 16),

        SizedBox(
          height: 350,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: widget.qualityData.length,

            itemBuilder: (context, index) {
              final chartData = widget.qualityData[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: BaseLineChart(
                  chartData: LineChartDatas(
                    actualData: chartData.performanceScores,
                    xAxisLabel: chartData.xAxisLabel,
                    yAxisLabel: chartData.yAxisLabel,
                    maxY: chartData.maxY,
                  ),
                  actualLineColor: Colors.orange,
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
