import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tajalwaqaracademy/shared/themes/app_theme.dart';
import 'package:tajalwaqaracademy/core/constants/data.dart';
import 'package:tajalwaqaracademy/core/models/report_frequency.dart';

import 'package:tajalwaqaracademy/shared/func/date_format.dart';

import 'package:tajalwaqaracademy/shared/widgets/avatar.dart';
import 'package:tajalwaqaracademy/shared/widgets/frequency_selector.dart';
import 'package:tajalwaqaracademy/shared/widgets/horizontal_calendar_date_picker.dart';
import 'package:tajalwaqaracademy/shared/widgets/taj.dart';

import '../../../../../shared/widgets/caerd_tile.dart';
import '../../../../StudentsManagement/presentation/ui/screens/student_profile_screen.dart';
import '../../../../StudentsManagement/presentation/view_models/follow_up_report_bundle_entity.dart';
import '../../../../StudentsManagement/domain/entities/student_entity.dart';
import '../../../../StudentsManagement/presentation/view_models/factories/follow_up_report_factory.dart';
import '../../../../StudentsManagement/presentation/ui/screens/follow_up_report_dialog.dart';
import '../../../domain/entities/halqa.dart';

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
  String reportType = 'يومي'; // أو 'أسبوعي', 'شهري'

  Frequency _freq = Frequency.daily; // التردد الافتراضي

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
        FrequencySelector(
          selected: _freq,
          onChanged: (newFreq) {
            setState(() {
              _freq = newFreq;
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

              // 3) إذا عندك تبز (Tabs) إبقى ضيف TabBar هنا
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
                              style: Theme.of(context).textTheme.labelLarge!,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "(${activeHalqas.length + inactiveHalqas.length})",
                              style: Theme.of(context).textTheme.labelLarge!,
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
                              style: Theme.of(context).textTheme.labelLarge!,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "(${activeHalqas.length})",
                              style: Theme.of(context).textTheme.labelLarge!,
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
                              style: Theme.of(context).textTheme.labelLarge!,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "(${activeHalqas.length})",
                              style: Theme.of(context).textTheme.labelLarge!,
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
                      // تاب1: قائمة المتوقع
                      _buildHalqasList(inactiveHalqas, activeHalqas),
                      // تاب1: قائمة المرسل
                      _buildHalqasList([], activeHalqas),
                      // تاب1: قائمة التأخرين
                      _buildHalqasList(inactiveHalqas, []),
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
      child: Text(
        text,
        style: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.lightCream,
        ),
      ),
    );
  }

  Widget _buildHalqasList(
    List<Halqa> activeHalqas,
    List<Halqa> inactiveHalqas,
  ) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: inactiveHalqas.length + activeHalqas.length,
      separatorBuilder: (_, __) => SizedBox(height: 8),
      itemBuilder: (_, i) {
        List<Halqa> halqas = [...activeHalqas, ...inactiveHalqas];
        return CustomListListTile(
          title: halqas[i].halqaName,
          moreIcon: Icons.more_vert,
          leading: Avatar(),
          subtitle: halqas[i].country,
          backgroundColor: AppColors.accent12,
          border: Border.all(color: AppColors.accent70, width: 0.5),
          onMoreTab: () => {},
          onListTilePressed: () => {},
          onTajPressed: () {
            _showStudentsReports(halqas[i]);
          },
        );
      },
    );
  }

  void _showStudentReports(
    String name,
    FollowUpReportBundleEntity reportBundle,
  ) {
    showDialog(
      context: context,
      builder: (_) =>
          FollowUpReportDialog(studentName: name, bundle: reportBundle),
    );
  }

  void _showStudentsReports(Halqa halqa) {
    List<StudentDetailEntity> students = [
      ...fakeStudents1,
      ...fakeStudents1,
      ...fakeStudents1,
      ...fakeStudents1,
    ];
    // List<StudentDetailEntity> students = [
    //   ...fakeStudents.where((element) => halqa.halqaID == element.halaqaId),
    // ];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            padding: const EdgeInsets.all(10),
            constraints: const BoxConstraints(maxHeight: 600),
            decoration: BoxDecoration(
              color: AppColors.accent12,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.accent70, width: 0.7),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            halqa.halqaName,
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.lightCream,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "عدد الطلاب: ${students.length}",
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              color: AppColors.lightCream70,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "إجمالي التقارير: ${students.length}",
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              color: AppColors.lightCream70,
                            ),
                          ),
                          Text(
                            "آخر تقرير: ",
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              color: AppColors.lightCream70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: const Divider(height: 2, color: AppColors.accent70),
                ),

                const SizedBox(height: 10),
                if (students.isNotEmpty)
                  Expanded(
                    child: ListView.separated(
                      itemCount: students.length,
                      shrinkWrap: true,
                      separatorBuilder: (_, __) => const SizedBox(height: 2),
                      // physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (_, index) {
                        final planEntity = studentPlan.toEntity();
                        final trackingEntities = studentTrackings
                            .map((model) => model.toEntity())
                            .toList();
                        final factory = FollowUpReportFactory();
                        final FollowUpReportBundleEntity reportBundle = factory
                            .create(
                              plan: planEntity,
                              trackings: trackingEntities,
                              totalPendingReports: 2,
                            );

                        return Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            // color: AppColors.accent26,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.accent70,
                              width: 0.5,
                            ),
                          ),
                          child: ListTile(
                            onTap: () => {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => StudentProfileScreen(
                                    studentID: students[index].id,
                                  ),
                                ),
                              ),
                            },
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    _showStudentReports(
                                      students[index].name,
                                      reportBundle,
                                    );
                                  },
                                  child: StatusTag(lable: "تقرير"),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.more_vert,
                                    color: AppColors.lightCream,
                                  ),
                                  onPressed: () => {},
                                ),
                              ],
                            ),

                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 0,
                              vertical: 0,
                            ),
                            leading: Avatar(gender: students[index].gender),
                            title: Text(
                              students[index].name,
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold,
                                color: AppColors.lightCream,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "عدد الأيام المسجلة: ${reportBundle.followUpReports.length}",
                                  style: GoogleFonts.cairo(
                                    fontSize: 13,
                                    color: AppColors.lightCream70,
                                  ),
                                ),
                                Text(
                                  "متوسط الإنجاز: ${(reportBundle.followUpReports.map((e) => e.behaviourAssessment).reduce((a, b) => a + b) / reportBundle.followUpReports.length).toStringAsFixed(1)}٪",
                                  style: GoogleFonts.cairo(
                                    fontSize: 13,
                                    color: AppColors.lightCream70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.accent70),
                        ),
                        child: Text(
                          "إغلاق",
                          style: GoogleFonts.cairo(color: AppColors.lightCream),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
