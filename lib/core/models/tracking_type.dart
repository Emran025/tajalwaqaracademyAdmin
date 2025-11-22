enum TrackingType {
  memorization(1, 'حفظ', "Memorization"),
  review(2, 'مراجعة', "Review"),
  recitation(3, 'سرد', "Recitation");

  final int id;
  final String labelAr;
  final String label;
  const TrackingType(this.id, this.labelAr, this.label);
  static TrackingType fromId(int id) {
    return TrackingType.values.firstWhere(
      (e) => e.id == id,
      orElse: () => recitation,
    );
  }

  static TrackingType fromLabel(String label) {
    switch (label.toLowerCase()) {
      case 'memorization':
      case 'حفظ':
        return TrackingType.memorization;
      case 'review':
      case 'مراجعة':
        return TrackingType.review;
      default:
        return TrackingType.recitation;
    }
  }
}
