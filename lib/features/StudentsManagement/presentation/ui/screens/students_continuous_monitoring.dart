import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tajalwaqaracademy/core/constants/app_colors.dart';
import 'package:tajalwaqaracademy/core/constants/data.dart';
import 'package:tajalwaqaracademy/core/models/report_frequency.dart';
import 'package:tajalwaqaracademy/features/StudentsManagement/domain/entities/student_entity.dart';
import 'package:tajalwaqaracademy/shared/func/date_format.dart';

import 'package:tajalwaqaracademy/shared/widgets/avatar.dart';
import 'package:tajalwaqaracademy/shared/widgets/frequency_selector.dart';
import 'package:tajalwaqaracademy/shared/widgets/horizontal_calendar_date_picker.dart';
import 'package:tajalwaqaracademy/shared/widgets/taj.dart';

import '../../view_models/follow_up_report_bundle_entity.dart';
import '../../../domain/factories/follow_up_report_factory.dart';
import 'follow_up_report_dialog.dart';

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
  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    students = [
      ...fakeStudents,
      ...fakeStudents,
      ...fakeStudents,
      ...fakeStudents,
    ];
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
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                color: AppColors.lightCream87,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "(31)",
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.lightCream,
                              ),
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
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                color: AppColors.lightCream87,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "(27)",
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.lightCream,
                              ),
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
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                color: AppColors.lightCream87,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "(5)",
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.lightCream,
                              ),
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
                      // تاب1: قائمة التأخرين
                      _buildLateStudentsList(),
                      // تاب1: قائمة التأخرين
                      _buildLateStudentsList(),
                      // تاب1: قائمة التأخرين
                      _buildLateStudentsList(),
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

  Widget _buildStudentCard(
    StudentDetailEntity student,
    void Function()? onPressed,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.accent12,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent70, width: 0.5),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18),
        shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        leading: Avatar(gender: student.gender, pic: student.avatar),
        title: Text(
          student.name,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: AppColors.lightCream,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: Text(
            student.status.labelAr,
            style: GoogleFonts.cairo(fontSize: 12, color: AppColors.lightCream),
          ),
        ),
        onTap: () => {},
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () {
                onPressed!();
              },
              child: StatusTag(lable: "تقرير"),
            ),
            IconButton(
              icon: Icon(Icons.more_vert, color: AppColors.lightCream),
              onPressed: () => {},
            ),
          ],
        ),
      ),
    );
  }

  // مثال: تبويب المتأخرين
  Widget _buildLateStudentsList() {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: students.length,
      separatorBuilder: (_, __) => SizedBox(height: 8),
      itemBuilder: (_, i) {
        return _buildStudentCard(students[i], () {
          _showStudentReports(students[i]);
        });
      },
    );
  }

  void _showStudentReports(StudentDetailEntity student) {
    print("Step 1: Converting Models to Entities...");
    final planEntity = studentPlan.toEntity();
    final trackingEntities = studentTrackings
        .map((model) => model.toEntity())
        .toList();

    // 2. إنشاء نسخة من المصنع (المعالج)
    print("Step 2: Creating the factory instance...");
    final factory = FollowUpReportFactory();

    // 3. استدعاء المصنع لإنشاء حزمة التقرير النهائية
    // هذه هي الخطوة الجوهرية التي تقوم بكل الحسابات.
    print("Step 3: Calling the factory to process entities...");
    final FollowUpReportBundleEntity reportBundle = factory.create(
      plan: planEntity,
      trackings: trackingEntities,
      totalPendingReports: 2, // قيمة ثابتة للتجربة
    );
    print("Step 4: Processing complete. Bundle is ready.");

    showDialog(
      context: context,
      builder: (_) =>
          FollowUpReportDialog(studentName: student.name, bundle: reportBundle),

      //  StudentReports(name: student.name, report: logs),
    );
  }
}
