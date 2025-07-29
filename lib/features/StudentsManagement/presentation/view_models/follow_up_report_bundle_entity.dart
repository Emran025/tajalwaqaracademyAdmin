
import 'follow_up_report_entity.dart';
import 'student_summary_entity.dart';

class FollowUpReportBundleEntity  {
  final List<FollowUpReportEntity> followUpReports;
  final StudentSummaryEntity summary;

  const FollowUpReportBundleEntity({
    required this.followUpReports,
    required this.summary,
  });

}