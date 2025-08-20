enum Frequency {
  daily(1, 'يوميًا', "daily"),
  onceAWeek(2, 'أسبوعيًا', "onceAWeek"),
  twiceAWeek(3, 'مرتين بالأسبوع', "twiceAWeek"),
  thriceAWeek(4, 'ثلاث مرات بالأسبوع', "thriceAWeek");

  final int id;
  final String labelAr;
  final String label;
  const Frequency(this.id, this.labelAr, this.label);

  static Frequency fromId(int id) {
    return Frequency.values.firstWhere((e) => e.id == id, orElse: () => daily);
  }

  static Frequency fromLabel(String label) {
    switch (label.toLowerCase()) {
      case 'onceAWeek':
      case 'مرة بالأسبوع':
      case 'أسبوعيًا':
        return Frequency.onceAWeek;
      case 'twiceAWeek':
      case 'مرتين بالأسبوع':
        return Frequency.twiceAWeek;
      case 'thriceAWeek':
      case 'ثلاث مرات بالأسبوع':
        return Frequency.thriceAWeek;
      default:
        return Frequency.daily;
    }
  }
}
