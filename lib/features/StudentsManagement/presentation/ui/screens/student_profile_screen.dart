import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tajalwaqaracademy/shared/themes/app_theme.dart';
import 'package:tajalwaqaracademy/core/models/active_status.dart';
import '../widgets/add_traking_session.dart';
import '../widgets/study_halaqa_card.dart';
import 'follow_up_report_dialog.dart';

import 'package:tajalwaqaracademy/shared/widgets/avatar.dart';

import '../../../../../config/di/injection.dart';
import '../../../domain/entities/student_entity.dart';
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
  StudentsPlanForm form = StudentsPlanForm(key: UniqueKey());

  @override
  void initState() {
    // student = fakeStudents[int.parse(widget.studentID)];
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
    // الـ BLoC الخاص بالشاشة مسؤول فقط عن بيانات الشاشة
    return BlocProvider(
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
          builder: (context, state) {
            if (state.detailsStatus == StudentInfoStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.detailsStatus == StudentInfoStatus.success) {
              return _buildSuccessfulUI(context, state);
            } else {
              return const Center(child: Text("فشل تحميل التفاصيل"));
            }
          },
        ),
      ),
    );
  }

  // دالة مساعدة لبناء الواجهة الرئيسية لجعل دالة build نظيفة
  Widget _buildSuccessfulUI(BuildContext screenContext, StudentState status) {
    // When success, the data will be in `state.selectedStudent`.
    // Another BlocBuilder can be used to display the actual data.
    final student = status.selectedStudent!.studentDetailEntity;
    final plan = status.selectedStudent!.followUpPlan;
    final halaqa = status.selectedStudent!.assignedHalaqa;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(10),
          children: [
            _buildHeader(context, student),
            SizedBox(height: 24),
            _buildInfoRow("البريد", student.email),
            Row(
              children: [
                Expanded(child: _buildInfoRow("رقم الهاتف", student.phone)),
                SizedBox(width: 8),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: _buildInfoRow(
                    "",
                    "${status.selectedStudent!.studentDetailEntity.phoneZone}",
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    "رقم الواتس",
                    status.selectedStudent!.studentDetailEntity.whatsAppPhone,
                  ),
                ),
                SizedBox(width: 8),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: _buildInfoRow(
                    "",
                    "${status.selectedStudent!.studentDetailEntity.whatsAppZone}",
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    "الجنس",
                    status.selectedStudent!.studentDetailEntity.gender.labelAr,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _buildInfoRow(
                    "الجنسية",
                    status.selectedStudent!.studentDetailEntity.country,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    "بلد الإقامة",
                    status.selectedStudent!.studentDetailEntity.country,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _buildInfoRow(
                    "المدينة",
                    status.selectedStudent!.studentDetailEntity.city,
                  ),
                ),
              ],
            ),
            _buildInfoRow(
              "المرحلة التعليمية",
              status.selectedStudent!.studentDetailEntity.qualification,
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
                Expanded(child: Divider(height: 2, color: AppColors.accent70)),
              ],
            ),

            if (student.status == ActiveStatus.active) ...[
              SizedBox(height: 15),
              Text(
                "حلقة الطالب",
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  color: AppColors.lightCream70,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (halaqa.halaqaId != "0") ...{
                SizedBox(height: 12),
                StudyHalaqaCard(
                  onPress: _showAddStudentPlan,
                  assignedHalaqasEntity: halaqa,
                ),
              },

              SizedBox(height: 15),
              Text(
                "خطة التقدم",
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  color: AppColors.lightCream70,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (plan.details.isNotEmpty) ...{
                SizedBox(height: 12),
                StudyPlanCard(
                  onPress: _showAddStudentPlan,
                  planType: plan.frequency.labelAr,
                  planDetailList: plan.details,
                ),
              },
              SizedBox(height: 15),

              Text(
                "سجل المتابعة",
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  color: AppColors.lightCream70,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (halaqa.halaqaId != "0") ...{
                SizedBox(height: 12),
                AddTrakingSession(
                  assignedHalaqasEntity: halaqa,
                  onTap: () => _showStudentReports(context, student.name),
                ),
              },
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
                        style: GoogleFonts.cairo(color: AppColors.lightCream),
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
                        style: GoogleFonts.cairo(color: AppColors.lightCream),
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
  }

  // -->> إعادة كتابة جذرية لهذه الدالة <<--
  void _showStudentReports(BuildContext screenContext, String studentName) {
    showDialog(
      context: screenContext,
      builder: (_) {
        return BlocProvider(
          create: (context) =>
              sl<StudentBloc>()..add(FollowUpReportFetched(widget.studentID)),
          child: BlocBuilder<StudentBloc, StudentState>(
            builder: (dialogContext, state) {
              print("DIALOG: --- 3. BlocBuilder is rebuilding! ---");
              print(
                "DIALOG: Current followUpReportStatus is: ${state.followUpReportStatus}",
              );
              print(
                "DIALOG: Is followUpReport null? --> ${state.followUpReport == null}",
              );
              if (state.followUpReportStatus == FollowUpReportStatus.loading) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              if (state.followUpReportStatus == FollowUpReportStatus.success &&
                  state.followUpReport != null) {
                return FollowUpReportDialog(
                  studentName: studentName,
                  bundle: state.followUpReport!,
                );
              }

              if (state.followUpReportStatus == FollowUpReportStatus.failure) {
                return AlertDialog(
                  title: const Text('wrong'),
                  content: Text("Failed to load details"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        dialogContext.read<StudentBloc>().add(
                          FollowUpReportFetched(widget.studentID),
                        );
                      },
                      child: const Text('Try Again'),
                    ),
                  ],
                );
              }
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            },
          ),
        );
      },
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
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.black45,
              insetPadding: const EdgeInsets.all(10),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 9,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent12,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.accent70, width: 0.7),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.add, color: AppColors.lightCream),
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
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, StudentDetailEntity student) {
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
}
