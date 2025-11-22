// دلتا لتحديث الجدول الملخص


import '../../../../core/models/user_role.dart';

class CountsDeltaEntity {
  CountDeltaEntity studentCount;
  CountDeltaEntity halaqaCount;
  CountDeltaEntity teacherCount;
  CountsDeltaEntity({
    required this.studentCount,
    required this.halaqaCount,
    required this.teacherCount,
  });
}


class CountDeltaEntity {
  final DateTime date;
  final UserRole entityType;
  final int count;

  CountDeltaEntity({
    required this.date,
    required this.entityType,
    required this.count,
  });
}