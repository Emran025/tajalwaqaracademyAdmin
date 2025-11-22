import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../config/di/injection.dart';
import '../../../../../core/models/active_status.dart';
import '../../../../../core/models/report_frequency.dart';
import '../../../../../shared/themes/app_theme.dart';
import '../../../../../shared/widgets/avatar.dart';
import '../../../../../shared/widgets/caerd_tile.dart';
import '../../../domain/entities/student_list_item_entity.dart';
import '../../bloc/student_bloc.dart';
import '../screens/student_profile_screen.dart';
import 'show_student_reports_dialog.dart';

class StudentListCardWithOptions extends StatefulWidget {
  final ActiveStatus? status;
  final int? halaqaId;
  final DateTime? trackDate;
  final Frequency? frequencyCode;
  const StudentListCardWithOptions({
    super.key,
    this.status,
    this.halaqaId,
    this.trackDate,
    this.frequencyCode,
  });

  @override
  State<StudentListCardWithOptions> createState() =>
      _StudentListCardWithOptionsState();
}

class _StudentListCardWithOptionsState
    extends State<StudentListCardWithOptions> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<StudentBloc>()
        ..add(
          FilteredStudents(
            status: widget.status,
            halaqaId: widget.halaqaId,
            trackDate: widget.trackDate,
            frequencyCode: widget.frequencyCode,
          ),
        ),

      child: BlocBuilder<StudentBloc, StudentState>(
        builder: (context, state) {
          if (state.status == StudentStatus.loading && state.students.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == StudentStatus.failure && state.students.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: state.failure?.message'),
                  ElevatedButton(
                    onPressed: () => context.read<StudentBloc>().add(
                      const StudentsRefreshed(),
                    ),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }
          if (state.status == StudentStatus.success && state.students.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                if (state.status == StudentStatus.success &&
                    state.hasMorePages &&
                    !state.isLoadingMore) {
                  context.read<StudentBloc>().add(const StudentsRefreshed());
                }
              },
              child: const Center(child: Text('No students found.')),
            );
          }
          final filteredStudents = state.students;
          // .where(
          //   (t) => (status == ActiveStatus.unknown
          //       ? t.status == t.status
          //       : t.status == status),
          // )
          // .toList();
          return RefreshIndicator(
            onRefresh: () async {
              context.read<StudentBloc>().add(const StudentsRefreshed());
              // The refresh completes when the BLoC emits a new state.
            },
            child: ListView.separated(
              separatorBuilder: (_, __) => const SizedBox(height: 5),
              controller: _scrollController, // Controller for "load more"
              itemCount:
                  filteredStudents.length + (state.isLoadingMore ? 1 : 0),
              itemBuilder: (ctx, i) {
                if (i >= filteredStudents.length) {
                  // "Load More" indicator
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return CustomListTile(
                  title: filteredStudents[i].name,
                  moreIcon: Icons.more_vert,
                  leading: Avatar(),
                  subtitle: filteredStudents[i].status.labelAr,
                  backgroundColor: AppColors.accent12,
                  border: Border.all(color: AppColors.accent70, width: 0.5),
                  onMoreTab: () => _openStudentMenu(filteredStudents[i]),
                  onListTilePressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => StudentProfileScreen(
                          studentID: filteredStudents[i].id,
                        ),
                      ),
                    );
                  },
                  onTajPressed: () {
                    filteredStudents[i].status == ActiveStatus.active
                        ? _showStudentReports(
                            context,
                            filteredStudents[i].name,
                            filteredStudents[i].id,
                          )
                        : _showPreviousReason(filteredStudents[i]);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showStudentReports(
    BuildContext screenContext,
    String studentName,
    String studentId,
  ) {
    showDialog(
      context: screenContext,
      builder: (_) {
        return ShowStudentReportsDialog(
          studentId: studentId,
          studentName: studentName,
        );
      },
    );
  }

  void _openStudentMenu(StudentListItemEntity student) {
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
              _simpleListTile(
                Icons.transfer_within_a_station_outlined,
                "نقله إلى حلقة أخرى",
                () {
                  Navigator.pop(context);
                },
              ),
              _simpleListTile(Icons.person_outlined, "عرض ملفه الشخصي", () {
                Navigator.pop(context);
              }),
              _simpleListTile(
                Icons.remove_circle_outline,
                "اتخاذ إجراء معه",
                () {
                  Navigator.pop(context);
                  _showStudentActionDialog(student);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStudentActionDialog(StudentListItemEntity student) {
    String action = "";
    TextEditingController noteCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: AppColors.lightCream.withOpacity(0.1),
            insetPadding: EdgeInsets.all(10),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accent12,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.accent70, width: 0.7),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "إدارة الطالب",
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightCream,
                      ),
                    ),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ["نقل", "فصل", "إيقاف"].map((action1) {
                        final isSelected = action == action1;
                        return ChoiceChip(
                          label: Text(
                            action1,
                            style: GoogleFonts.cairo(
                              color: isSelected
                                  ? AppColors.lightCream
                                  : AppColors.mediumDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.accent,
                          backgroundColor: AppColors.accent70.withOpacity(0.3),
                          onSelected: (_) =>
                              setStateDialog(() => action = action1),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: StadiumBorder(
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.accent
                                  : AppColors.lightCream26,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: noteCtrl,
                      minLines: 2,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "أضف ملاحظة (اختياري)",
                        hintStyle: GoogleFonts.cairo(
                          color: AppColors.lightCream70,
                        ),
                        filled: true,
                        fillColor: AppColors.lightCream12,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: GoogleFonts.cairo(color: AppColors.lightCream),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppColors.accent70),
                            ),
                            child: Text(
                              "إلغاء",
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
                              backgroundColor: AppColors.accent,
                            ),
                            onPressed: () {
                              if (action == "نقل") {
                                setState(() {
                                  // currentStudents.remove(student);
                                  // add to previous + note
                                });
                              } else if (action == "فصل" || action == "إيقاف") {
                                setState(() {
                                  // stoppedStatus[student] = true;
                                });
                              }
                              Navigator.pop(context);
                            },
                            child: Text(
                              "تنفيذ",
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
          );
        },
      ),
    );
  }

  void _showPreviousReason(StudentListItemEntity student) {
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
                                student.stopReasons ?? "لا توجد تفاصيل.",
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

  Widget _simpleListTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).brightness != Brightness.dark
              ? Theme.of(context).colorScheme.surface
              : AppColors.lightCream,
        ),
      ),
      onTap: () => onTap(),
    );
  }
}
