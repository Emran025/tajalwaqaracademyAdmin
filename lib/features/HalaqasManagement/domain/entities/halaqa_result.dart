import 'package:tajalwaqaracademy/features/HalaqasManagement/domain/entities/halaqa_list_item_entity.dart';
import 'package:flutter/material.dart';

@immutable
class HalaqaResult {
  final List<HalaqaListItemEntity> halaqas;
  final bool hasMorePages;

  const HalaqaResult({required this.halaqas, required this.hasMorePages});
}
