
class TrackingUnitDetail {
  final int id;
  final int unitId;
  final String fromSurah;
  final int fromPage;
  final int fromAyah;
  final String toSurah;
  final int toPage;
  final int toAyah;


  TrackingUnitDetail(
    this.id,
    this.unitId,
    this.fromSurah,
    this.fromPage,
    this.fromAyah,
    this.toSurah,
    this.toPage,
    this.toAyah,
  );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'unitId': unitId,
      'fromSurah': fromSurah,
      'fromPage': fromPage,
      'fromAyah': fromAyah,
      'toSurah': toSurah,
      'toPage': toPage,
      'toAyah': toAyah,
    };
  }

  factory TrackingUnitDetail.fromJson(Map<String, dynamic> json) {
    return TrackingUnitDetail(
      json['id'] as int,
      json['unitId'] as int,
      json['fromSurah'] as String,
      json['fromPage'] as int,
      json['fromAyah'] as int,
      json['toSurah'] as String,
      json['toPage'] as int,
      json['toAyah'] as int,
    );
  }
}
