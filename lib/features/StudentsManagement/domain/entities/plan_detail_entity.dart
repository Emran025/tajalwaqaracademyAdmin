import 'package:tajalwaqaracademy/core/models/tracking_units.dart';

import '../../../../core/models/tracking_type.dart';

class PlanDetailEntity {
  final TrackingType type;
  final TrackingUnit unit;
  final int amount;

  const PlanDetailEntity({
    required this.type,
    required this.unit,
    required this.amount,
  });
}
