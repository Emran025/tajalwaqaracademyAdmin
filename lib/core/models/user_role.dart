// lib/domain/entities/enums.dart

/// Represents user roles in the system.
enum UserRole {
  powerAdmin(1, "Power Admin"),
  supervisor(2, "Supervisor"),
  teacher(3, "Teacher"),
  student(4, "Student"),
  unknown(0, "Unknown");

  final int id;
  final String label;
  const UserRole(this.id, this.label);

  static UserRole fromId(int id) {
    return UserRole.values.firstWhere((e) => e.id == id, orElse: () => unknown);
  }

  static UserRole fromLabel(String label) {
    switch (label.toLowerCase()) {
      case 'power admin':
      case 'مدير عام':
        return UserRole.powerAdmin;
      case 'supervisor':
      case 'مشرف':
        return UserRole.supervisor;
      case 'teacher':
      case 'معلم':
        return UserRole.teacher;
      case 'student':
      case 'طالب':
        return UserRole.student;
      default:
        return UserRole.unknown;
    }
  }
}
