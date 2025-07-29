import 'package:tajalwaqaracademy/features/StudentsManagement/presentation/view_models/actual_progress_entity.dart';
import 'package:tajalwaqaracademy/features/StudentsManagement/presentation/view_models/planned_detail_entity.dart';

import '../../../../core/models/tracking_type.dart';

class FollowUpReportDetailEntity {
  final TrackingType type;
  final PlannedDetailEntity plannedDetail;
  final ActualProgressEntity actual;
  final double gap;
  final double performanceScore;
  final String note;

  const FollowUpReportDetailEntity({
    required this.type,
    required this.plannedDetail,
    required this.actual,
    required this.gap,
    required this.performanceScore,
    required this.note,
  });

}