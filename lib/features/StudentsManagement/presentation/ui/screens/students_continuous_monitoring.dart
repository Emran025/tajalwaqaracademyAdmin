import 'package:flutter/material.dart';
import 'package:tajalwaqaracademy/shared/themes/app_theme.dart';
import 'package:tajalwaqaracademy/core/constants/data.dart';
import 'package:tajalwaqaracademy/core/models/report_frequency.dart';
import 'package:tajalwaqaracademy/features/StudentsManagement/domain/entities/student_entity.dart';
import 'package:tajalwaqaracademy/shared/func/date_format.dart';

import 'package:tajalwaqaracademy/shared/widgets/frequency_selector.dart';
import 'package:tajalwaqaracademy/shared/widgets/horizontal_calendar_date_picker.dart';

import '../widgets/student_list_card_with_options.dart';

class StudentsContinuousMonitoring extends StatefulWidget {
  const StudentsContinuousMonitoring({super.key});

  @override
  State<StudentsContinuousMonitoring> createState() =>
      _StudentsContinuousMonitoringState();
}

class _StudentsContinuousMonitoringState
    extends State<StudentsContinuousMonitoring>
    with TickerProviderStateMixin {
  late List<StudentDetailEntity> students;

  DateTime selectedDate = DateTime.now();
  String reportType = 'يومي'; // أو 'أسبوعي', 'شهري'

  Frequency _freq = Frequency.daily; // التردد الافتراضي

  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    students = [
      ...fakeStudents1,
      ...fakeStudents1,
      ...fakeStudents1,
      ...fakeStudents1,
    ];
    super.initState();
    // Add a listener to the scroll controller to detect when the user reaches the end.
  }

  // This is the correct place to trigger the initial data fetch.
  // We do it in the BlocProvider's create method.

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

              // 4) الـTabBarView ياخذ بقية المساحة
              SliverFillRemaining(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 5,
                  ),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      StudentListCardWithOptions(),
                      StudentListCardWithOptions(),
                      StudentListCardWithOptions(),
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
