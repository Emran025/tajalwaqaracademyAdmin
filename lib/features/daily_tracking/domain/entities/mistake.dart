//lib/features/daily_tracking/domain/entities/mistake.dart

import 'package:equatable/equatable.dart';

import '../../../../core/models/mistake_type.dart';


/// Represents a single mistake marked on a specific word within an ayah.
/// This is the pure, domain-layer representation of a mistake.
class Mistake extends Equatable {
  final String id; // The unique UUID of the mistake
  final String trackingDetailId; // The UUID of the parent tracking detail
  final int ayahIdQuran; // The ID of the ayah in the static Quran table
  final int wordIndex; // The index of the character/word
  final MistakeType mistakeType;

  const Mistake({
    required this.id,
    required this.trackingDetailId,
    required this.ayahIdQuran,
    required this.wordIndex,
    required this.mistakeType,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trackingDetailId': trackingDetailId,
      'ayahIdQuran': ayahIdQuran,
      'wordIndex': wordIndex,
      'mistakeType': mistakeType.toString(),
    };
  }

  factory Mistake.fromJson(Map<String, dynamic> json) {
    return Mistake(
      id: json['id'] as String,
      trackingDetailId: json['trackingDetailId'] as String,
      ayahIdQuran: json['ayahIdQuran'] as int,
      wordIndex: json['wordIndex'] as int,
      mistakeType: MistakeType.values
          .firstWhere((e) => e.toString() == json['mistakeType'] as String),
    );
  }

  @override
  List<Object?> get props => [id, trackingDetailId, ayahIdQuran, wordIndex, mistakeType];
}
