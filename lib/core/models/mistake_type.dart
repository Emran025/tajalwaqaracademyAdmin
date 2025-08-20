/// Enhanced enum representing the different types of recitation mistakes.
///
/// Each member has an `id` for database storage and a `labelAr` for display in the UI.
enum MistakeType {
  // id, Arabic Label
  none(0, 'غير مصنف'),
  memory(1, 'نسيان'),
  grammar(2, 'نحوي'),
  pronunciation(3, 'مخارج حروف'),
  timing(4, 'وقف وابتداء');
  // You can easily add more types here in the future.
  
  final int id;
  final String labelAr;
  const MistakeType(this.id, this.labelAr);

  /// A utility method to find a [MistakeType] by its integer ID.
  ///
  /// This is useful when retrieving data from the database.
  /// Defaults to [MistakeType.none] if the id is not found.
  static MistakeType fromId(int id) {
    return MistakeType.values.firstWhere(
      (e) => e.id == id,
      orElse: () => none,
    );
  }
}