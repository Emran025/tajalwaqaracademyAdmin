import '../../../../core/entities/tracking_unit.dart';
import '../../../../core/models/tracking_units.dart';

class ActualProgressEntity {
  final TrackingUnit unit;
  final TrackingUnitDetail fromTrackingUnitId; 
  final TrackingUnitDetail toTrackingUnitId;
  const ActualProgressEntity({required this.unit,required this.fromTrackingUnitId,required this.toTrackingUnitId});
}
