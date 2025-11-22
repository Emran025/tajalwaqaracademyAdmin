import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../config/di/injection.dart';
import '../../../../../core/constants/data.dart';
import '../../../../../core/models/active_status.dart';
import '../../../../../core/models/report_frequency.dart';
import '../../../../../shared/themes/app_theme.dart';
import '../../../../../shared/widgets/avatar.dart';
import '../../../../../shared/widgets/caerd_tile.dart';
import '../../../../../shared/widgets/taj.dart';
import '../../../../StudentsManagement/domain/entities/student_entity.dart';
import '../../../../StudentsManagement/presentation/ui/screens/follow_up_report_dialog.dart';
import '../../../../StudentsManagement/presentation/view_models/factories/follow_up_report_factory.dart';
import '../../../../StudentsManagement/presentation/view_models/follow_up_report_bundle_entity.dart';
import '../../../domain/entities/halaqa_list_item_entity.dart';
import '../../bloc/halaqa_bloc.dart';
import '../screens/halaqa_profile_screen.dart';

class HalaqaListCardWithOptions extends StatefulWidget {
  final ActiveStatus? status;
  final int? halaqaId;
  final DateTime? trackDate;
  final Frequency? frequencyCode;
  const HalaqaListCardWithOptions({
    super.key,
    this.status,
    this.halaqaId,
    this.trackDate,
    this.frequencyCode,
  });

  @override
  State<HalaqaListCardWithOptions> createState() =>
      _HalaqaListCardWithOptionsState();
}

class _HalaqaListCardWithOptionsState
    extends State<HalaqaListCardWithOptions> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<HalaqaBloc>()
        ..add(
          FilteredHalaqas(
            status: widget.status,
            trackDate: widget.trackDate,
            frequencyCode: widget.frequencyCode,
          ),
        ),

      child: BlocBuilder<HalaqaBloc, HalaqaState>(
        builder: (context, state) {
          if (state.status == HalaqaStatus.loading && state.halaqas.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == HalaqaStatus.failure && state.halaqas.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: state.failure?.message'),
                  ElevatedButton(
                    onPressed: () => context.read<HalaqaBloc>().add(
                      const HalaqasRefreshed(),
                    ),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }
          if (state.status == HalaqaStatus.success && state.halaqas.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                if (state.status == HalaqaStatus.success &&
                    state.hasMorePages &&
                    !state.isLoadingMore) {
                  context.read<HalaqaBloc>().add(const HalaqasRefreshed());
                }
              },
              child: const Center(child: Text('No students found.')),
            );
          }
          final filteredHalaqas = state.halaqas;
          // .where(
          //   (t) => (status == ActiveStatus.unknown
          //       ? t.status == t.status
          //       : t.status == status),
          // )
          // .toList();
          return RefreshIndicator(
            onRefresh: () async {
              context.read<HalaqaBloc>().add(const HalaqasRefreshed());
              // The refresh completes when the BLoC emits a new state.
            },
            child: ListView.separated(
              separatorBuilder: (_, __) => const SizedBox(height: 5),
              controller: _scrollController, // Controller for "load more"
              itemCount:
                  filteredHalaqas.length + (state.isLoadingMore ? 1 : 0),
              itemBuilder: (ctx, i) {
                if (i >= filteredHalaqas.length) {
                  // "Load More" indicator
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return CustomListTile(
                  title: filteredHalaqas[i].name,
                  moreIcon: Icons.more_vert,
                  leading: Avatar(),
                  subtitle: filteredHalaqas[i].status.labelAr,
                  backgroundColor: AppColors.accent12,
                  border: Border.all(color: AppColors.accent70, width: 0.5),
                  onMoreTab: () => _openHalaqaMenu(filteredHalaqas[i]),
                  onListTilePressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => HalaqaProfileScreen(
                          halaqaId: filteredHalaqas[i].id,
                        ),
                      ),
                    );
                  },
                  onTajPressed: () {
                    filteredHalaqas[i].status == ActiveStatus.active
                        ? _showHalaqaReports(
                           
                            filteredHalaqas[i],
                          )
                        : _showPreviousReason(filteredHalaqas[i]);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }



    void _showHalaqaReports(HalaqaListItemEntity halqa) {
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
                            halqa.name,
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
                                  builder: (context) => HalaqaProfileScreen(
                                    halaqaId: students[index].id,
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


  void _openHalaqaMenu(HalaqaListItemEntity student) {
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
                  _showHalaqaActionDialog(student);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHalaqaActionDialog(HalaqaListItemEntity student) {
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
                                  // currentHalaqas.remove(student);
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

  void _showPreviousReason(HalaqaListItemEntity student) {
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
                                 "لا توجد تفاصيل.",
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

}
