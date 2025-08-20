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

  @override
  List<Object?> get props => [id, trackingDetailId, ayahIdQuran, wordIndex, mistakeType];
}