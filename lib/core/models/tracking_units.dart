enum TrackingUnit {
  juz(1, 'جزء', "juz"),
  hizb(2, 'حزب', "hizb"),
  halfHizb(3, '\u00bd حزب', "halfHizb"),
  quarterHizb(4, '\u00bc حزب', "quarterHizb"),
  page(5, 'صفحة', "page");

  final int id;
  final String labelAr;
  final String label;
  const TrackingUnit(this.id, this.labelAr, this.label);

  static TrackingUnit fromLabel(String label) {
    switch (label.toLowerCase()) {
      case 'juz':
      case 'جزء':
        return TrackingUnit.juz;
      case 'hizb':
      case 'حزب':
        return TrackingUnit.hizb;
      case 'halfHizb':
      case 'نصف حزب':
      case '½ حزب':
        return TrackingUnit.halfHizb;
      case 'quarterHizb':
      case 'ربع حزب':
      case '¼ حزب':
        return TrackingUnit.quarterHizb;
      default:
        return TrackingUnit.page;
    }
  }

  static TrackingUnit fromId(int id) {
    return TrackingUnit.values.firstWhere(
      (e) => e.id == id,
      orElse: () => page,
    );
  }
}
