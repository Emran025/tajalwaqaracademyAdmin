enum ActiveStatus {
  active(1, 'نشط', "Active"),
  inactive(2, 'غير نشط', "Inactive"),
  pending(3, 'معلق', "Pending"),
  stopped(4, 'متوقف', "Stopped"),
    unknown(0,'UN', "Unknown"),

  waiteing(5, 'بانتظار', "Waiteing");

  final int id;
  final String labelAr;
  final String label;
  const ActiveStatus(this.id, this.labelAr, this.label);

  static ActiveStatus fromId(int id) {
    return ActiveStatus.values.firstWhere(
      (e) => e.id == id,
      orElse: () => inactive,
    );
  }

  static ActiveStatus fromLabel(String label) {
    switch (label.toLowerCase()) {
      case 'نشط':
      case 'active':
        return ActiveStatus.active;
      case 'غير نشط':
      case 'inactive':
        return ActiveStatus.inactive;
      case 'معلق':
      case 'pending':
        return ActiveStatus.pending;
      case 'متوقف':
      case 'stopped':
        return ActiveStatus.pending;
      default:
        return ActiveStatus.waiteing;
    }
  }
}



