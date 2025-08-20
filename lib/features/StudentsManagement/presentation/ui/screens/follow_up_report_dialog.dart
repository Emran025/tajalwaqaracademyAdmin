import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tajalwaqaracademy/features/StudentsManagement/presentation/ui/widgets/daily_details_dialog.dart';
import 'package:tajalwaqaracademy/shared/widgets/taj.dart';

import 'package:tajalwaqaracademy/shared/themes/app_theme.dart';
import '../../../../../shared/func/date_format.dart';
import '../../view_models/follow_up_report_bundle_entity.dart';
import '../../view_models/follow_up_report_entity.dart';
import '../../view_models/student_performance_metrics_entity.dart';
import '../../view_models/student_summary_entity.dart';

/// A professional, read-only dialog for displaying a student's complete follow-up report.
///
/// This widget is designed to be highly performant and clean. It expects a fully
/// processed [FollowUpReportBundleEntity] and is only responsible for rendering
/// the data, not calculating it.
class FollowUpReportDialog extends StatefulWidget {
  final String studentName;
  final FollowUpReportBundleEntity bundle;
  const FollowUpReportDialog({
    super.key,
    required this.studentName,
    required this.bundle,
  });

  @override
  State<FollowUpReportDialog> createState() => _FollowUpReportDialogState();
}

class _FollowUpReportDialogState extends State<FollowUpReportDialog> {
  /// The list of reports, sorted once for performance.
  late final List<FollowUpReportEntity> _sortedReports;

  @override
  void initState() {
    super.initState();
    // Sort the list of reports by date ONCE when the widget is initialized.
    // This is much more efficient than sorting inside the build method.
    _sortedReports = List.from(widget.bundle.followUpReports)
      ..sort((a, b) => b.trackDate.compareTo(a.trackDate));
  }

  void _showDailyDetails(FollowUpReportEntity report) {
    showDialog(
      context: context,
      builder: (context) => DailyDetailsDialog(report: report),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Access the summary and performance metrics directly from the bundle.
    final summary = widget.bundle.summary;
    final performance = summary.studentPerformance;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.black45,
        insetPadding: const EdgeInsets.all(10),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(maxHeight: 600),
            decoration: BoxDecoration(
              color: AppColors.accent12,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.accent70, width: 0.7),
            ),
            child: Column(
              children: [
                // --- 1. Summary Header (Data comes directly from the bundle) ---
                _buildSummaryHeader(performance, summary),

                const Divider(height: 2, color: AppColors.accent70),

                Flexible(
                  child: Scrollbar(
                    thickness: 2,
                    child: ListView.separated(
                      padding: const EdgeInsets.only(left: 10, top: 8),
                      itemCount: _sortedReports.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (_, index) {
                        final report = _sortedReports[index];
                        return (report.attendance == AttendanceStatus.present)
                            ? _buildDailyReportCard(report)
                            : SizedBox(height: 0);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // --- 3. Close Button ---
                _buildCloseButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the top summary section of the dialog.
  Widget _buildSummaryHeader(
    StudentPerformanceMetricsEntity performance,
    StudentSummaryEntity summary,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.studentName,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightCream,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "متوسط الإنجاز: ${performance.averageAchievementRate.toStringAsFixed(1)}٪",
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: AppColors.lightCream70,
                ),
              ),
              Text(
                "متوسط الجودة: ${performance.averageExecutionQuality.toStringAsFixed(1)} / 5",
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: AppColors.lightCream70,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "إجمالي التقارير: ${performance.reportCount}",
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: AppColors.lightCream70,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "الانحراف الكلي: ${summary.totalDeviation.toStringAsFixed(1)} صفحات",
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: AppColors.lightCream70,
                ),
              ),
              if (_sortedReports.isNotEmpty)
                Text(
                  "آخر تقرير: ${formatDate(_sortedReports.first.trackDate)}",
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: AppColors.lightCream70,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the card for a single day's report.
  Widget _buildDailyReportCard(FollowUpReportEntity report) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "📅 ${formatDate(report.trackDate)}",
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightCream87,
                ),
              ),

              InkWell(
                onTap: () => _showDailyDetails(report),

                child: StatusTag(lable: "تفاصـــيل", fontSize: 10, radius: 8),
              ),
              // Text(
              //   "تقييم السلوك: ${report.behaviourAssessment.toStringAsFixed(1)} / 5",
              //   style: GoogleFonts.cairo(
              //     fontSize: 12,
              //     color: AppColors.lightCream70,
              //   ),
              // ),
            ],
          ),
          const SizedBox(height: 8),

          _buildDetailsTable(report),
        ],
      ),
    );
  }

  /// Builds the table with performance details for a single day.
  Widget _buildDetailsTable(FollowUpReportEntity report) {
    return Table(
      defaultColumnWidth: const FlexColumnWidth(),
      border: TableBorder.all(
        color: AppColors.accent70,
        width: 0.5,
        borderRadius: BorderRadius.circular(10),
      ),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: const {
        0: FlexColumnWidth(2.2),
        1: FlexColumnWidth(1.8),
        2: FlexColumnWidth(1.5),
        3: FlexColumnWidth(1.5),
        4: FlexColumnWidth(1.5),
      },
      children: [
        TableRow(
          decoration: const BoxDecoration(
            color: AppColors.accent26,
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
          ),
          children: [
            _buildTableHeader("النوع"),
            _buildTableHeader("المخطط"),
            _buildTableHeader("الفعلي"),
            _buildTableHeader("الفجوة"),
            _buildTableHeader("الجودة"),
          ],
        ),
        ...report.details.map((detail) {
          // The actual amount can be derived from the plan and the gap
          final actualAmount = detail.plannedDetail.amount + detail.gap;
          return TableRow(
            children: [
              _buildTableCell(detail.type.labelAr),
              _buildTableCell(
                "${detail.plannedDetail.amount} ${detail.plannedDetail.unit.labelAr}",
              ),
              _buildTableCell(actualAmount.toStringAsFixed(1)),
              _buildGapCell(detail.gap), // Special cell for the gap
              _buildTableCell(detail.performanceScore.toStringAsFixed(1)),
            ],
          );
        }),
      ],
    );
  }

  /// Builds the close button at the bottom.
  Widget _buildCloseButton() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.accent70),
            ),
            child: Text(
              "إغلاق",
              style: GoogleFonts.cairo(color: AppColors.lightCream),
            ),
          ),
        ),
      ],
    );
  }

  // --- Helper Widgets & Functions ---

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.lightCream70,
        ),
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.cairo(fontSize: 12, color: AppColors.lightCream),
      ),
    );
  }

  /// A special cell that colors the gap value based on whether it's positive or negative.
  Widget _buildGapCell(double gap) {
    final Color color;
    final String sign;
    if (gap > 0) {
      color = Colors.greenAccent;
      sign = '+';
    } else if (gap < 0) {
      color = Colors.redAccent;
      sign = ''; // Negative sign is already there
    } else {
      color = AppColors.lightCream;
      sign = '';
    }
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        "$sign${gap.toStringAsFixed(1)}",
        textAlign: TextAlign.center,
        style: GoogleFonts.cairo(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// import 'path/to/your/tracking_unit_detail.dart';
