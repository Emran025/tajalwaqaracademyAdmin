// lib/features/quran_reader/data/models/surah_model.dart
import 'package:equatable/equatable.dart';
import 'package:tajalwaqaracademy/features/daily_tracking/domain/entities/surah.dart';

class SurahModel extends Equatable {
  final int number; // Corresponds to Id
  final String name; // Corresponds to Name_ar
  final String englishName; // Corresponds to Name_en
  // englishNameTranslation is not available, we'll use englishName
  final String englishNameTranslation;
  final int numberOfAyahs; // Corresponds to AyatCount
  final String revelationType; // Corresponds to TypeText_en

  const SurahModel({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.revelationType,
  });

  factory SurahModel.fromMap(Map<String, dynamic> map) {
    return SurahModel(
      number: map['Id'] as int,
      name: map['Name_ar'].replaceAll('ۡ', 'ْ') as String,
      englishName: map['Name_en'] as String,
      englishNameTranslation:
          map['Name_en'] as String, // Using Name_en as fallback
      numberOfAyahs: map['AyatCount'] as int,
      revelationType: map['TypeText_en'] as String,
    );
  }

  Surah toEntity() {
    return Surah(
      number: number,
      name: name,
      englishName: englishName,
      englishNameTranslation: englishNameTranslation,
      numberOfAyahs: numberOfAyahs,
      revelationType: revelationType,
    );
  }

  @override
  List<Object?> get props => [
    number,
    name,
    englishName,
    numberOfAyahs,
    revelationType,
  ];
}
