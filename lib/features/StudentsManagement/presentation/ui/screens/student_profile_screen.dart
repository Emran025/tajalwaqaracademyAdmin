import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tajalwaqaracademy/core/constants/app_colors.dart';
import 'package:tajalwaqaracademy/core/models/active_status.dart';
import 'package:tajalwaqaracademy/core/constants/data.dart';
import '../../../../../shared/func/date_format.dart';
import 'follow_up_report_dialog.dart';

import 'package:tajalwaqaracademy/shared/widgets/avatar.dart';

import '../../../../../config/di/injection.dart';
import '../../view_models/follow_up_report_bundle_entity.dart';
import '../../../domain/entities/student_entity.dart';
import '../../../domain/factories/follow_up_report_factory.dart';
import '../../bloc/student_bloc.dart';
import '../widgets/study_plan_card.dart';
import 'add_student_plan.dart';

class StudentProfileScreen extends StatefulWidget {
  final String studentID;

  const StudentProfileScreen({super.key, required this.studentID});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  late StudentDetailEntity student;

  StudentsPlanForm form = StudentsPlanForm(key: UniqueKey());

  @override
  void initState() {
    // student = fakeStudents[int.parse(widget.studentID)];
    student = fakeStudents.first;
    super.initState();
  }

  void _submitForms() {
    if (form.formKey.currentState?.validate() ?? false) {
      form.formKey.currentState?.save();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // The screen is responsible for creating the BLoC and dispatching the initial event.
      create: (context) =>
          sl<StudentBloc>()..add(StudentDetailsFetched(widget.studentID)),
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        appBar: AppBar(
          title: Text("الملف الشخصي"),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: BlocBuilder<StudentBloc, StudentState>(
          builder: (context, status) {
            if (status.detailsStatus == StudentDetailsStatus.failure) {
              return const Text('Failed to load details');
            } else if (status.detailsStatus == StudentDetailsStatus.success) {
              // When success, the data will be in `state.selectedStudent`.
              // Another BlocBuilder can be used to display the actual data.
              return Directionality(
                textDirection: TextDirection.rtl,
                child: SafeArea(
                  child: ListView(
                    padding: EdgeInsets.all(10),
                    children: [
                      _buildHeader(context),
                      SizedBox(height: 24),
                      _buildInfoRow("البريد", status.selectedStudent!.email),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoRow(
                              "رقم الهاتف",
                              status.selectedStudent!.phone,
                            ),
                          ),
                          SizedBox(width: 8),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: _buildInfoRow(
                              "",
                              "${status.selectedStudent!.phoneZone}",
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoRow(
                              "رقم الواتس",
                              status.selectedStudent!.whatsAppPhone,
                            ),
                          ),
                          SizedBox(width: 8),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: _buildInfoRow(
                              "",
                              "${status.selectedStudent!.whatsAppZone}",
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoRow(
                              "الجنس",
                              status.selectedStudent!.gender.labelAr,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: _buildInfoRow(
                              "الجنسية",
                              status.selectedStudent!.country,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoRow(
                              "بلد الإقامة",
                              status.selectedStudent!.country,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: _buildInfoRow(
                              "المدينة",
                              status.selectedStudent!.city,
                            ),
                          ),
                        ],
                      ),
                      _buildInfoRow(
                        "المرحلة التعليمية",
                        status.selectedStudent!.qualification,
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            // onTap: () => _showStudentReports(),
                            child: Container(
                              height: 50,
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: AppColors.accent70,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit_note,
                                    color: AppColors.lightCream70,
                                    size: 30,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "تعديل البيانات",
                                    style: GoogleFonts.cairo(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.lightCream87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              height: 2,
                              color: AppColors.accent70,
                            ),
                          ),
                        ],
                      ),

                      if (student.status == ActiveStatus.active) ...[
                        SizedBox(height: 15),
                        Text(
                          "خطة التقدم",
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            color: AppColors.lightCream70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        StudyPlanCard(
                          onCountryChanged: _showAddStudentPlan,
                          planType: student.followUpPlan!.frequency,
                          planDetailList: student.followUpPlan!.details,
                        ),
                        SizedBox(height: 15),
                        Text(
                          "السجل اليومي",
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            color: AppColors.lightCream70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        _buildLogCard(),
                      ] else ...[
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  // Navigator.pop(context);
                                },
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  side: BorderSide(color: AppColors.accent70),
                                ),
                                child: Text(
                                  "رفض",
                                  style: GoogleFonts.cairo(
                                    color: AppColors.lightCream,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  backgroundColor: AppColors.accent,
                                ),
                                onPressed: () {
                                  // setState(() {
                                  //   residence.text = tempSelected;
                                  // });
                                  // Navigator.pop(context);
                                },
                                child: Text(
                                  "قبول",
                                  style: GoogleFonts.cairo(
                                    color: AppColors.lightCream,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }

  void _showAddStudentPlan() {
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              backgroundColor: AppColors.lightCream.withOpacity(0.1),
              insetPadding: const EdgeInsets.all(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.9,
                  ),
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.lightCream.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.lightCream38),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.add,
                                color: AppColors.lightCream,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "اضافة خطة دراسية",
                                style: GoogleFonts.cairo(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.lightCream,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(height: 2, color: AppColors.accent70),
                          const SizedBox(height: 16),

                          /// ✅ هذا هو النموذج
                          form,

                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: AppColors.accent70),
                                  ),
                                  child: Text(
                                    "الغاء",
                                    style: GoogleFonts.cairo(
                                      color: AppColors.lightCream,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.accent,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _submitForms();
                                    });
                                  },
                                  child: Text(
                                    "حفظ",
                                    style: GoogleFonts.cairo(
                                      color: AppColors.lightCream,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.lightCream.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightCream38),
      ),
      child: Row(
        children: [
          Avatar(gender: student.gender, pic: student.avatar),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  student.name,
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightCream,
                  ),
                ),
                SizedBox(height: 15),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: student.status == ActiveStatus.active
                        ? AppColors.success.withOpacity(0.3)
                        : Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    student.status.labelAr,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: AppColors.lightCream,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.mediumDark87,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "25  عام",
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    color: AppColors.lightCream,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: student.status == ActiveStatus.active
                      ? AppColors.success.withOpacity(0.3)
                      : Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "25  جزءًا",
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    color: AppColors.lightCream,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.lightCream12,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.cairo(color: AppColors.lightCream70)),
          Text(value, style: GoogleFonts.cairo(color: AppColors.lightCream)),
        ],
      ),
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

  Widget _buildLogCard() {
    return GestureDetector(
      onTap: () => _showStudentReports(student),
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.accent70,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.history, color: AppColors.lightCream70, size: 35),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "السجل اليومي",
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                ),
                Text(
                  "اخر تقرير له في : ${formatDate(DateTime.now())}",
                  style: GoogleFonts.cairo(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
