// lib/features/quran_reader/domain/entities/ayah.dart

import 'package:equatable/equatable.dart';

/// Represents an Ayah (verse) of the Quran.
///
/// This is a pure domain entity, containing the core business logic and data
/// related to an Ayah. It is completely decoupled from data and presentation layers.
/// It extends [Equatable] to facilitate value-based comparisons, essential for
/// state management and testing.
import 'package:flutter/material.dart';

@immutable
class Ayah extends Equatable {
  /// A unique identifier for the Ayah across the entire Quran (from 1 to 6236).
  final int number;

  /// The Uthmani script text of the Ayah, typically used for display.
  final String text;

  /// The simplified, clean text of the Ayah (without special characters),
  /// ideal for search functionality and easier reading.
  final String textEmlaey;

  /// The number of the Ayah within its Surah (e.g., from 1 to 286 for Al-Baqara).
  final int numberInSurah;

  /// The page number in the standard Mushaf where the Ayah appears.
  final int page;

  /// The number of the Surah to which this Ayah belongs.
  final int surahNumber;

  /// The Juz' (part) number where this Ayah is located.
  final int juz;

  /// A boolean flag indicating whether the Ayah contains a Sajda (prostration).
  final bool sajda;

  const Ayah({
    required this.number,
    required this.text,
    required this.textEmlaey,
    required this.numberInSurah,
    required this.page,
    required this.surahNumber,
    required this.juz,
    required this.sajda,
  });

  /// The list of properties that will be used to check for equality.
  @override
  List<Object?> get props => [
        number,
        text,
        textEmlaey,
        numberInSurah,
        page,
        surahNumber,
        juz,
        sajda,
      ];
}