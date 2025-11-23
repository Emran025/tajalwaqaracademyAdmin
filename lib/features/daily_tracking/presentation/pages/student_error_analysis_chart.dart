import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tajalwaqaracademy/core/models/cheet_tile.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/models/bar_chart_datas.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/domain/entities/chart_filter.dart';
import '../../../../shared/themes/app_theme.dart';
import '../../../supervisor_dashboard/presentation/ui/widgets/base_bar_chart.dart';


class StudentErrorAnalysisChart extends StatefulWidget {
  final List<BarChartDatas> errorDataPeriods;
  final ChartFilter filter;
  final ChartTile tile;
  final Function(ChartFilter)? onFilterChanged;

  const StudentErrorAnalysisChart({
    super.key,
    required this.errorDataPeriods,
    required this.filter,
    required this.tile,
    this.onFilterChanged,
  });

  @override
  State<StudentErrorAnalysisChart> createState() =>
      _StudentErrorAnalysisChartState();
}

class _StudentErrorAnalysisChartState extends State<StudentErrorAnalysisChart> {
  late PageController _pageController;
  late ChartFilter _currentFilter;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.filter;
    _pageController = PageController(
      initialPage: widget.errorDataPeriods.length - 1,
    );
    _currentPageIndex = widget.errorDataPeriods.length - 1;
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

  String _getPeriodLabel() {
    if (_currentPageIndex >= 0 &&
        _currentPageIndex < widget.errorDataPeriods.length) {
      final periodData = widget.errorDataPeriods[_currentPageIndex];
      if (periodData.periodDate != null) {
        return _formatPeriodDate(periodData.periodDate!);
      }
    }
    return 'الفترة ${_currentPageIndex + 1}';
  }

  String _formatPeriodDate(DateTime date) {
    final months = [
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
    return '${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filters Section
        _buildTitelIndicator(widget.tile),
        const SizedBox(height: 16),
        _buildFiltersSection(),
        const SizedBox(height: 16),
        // Period Indicator
        _buildPeriodIndicator(),

        // PageView for Charts
        SizedBox(
          height: 280,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: widget.errorDataPeriods.length,
            itemBuilder: (context, index) {
              final chartData = widget.errorDataPeriods[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: BaseBarChart(
                  chartData: BarChartDatas(
                    data: chartData.data,
                    xAxisLabel: chartData.xAxisLabel,
                    yAxisLabel: chartData.yAxisLabel,
                    maxY: chartData.maxY,
                  ),
                  barColor: AppColors.error,
                ),
              );
            },
          ),
        ),
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
          SizedBox(
            height: 50,
            width: MediaQuery.of(context).size.width - 100,
            child: Row(
              children: [
                Text(
                  'المعايير',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: AppColors.lightCream),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    value: "مقدار ورد",
                    groupValue: tempSelected,
                    activeColor: AppColors.accent,
                    title: Text(
                      "مقدار ورد",
                      style: GoogleFonts.cairo(
                        color: AppColors.lightCream,
                        fontSize: 10,
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        tempSelected = val!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    value: 'فترة زمنية',
                    groupValue: tempSelected,
                    activeColor: AppColors.accent,
                    title: Text(
                      'فترة زمنية',
                      style: GoogleFonts.cairo(
                        color: AppColors.lightCream,
                        fontSize: 10,
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        tempSelected = val!;
                      });
                    },
                  ),
                ),
               
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (tempSelected == 'فترة زمنية')
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
                )
              else
                Expanded(
                  child: _buildFilterDropdown(
                    label: 'مدى الحفظ',
                    value: _currentFilter.quantityUnit,
                    items: const ['page', 'hizb', 'juz', 'full_quran'],
                    labels: const ['صفحة', 'حزب', 'جزء', 'مصحف كامل'],
                    onChanged: (value) {
                      setState(() {
                        _currentFilter = _currentFilter.copyWith(
                          quantityUnit: value,
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

  Widget _buildPeriodIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _getPeriodLabel(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.lightCream,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${_currentPageIndex + 1} من ${widget.errorDataPeriods.length}',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppColors.lightCream70),
          ),
        ],
      ),
    );
  }

  // Mini stat widget

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
