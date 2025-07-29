import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tajalwaqaracademy/core/constants/app_colors.dart';
import 'package:tajalwaqaracademy/core/constants/data.dart';
import 'package:tajalwaqaracademy/features/HalqasManagement/data/models/halqa.dart';
import 'package:tajalwaqaracademy/features/HalqasManagement/presentation/ui/screens/halqa_edit_screen.dart';

import 'package:tajalwaqaracademy/shared/widgets/avatar.dart';
import 'package:tajalwaqaracademy/shared/widgets/taj.dart';

import '../../../../../core/models/active_status.dart';
import '../../../../StudentsManagement/presentation/view_models/follow_up_report_bundle_entity.dart';
import '../../../../StudentsManagement/domain/entities/student_entity.dart';
import '../../../../StudentsManagement/domain/factories/follow_up_report_factory.dart';
import '../../../../StudentsManagement/presentation/ui/screens/follow_up_report_dialog.dart';

class HalqaProfileScreen extends StatefulWidget {
  const HalqaProfileScreen({super.key});
  @override
  State<HalqaProfileScreen> createState() => _HalqaProfileScreenState();
}

class _HalqaProfileScreenState extends State<HalqaProfileScreen>
    with TickerProviderStateMixin {
  DateTime selectedDate = DateTime.now();

  Halqa halqa = Halqa(
    "1",
    "حلقة كبار السن",
    "اليمن - اب",
    TimeOfDay.now(),
    "أ. خالد",
  );

  List<String> teachers = ["أ. خالد", "أ. سمير", "أ. فاطمة"];

  List<String> pastTeachers = ["أ. محمد", "أ. علي", "أ. يوسف"];
  List<String> graduates = ["حسن", "ريان", "وفاء"];
  List<String> hafidh = ["خالد", "حسين", "إيمان", "شيماء"];

  List<String> currStudents = ["علي", "هدى", "يوسف", "أميرة"];

  late List<StudentDetailEntity> prevStudents;

  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    prevStudents = fakeStudents;
    super.initState();
  }

  // Dialog list
  void _showListDialog(String title, List<String> items, String message) {
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.black45,
              insetPadding: EdgeInsets.all(10),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: EdgeInsets.all(10),
                  constraints: BoxConstraints(maxHeight: 450),
                  decoration: BoxDecoration(
                    color: AppColors.accent12,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.accent70, width: 0.7),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Text(
                          title,
                          style: GoogleFonts.cairo(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.lightCream,
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      Expanded(
                        child: items.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 24,
                                  ),
                                  child: Text(
                                    message,
                                    style: GoogleFonts.cairo(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              )
                            : Scrollbar(
                                thumbVisibility: true,
                                child: ListView.separated(
                                  // padding: EdgeInsets.symmetric(
                                  //   vertical: 5,
                                  // ),
                                  itemCount: items.length,
                                  separatorBuilder: (_, __) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    child: Divider(
                                      height: 1,
                                      color: AppColors.mediumDark87,
                                    ),
                                  ),
                                  itemBuilder: (_, i) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        items[i],
                                        style: GoogleFonts.cairo(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.lightCream,
                                        ),
                                      ),
                                      leading: Icon(
                                        Icons.check_circle_outline,
                                        color: AppColors.accent,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppColors.accent70),
                              ),
                              child: Text(
                                "اغلاق",
                                style: GoogleFonts.cairo(
                                  color: AppColors.lightCream,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _openStudentMenu(StudentDetailEntity student) {
    showModalBottomSheet(
      backgroundColor: AppColors.lightCream.withOpacity(0.1),
      // insetPadding: EdgeInsets.all(10),
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(10),
          constraints: BoxConstraints(maxHeight: 450),
          decoration: BoxDecoration(
            color: AppColors.accent12,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.accent70, width: 0.7),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.person_outlined),
                title: Text("عرض الملف الشخصي", style: GoogleFonts.cairo()),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.transfer_within_a_station_outlined),
                title: Text("نقله لحلقة أخرى", style: GoogleFonts.cairo()),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.remove_circle_outline),
                title: Text("فصله من الحلقة", style: GoogleFonts.cairo()),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    currStudents.add(student.name);
                    prevStudents.remove(student);
                    // student.stopReasons = "تم فصله.";
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPreviousReason(StudentDetailEntity student) {
    final isStopped = student.status == ActiveStatus.stopped;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: AppColors.lightCream.withOpacity(0.1),
              insetPadding: EdgeInsets.all(10),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: EdgeInsets.all(15),
                  constraints: BoxConstraints(maxHeight: 350),
                  decoration: BoxDecoration(
                    color: AppColors.lightCream.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.lightCream26),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Avatar(gender: student.gender, pic: student.avatar),
                          SizedBox(width: 12),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: Text(
                                "حالة الطالب : ${student.name} العامة",
                                style: GoogleFonts.cairo(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.lightCream,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Divider(color: AppColors.accent70),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isStopped ? Icons.block : Icons.check_circle,
                                  color: isStopped
                                      ? Colors.redAccent
                                      : Colors.green,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  isStopped ? "الحالة: متوقف" : "الحالة: نشط",
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    color: AppColors.lightCream,
                                  ),
                                ),
                              ],
                            ),
                            if (isStopped) ...[
                              SizedBox(height: 16),
                              Text(
                                "سبب التوقف:",
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.lightCream,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                student.stopReasons.trim().isEmpty
                                    ? "لا توجد تفاصيل."
                                    : student.stopReasons,
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppColors.accent70,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppColors.accent70),
                              ),
                              child: Text(
                                "اغلاق",
                                style: GoogleFonts.cairo(
                                  color: AppColors.lightCream,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabs() {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
                              dividerColor: Colors.black12,

          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.lightCream,
          indicatorColor: AppColors.accent,
          labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          tabs: [
            Tab(text: "الحاليين (${currStudents.length})"),
            Tab(text: "السابقين (${prevStudents.length})"),
          ],
        ),
        SizedBox(height: 12),

        Expanded(
          child: Center(
            child: TabBarView(
              
              controller: _tabController,
              children: [
                // Current students list
                ListView.separated(
                  itemCount: prevStudents.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    return _buildStudentCard(prevStudents[i], () {
                      _showStudentReports(prevStudents[i]);
                    });
                  },
                ),

                // Previous students list
                ListView.separated(
                  itemCount: prevStudents.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    return _buildStudentCard(prevStudents[i], () {
                      _showPreviousReason(prevStudents[i]);
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentCard(StudentDetailEntity student, void Function()? onPressed) {
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
        onTap: () => _openStudentMenu(student),
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
              onPressed: () => _openStudentMenu(student),
            ),
          ],
        ),
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
      builder: (_) => FollowUpReportDialog(
        studentName: student.name,
        bundle: reportBundle,
        ),
      
    //  StudentReports(name: student.name, report: logs),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Text(
          "ملف الحلقة",
          style: GoogleFonts.cairo(color: AppColors.lightCream),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                // Header glass card
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.lightCream.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.lightCream26),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  halqa.halqaName,
                                  style: GoogleFonts.cairo(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.lightCream,
                                  ),
                                ),
                                Text(
                                  halqa.country,
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.lightCream,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 14),
                          Row(
                            children: [
                              Icon(Icons.person, color: AppColors.accent),
                              SizedBox(width: 8),
                              Text(
                                halqa.teacher,
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.lightCream,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 14),
                          Wrap(
                            spacing: 12,
                            children: [
                              GestureDetector(
                                onTap: () => _showListDialog(
                                  "المعلمين السابقين",
                                  pastTeachers,
                                  "لا يوجد معلمين في هذه الحلقة بعد",
                                ),
                                child: Chip(
                                  label: Text(
                                    " سجل المعلمين: ${pastTeachers.length}",
                                    style: GoogleFonts.cairo(
                                      color: AppColors.lightCream,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  backgroundColor: AppColors.mediumDark87,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _showListDialog(
                                  "الخريجين الحفاظ",
                                  hafidh,
                                  "لا يوجد خريجين من هذه الحلقة بعد",
                                ),
                                child: Chip(
                                  label: Text(
                                    " الحفاظ: ${hafidh.length}",
                                    style: GoogleFonts.cairo(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.lightCream,
                                    ),
                                  ),
                                  backgroundColor: AppColors.mediumDark87,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: AppColors.lightCream,
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => HalqaEditScreen(),
                                    ),
                                  );
                                },
                                // onPressed: _showEditOptions,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Expanded(child: _buildTabs()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
