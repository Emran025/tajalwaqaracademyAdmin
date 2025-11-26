import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tajalwaqaracademy/core/models/cheet_tile.dart';
import 'package:tajalwaqaracademy/features/daily_tracking/presentation/bloc/error_analysis_chart/error_analysis_chart_bloc.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/models/bar_chart_datas.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/domain/entities/chart_filter.dart';
import '../../../../shared/themes/app_theme.dart';
import '../../../supervisor_dashboard/presentation/ui/widgets/base_bar_chart.dart';
import 'package:tajalwaqaracademy/injection_container.dart';

class StudentErrorAnalysisChart extends StatelessWidget {
  final ChartTile tile;
  final String enrollmentId;

  const StudentErrorAnalysisChart({
    super.key,
    required this.tile,
    required this.enrollmentId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ErrorAnalysisChartBloc>()
        ..add(LoadErrorAnalysisChartData(
          enrollmentId: enrollmentId,
          filter: const ChartFilter(),
        )),
      child: BlocBuilder<ErrorAnalysisChartBloc, ErrorAnalysisChartState>(
        builder: (context, state) {
          return Column(
            children: [
              _buildTitelIndicator(tile),
              const SizedBox(height: 16),
              if (state is ErrorAnalysisChartLoaded) ...[
                _buildFiltersSection(context, state.filter),
                const SizedBox(height: 16),
                _ChartContent(
                  chartData: state.chartData,
                )
              ] else if (state is ErrorAnalysisChartLoading)
                const CircularProgressIndicator()
              else if (state is ErrorAnalysisChartError)
                Text(state.message)
              else
                Container(),
            ],
          );
        },
      ),
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

  Widget _buildFiltersSection(BuildContext context, ChartFilter currentFilter) {
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
                  child: RadioListTile<FilterDimension>(
                    value: FilterDimension.quantity,
                    groupValue: currentFilter.dimension,
                    activeColor: AppColors.accent,
                    title: Text(
                      "مقدار ورد",
                      style: GoogleFonts.cairo(
                        color: AppColors.lightCream,
                        fontSize: 10,
                      ),
                    ),
                    onChanged: (val) {
                      if (val != null) {
                        context.read<ErrorAnalysisChartBloc>().add(
                            UpdateErrorAnalysisChartFilter(
                                filter: currentFilter.copyWith(
                                    dimension: val)));
                      }
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<FilterDimension>(
                    value: FilterDimension.time,
                    groupValue: currentFilter.dimension,
                    activeColor: AppColors.accent,
                    title: Text(
                      'فترة زمنية',
                      style: GoogleFonts.cairo(
                        color: AppColors.lightCream,
                        fontSize: 10,
                      ),
                    ),
                    onChanged: (val) {
                      if (val != null) {
                        context.read<ErrorAnalysisChartBloc>().add(
                            UpdateErrorAnalysisChartFilter(
                                filter: currentFilter.copyWith(
                                    dimension: val)));
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (currentFilter.dimension == FilterDimension.time)
                Expanded(
                  child: _buildFilterDropdown(
                    context: context,
                    label: 'الفترة الزمنية',
                    value: currentFilter.timePeriod,
                    items: const ['week', 'month', 'quarter', 'year'],
                    labels: const ['أسبوع', 'شهر', 'ربع سنة', 'سنة'],
                    onChanged: (value) {
                      context.read<ErrorAnalysisChartBloc>().add(
                          UpdateErrorAnalysisChartFilter(
                              filter: currentFilter.copyWith(
                                  timePeriod: value)));
                    },
                  ),
                )
              else
                Expanded(
                  child: _buildFilterDropdown(
                    context: context,
                    label: 'مدى الحفظ',
                    value: currentFilter.quantityUnit,
                    items: const ['page', 'hizb', 'juz', 'full_quran'],
                    labels: const ['صفحة', 'حزب', 'جزء', 'مصحف كامل'],
                    onChanged: (value) {
                      context.read<ErrorAnalysisChartBloc>().add(
                          UpdateErrorAnalysisChartFilter(
                              filter: currentFilter.copyWith(
                                  quantityUnit: value)));
                    },
                  ),
                ),
              const SizedBox(width: 12),
              SizedBox(
                width: MediaQuery.of(context).size.width / 4,
                child: _buildFilterDropdown(
                  context: context,
                  label: 'نوع المسار',
                  value: currentFilter.trackingType,
                  items: const ['memorization', 'review', 'recitation'],
                  labels: const ['حفظ', 'مراجعة', 'سرد'],
                  onChanged: (value) {
                    context.read<ErrorAnalysisChartBloc>().add(
                        UpdateErrorAnalysisChartFilter(
                            filter:
                                currentFilter.copyWith(trackingType: value)));
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
    required BuildContext context,
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

class _ChartContent extends StatefulWidget {
  final List<BarChartDatas> chartData;

  const _ChartContent({required this.chartData});

  @override
  State<_ChartContent> createState() => _ChartContentState();
}

class _ChartContentState extends State<_ChartContent> {
  late PageController _pageController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: widget.chartData.isNotEmpty ? widget.chartData.length - 1 : 0,
    );
    _currentPageIndex = widget.chartData.isNotEmpty ? widget.chartData.length - 1 : 0;
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
        _currentPageIndex < widget.chartData.length) {
      final periodData = widget.chartData[_currentPageIndex];
      if (periodData.periodLabel != null) {
        return periodData.periodLabel!;
      }
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
    if (widget.chartData.isEmpty) {
      return const Text('لا توجد بيانات لعرضها');
    }
    return Column(
      children: [
        _buildPeriodIndicator(),
        SizedBox(
          height: 280,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: widget.chartData.length,
            itemBuilder: (context, index) {
              final chartData = widget.chartData[index];
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
            '${_currentPageIndex + 1} من ${widget.chartData.length}',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppColors.lightCream70),
          ),
        ],
      ),
    );
  }
}
