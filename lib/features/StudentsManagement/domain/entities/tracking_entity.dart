
import 'tracking_detail_entity.dart';

class TrackingEntity {
  final String id;
  final String planId;
  final DateTime date;
  final String note;
  final int behaviorNote;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  /// A list of detailed tracking items associated with this daily record.
  final List<TrackingDetailEntity> details;

  TrackingEntity({
    required this.id,
    required this.planId,
    required this.date,
    required this.note,
    required this.behaviorNote,
    required this.createdAt,
    required this.updatedAt,
    required this.details,
  });

}

