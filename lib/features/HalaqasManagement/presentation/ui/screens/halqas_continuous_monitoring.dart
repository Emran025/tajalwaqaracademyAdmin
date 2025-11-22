import 'package:flutter/material.dart';
import '../../../../../shared/themes/app_theme.dart';
import '../../../../../core/models/report_frequency.dart';

import '../../../../../shared/func/date_format.dart';

import '../../../../../shared/widgets/frequency_selector.dart';
import '../../../../../shared/widgets/horizontal_calendar_date_picker.dart';
import '../widgets/halaqa_list_card_with_options.dart';

class HalaqasContinuousMonitoring extends StatefulWidget {
  const HalaqasContinuousMonitoring({super.key});

  @override
  State<HalaqasContinuousMonitoring> createState() =>
      _HalaqasContinuousMonitoringState();
}

class _HalaqasContinuousMonitoringState
    extends State<HalaqasContinuousMonitoring>
    with TickerProviderStateMixin {
  DateTime selectedDate = DateTime.now();
  String reportType = 'يومي';

  Frequency _freq = Frequency.daily;

  late TabController _tabController;
  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Column(
      children: [
        SizedBox(height: 8),
        Selector(
          items: Frequency.values.map((e) => e.labelAr).toList(),
          selected: _freq.labelAr,
          onChanged: (newFreq) {
            setState(() {
              _freq = Frequency.fromId(newFreq);
              reportType = _freq.labelAr;
            });
          },
        ),

        HorizontalCalendarDatePicker(
          startDate: DateTime.now().subtract(const Duration(days: 60)),
          endDate: DateTime.now().add(const Duration(days: 60)),
          initialDate: DateTime.now(),
          onDateSelected: (date) {
            setState(() {
              selectedDate = date;
            });
          },
        ),

        Expanded(
          child: CustomScrollView(
            physics: NeverScrollableScrollPhysics(),
            slivers: [
              // 1) القسم العلوي: هيدر التقرير
              SliverToBoxAdapter(
                child: _buildSectionHeader(
                  'تقرير $reportType المفترض رفعه يوم  ${formatDate(selectedDate)}',
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: accent,
                    dividerColor: Colors.black12,
                    unselectedLabelColor: AppColors.lightCream54,
                    padding: const EdgeInsets.only(top: 16.0),
                    tabs: [
                      Tab(
                        icon: Icon(Icons.warning, color: AppColors.accent),
                        child: Row(
                          children: [
                            Text(
                              "المتوقع",
                              style: Theme.of(context).textTheme.bodyLarge!,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "(31)",
                              style: Theme.of(context).textTheme.bodyLarge!,
                            ),
                          ],
                        ),
                      ),
                      Tab(
                        icon: Icon(Icons.upload, color: AppColors.accent),
                        child: Row(
                          children: [
                            Text(
                              "المرسل",
                              style: Theme.of(context).textTheme.bodyLarge!,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "(27)",
                              style: Theme.of(context).textTheme.bodyLarge!,
                            ),
                          ],
                        ),
                      ),
                      Tab(
                        icon: Icon(Icons.person_off, color: AppColors.accent),
                        child: Row(
                          children: [
                            Text(
                              "المتبقي",
                              style: Theme.of(context).textTheme.bodyLarge!,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "(5)",
                              style: Theme.of(context).textTheme.bodyLarge!,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverFillRemaining(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 5,
                  ),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      HalaqaListCardWithOptions(),
                      HalaqaListCardWithOptions(),
                      HalaqaListCardWithOptions(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, left: 8, right: 8),
      child: Text(text, style: Theme.of(context).textTheme.bodyLarge!),
    );
  }
}
