// import 'package:flutter/material.dart';

import 'base_halaqa_entity.dart';

import 'package:flutter/material.dart';

/// Represents the full, detailed profile of a single halaqa.
///
/// This entity includes all available information for a halaqa, used when
/// viewing a specific halaqa's profile. It inherits core properties and
/// adds detailed fields.

@immutable
class HalaqaDetailEntity extends BaseHalaqaEntity {
  final int teacherId;

  final int sumOfStudents;
  final int maxOfStudents;
  final String createdAt;
  final String updatedAt;

  const HalaqaDetailEntity({
    required super.id,
    required super.name,
    required super.avatar,
    required super.status,
    required super.gender,
    required this.teacherId,
    required super.country,

    required super.residence,
    required this.sumOfStudents,
    required this.maxOfStudents,

    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    ...super.props,
    teacherId,
    sumOfStudents,
    maxOfStudents,
    createdAt,
    updatedAt,
  ];
}
