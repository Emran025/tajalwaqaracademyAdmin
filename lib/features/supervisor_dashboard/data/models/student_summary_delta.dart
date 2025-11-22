// دلتا لتحديث الجدول الملخص

import '../../../../core/models/user_role.dart';

class SummaryDelta {
  final DateTime date;
  final UserRole entityType;
  final int activeCount;
  final int additions;
  final int deletions;

  SummaryDelta({
    required this.date,
    required this.entityType,
    required this.activeCount,
    required this.additions,
    required this.deletions,
  });

  factory SummaryDelta.fromMap(Map<String, dynamic> map) {
    return SummaryDelta(
      date: _parseDate(map['date']),
      entityType: UserRole.fromId(map['entity_type'] as int? ?? 0),
      activeCount: (map['active_count'] as int?) ?? 0,
      additions: (map['additions_count'] as int?) ?? 0,
      deletions: (map['deletions_count'] as int?) ?? 0,
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
      'active_count': activeCount,
      'entity_type': entityType.id,
      'additions_count': additions,
      'deletions_count': deletions,
      'last_updated': DateTime.now().millisecondsSinceEpoch,
    };
  }

  @override
  String toString() {
    return 'StudentSummaryDelta(date: $date, activeCount: $activeCount,  entityType: $entityType, additions: $additions, deletions: $deletions)';
  }
}