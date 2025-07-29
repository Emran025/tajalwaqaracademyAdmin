import 'follow_up_report_detail_entity.dart';

// enum لحالة الحضور
enum AttendanceStatus { present, absent }

class FollowUpReportEntity  {
  final int id;
  final DateTime trackDate;
  final AttendanceStatus attendance;
  final double behaviourAssessment;
  final List<FollowUpReportDetailEntity> details;

  const FollowUpReportEntity({
    required this.id,
    required this.trackDate,
    required this.attendance,
    required this.behaviourAssessment,
    required this.details,
  });

}