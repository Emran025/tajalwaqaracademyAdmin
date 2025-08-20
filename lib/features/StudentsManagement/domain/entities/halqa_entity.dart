import 'package:flutter/foundation.dart';

@immutable
class AssignedHalaqasEntity {
  final String id;
  final String name;
  final String avatar;
  final String enrolledAt;
  final String? enrollmentId;
  final String studentId;
  final String halaqaId;

  const AssignedHalaqasEntity({
    this.id = '0',
    this.enrollmentId = '0',

    this.halaqaId = "0",
    this.name = 'النور',
    this.avatar = 'assets/images/logo2.png',
    this.enrolledAt = '2025-07-08 22:21:36',
    this.studentId = "0",
  });
  const AssignedHalaqasEntity.empty()
    : id = '0',
      enrollmentId = '0',
      name = 'النور',
      avatar = 'assets/images/logo2.png',
      enrolledAt = '2025-07-08 22:21:36',
      halaqaId = '0',
      studentId = "0";
}
