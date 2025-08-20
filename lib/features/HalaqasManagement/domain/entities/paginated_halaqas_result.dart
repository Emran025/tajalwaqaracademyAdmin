import 'package:tajalwaqaracademy/features/HalaqasManagement/data/models/halaqa_model.dart';

/// A wrapper class to hold the list of halaqas and pagination metadata.
import 'package:flutter/material.dart';

@immutable
class PaginatedHalaqasResult {
  final List<HalaqaModel> halaqas;
  final bool hasMorePages;

  const PaginatedHalaqasResult({
    required this.halaqas,
    required this.hasMorePages,
  });
}
