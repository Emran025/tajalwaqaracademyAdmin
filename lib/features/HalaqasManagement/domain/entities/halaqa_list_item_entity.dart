import 'base_halaqa_entity.dart';

/// Represents a halaqa as displayed in a list.
///
/// This entity contains a minimal set of data required for a summary view,
/// optimizing performance by not loading unnecessary details for lists.
/// It inherits core properties from [BaseHalaqaDetailEntity].
import 'package:flutter/material.dart';

@immutable
class HalaqaListItemEntity extends BaseHalaqaEntity {
  const HalaqaListItemEntity({
    required super.id,
    required super.name,
    required super.gender,
    required super.avatar,
    required super.country,
    required super.city,
    required super.status,
  });
}
