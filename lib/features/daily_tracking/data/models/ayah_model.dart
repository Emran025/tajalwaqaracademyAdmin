// lib/features/quran_reader/data/models/ayah_model.dart

import 'package:equatable/equatable.dart';
import '../datasources/quran_ayas.dart';
import 'package:tajalwaqaracademy/features/daily_tracking/domain/entities/ayah.dart';

class AyahModel extends Equatable {
  final int number; // Corresponds to ID
  final String text; // Corresponds to AyaDiac
  final String textEmlaey; // Corresponds to SearchText
  final int numberInSurah; // Corresponds to AyaNum
  final int page; // Corresponds to PageNum
  final int surahNumber; // Corresponds to SoraNum
  final int juz; // Corresponds to PartNum
  // We don't have a sajda field in this DB, so we'll default it to false.
  final bool sajda;

  const AyahModel({
    required this.number,
    required this.text,
    required this.textEmlaey,
    required this.numberInSurah,
    required this.page,
    required this.surahNumber,
    required this.juz,
    this.sajda = false,
  });

  factory AyahModel.fromMap(Map<String, dynamic> map) {
    return AyahModel(
      number: map['ID'] as int,
      text: quranAyas[map['ID'] - 1 ?? 0],
      textEmlaey: map['SearchText'] as String,
      numberInSurah: map['AyaNum'] as int,
      page: map['PageNum'] as int,
      surahNumber: map['SoraNum'] as int,
      juz: map['PartNum'] as int,
      // sajda is not in the table, defaulting to false
    );
  }

  Ayah toEntity() {
    return Ayah(
      number: number,
      text: text,
      textEmlaey: textEmlaey,
      numberInSurah: numberInSurah,
      page: page,
      surahNumber: surahNumber,
      juz: juz,
      sajda: sajda,
    );
  }

  @override
  List<Object?> get props => [
    number,
    text,
    numberInSurah,
    page,
    surahNumber,
    juz,
  ];
}
