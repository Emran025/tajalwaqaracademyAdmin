enum Gender {
  male('ذكر', 'Male'),
  female('أنثى', 'Female'),
  other('UN', 'UN');

  final String labelAr;
  final String label;
  const Gender(this.labelAr, this.label);
  static Gender fromLabel(String label) {
    switch (label.toLowerCase()) {
      case 'male':
      case 'ذكر':
        return Gender.male;
      case 'female':
      case 'أنثى':
        return Gender.female;
      default:
        return Gender.other;
    }
  }
}
