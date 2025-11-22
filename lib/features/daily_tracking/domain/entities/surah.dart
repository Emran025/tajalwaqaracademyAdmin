// lib/features/quran_reader/domain/entities/surah.dart

import 'package:equatable/equatable.dart';

/// Represents a Surah (chapter) of the Quran.
///
/// This is a pure domain entity. It contains the core business logic and data
/// related to a Surah, completely independent of the data source or the UI layer.
///
/// It extends [Equatable] to enable value-based equality, which is crucial for
/// state management and testing. Two `Surah` instances are considered equal if all
/// their properties are the same.
import 'package:flutter/material.dart';

@immutable
class Surah extends Equatable {
  /// The unique number of the Surah in the Quran (e.g., 1 for Al-Fatiha).
  final int number;

  /// The Arabic name of the Surah (e.g., "سُورَةُ ٱلْفَاتِحَةِ").
  final String name;

  /// The common English name of the Surah (e.g., "Al-Fatiha").
  final String englishName;

  /// The English translation of the Surah's name (e.g., "The Opening").
  final String englishNameTranslation;

  /// The total number of Ayahs (verses) in the Surah.
  final int numberOfAyahs;

  /// The total number of Ayahs (verses) in the Surah.
  final int firstPageStrtsAt;

  /// The revelation type of the Surah, either "Meccan" or "Medinan".
  final String revelationType;

  const Surah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.firstPageStrtsAt,
    required this.revelationType,
  });

  /// The properties that are used by [Equatable] to determine if two instances are equal.
  @override
  List<Object?> get props => [
        number,
        name,
        englishName,
        englishNameTranslation,
        numberOfAyahs,
        firstPageStrtsAt,
        revelationType,
      ];
}