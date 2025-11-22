// دلتا لتحديث الجدول الملخص

import '../../../../core/models/user_role.dart';
import '../../domain/entities/counts_delta_entity.dart';

class CountsDelta {
  CountDelta studentCount;
  CountDelta halaqaCount;
  CountDelta teacherCount;
  CountsDelta({
    required this.studentCount,
    required this.halaqaCount,
    required this.teacherCount,
  });

  CountsDeltaEntity toEntity() {
    return CountsDeltaEntity(
      studentCount: studentCount.toEntity(),
      halaqaCount: halaqaCount.toEntity(),
      teacherCount: teacherCount.toEntity(),
    );
  }
}

class CountDelta {
  final DateTime date;
  final UserRole entityType;
  final int count;

  CountDelta({
    required this.date,
    required this.entityType,
    required this.count,
  });

  factory CountDelta.fromMap(Map<String, dynamic> map) {
    return CountDelta(
      date: _parseDate(map['date']),
      entityType: UserRole.fromId(map['entity_type'] as int? ?? 0),
      count: (map['count'] as int?) ?? 0,
    );
  }

  // دالة مساعدة لتحويل التاريخ
  static DateTime _parseDate(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();

    if (dateValue is DateTime) return dateValue;
    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        // إذا فشل التحويل، حاول تحويل التنسيق YYYY-MM-DD
        if (dateValue.contains('-')) {
          return DateTime.parse('${dateValue}T00:00:00Z');
        }
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  // دالة موحدة لإنشاء خريطة (للـ API والـ DB)
  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String().split('T').first,
      'entity_type': entityType.id,
      'count': count,
      'last_updated': DateTime.now().millisecondsSinceEpoch,
    };
  }

  @override
  String toString() {
    return 'StudentCountDelta(date: $date, count: $count,  entityType: $entityType)';
  }

  CountDeltaEntity toEntity() {
    return CountDeltaEntity(date: date, entityType: entityType, count: count);
  }
}
