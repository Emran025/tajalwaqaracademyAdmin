
enum AttendanceType {

  present('حاضر', 'present'),
  absent('غائب', 'absent'),
  other('UN', 'UN');

  final String labelAr;
  final String label;
  const AttendanceType(this.labelAr, this.label);
  static AttendanceType fromLabel(String label) {
    switch (label.toLowerCase()) {
      case 'حاضر':
      case 'present':
        return AttendanceType.present;
      case 'غائب':
      case 'absent':
        return AttendanceType.absent;
      default:
        return AttendanceType.other;
    }
  }
}
