enum Gender {
  male(1, 'ذكر', 'Male'),
  female(2, 'أنثى', 'Female'),
  both(3, 'الجنسين', 'Both');

  final int id;
  final String labelAr;
  final String label;
  const Gender(this.id, this.labelAr, this.label);

  /// A utility method to find a [MistakeType] by its integer ID.
  ///
  /// This is useful when retrieving data from the database.
  /// Defaults to [Gender.none] if the id is not found.
  static Gender fromId(int id) {
    return Gender.values.firstWhere((e) => e.id == id, orElse: () => male);
  }

  static Gender fromLabel(String label) {
    switch (label.toLowerCase()) {
      case 'female':
      case 'أنثى':
        return Gender.female;
      default:
        return Gender.male;
    }
  }
}
