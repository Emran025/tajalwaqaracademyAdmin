enum TrackingUnitTyps {
  juz(1, 'جزء', "juz"),
  hizb(2, 'حزب', "hizb"),
  halfHizb(3, '\u00bd حزب', "halfHizb"),
  quarterHizb(4, '\u00bc حزب', "quarterHizb"),
  page(5, 'صفحة', "page");

  final int id;
  final String labelAr;
  final String label;
  const TrackingUnitTyps(this.id, this.labelAr, this.label);

  static TrackingUnitTyps fromLabel(String label) {
    switch (label.toLowerCase()) {
      case 'juz':
      case 'جزء':
        return TrackingUnitTyps.juz;
      case 'hizb':
      case 'حزب':
        return TrackingUnitTyps.hizb;
      case 'halfHizb':
      case 'نصف حزب':
      case '½ حزب':
        return TrackingUnitTyps.halfHizb;
      case 'quarterHizb':
      case 'ربع حزب':
      case '¼ حزب':
        return TrackingUnitTyps.quarterHizb;
      default:
        return TrackingUnitTyps.page;
    }
  }

  static TrackingUnitTyps fromId(int id) {
    return TrackingUnitTyps.values.firstWhere(
      (e) => e.id == id,
      orElse: () => page,
    );
  }
}
