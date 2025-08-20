
enum AttendanceType {

  present(1 , 'حاضر', 'present'),
  absent(2 , 'غائب', 'absent'),
  other( 3, 'UN', 'UN');

  final int id;
  final String labelAr;
  final String label;
  const AttendanceType( this.id,  this.labelAr, this.label);
  static AttendanceType fromId(int id) {
    return AttendanceType.values.firstWhere((e) => e.id == id, orElse: () => absent);
  }  static AttendanceType fromLabel(String label) {
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
