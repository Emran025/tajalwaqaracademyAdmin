import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tajalwaqaracademy/shared/themes/app_theme.dart';
import 'package:tajalwaqaracademy/core/entities/tracking_unit.dart';
import 'package:tajalwaqaracademy/features/StudentsManagement/presentation/view_models/follow_up_report_detail_entity.dart';
import 'package:tajalwaqaracademy/features/StudentsManagement/presentation/view_models/follow_up_report_entity.dart';
import 'package:tajalwaqaracademy/shared/func/date_format.dart';

class DailyDetailsDialog extends StatelessWidget {
  final FollowUpReportEntity report;

  const DailyDetailsDialog({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.black45,
        insetPadding: const EdgeInsets.all(10),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accent12,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.accent70, width: 0.7),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "تفاصيل يوم: ${formatDate(report.trackDate)}",
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightCream,
                  ),
                ),
                const Divider(height: 20, color: AppColors.accent70),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: report.details.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 20, color: AppColors.accent26),
                    itemBuilder: (_, index) {
                      final detail = report.details[index];
                      return _buildDetailItem(detail);
                    },
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
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
            ),
          ),
        ),
      ),
    );
  }

  /// يبني عرضًا لبند تفصيلي واحد (مثل الحفظ أو المراجعة).
  Widget _buildDetailItem(FollowUpReportDetailEntity detail) {
    final fromDetail = detail.actual.fromTrackingUnitId;
    final toDetail = detail.actual.toTrackingUnitId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان النوع (حفظ، مراجعة)
        Text(
          detail.type.labelAr,
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.lightCream,
          ),
        ),
        const SizedBox(height: 8),
        // جدول صغير للتفاصيل
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildDetailColumn("من", fromDetail)),
            const VerticalDivider(color: AppColors.accent70),
            Expanded(child: _buildDetailColumn("إلى", toDetail)),
          ],
        ),
        // عرض الملاحظات إن وجدت
        if (detail.note.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            "ملاحظات: ${detail.note}",
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: AppColors.lightCream70,
            ),
          ),
        ],
      ],
    );
  }

  /// يبني عمودًا لعرض تفاصيل "من" أو "إلى".
  Widget _buildDetailColumn(String header, TrackingUnitDetail detail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          header,
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.lightCream70,
          ),
        ),
        _buildDetailRow("السورة:", detail.fromSurah),
        _buildDetailRow("الصفحة:", detail.fromPage.toString()),
        _buildDetailRow("الآية:", detail.fromAyah.toString()),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, right: 8),
      child: Text(
        "$label $value",
        style: GoogleFonts.cairo(fontSize: 13, color: AppColors.lightCream),
      ),
    );
  }
}
