// lib/features/quran_reader/data/datasources/quran_local_data_source.dart

import 'dart:async';
import 'package:tajalwaqaracademy/features/daily_tracking/data/models/ayah_model.dart';
import 'package:tajalwaqaracademy/features/daily_tracking/data/models/surah_model.dart';

/// The abstract contract for the local data source of Quran data.
///
/// This defines the methods that any implementation must provide, ensuring
/// a consistent API for the repository layer.
abstract class QuranLocalDataSource {
  /// Fetches a list of [AyahModel] for a specific page number from the local database.
  ///
  /// Throws a [CacheException] if there is an error accessing the database.
  Future<List<AyahModel>> getPageAyahs(int pageNumber);
  /// Fetches a list of [AyahModel] for a specific page number from the local database.
  ///
  /// Throws a [CacheException] if there is an error accessing the database.
  Future<List<AyahModel>> getMistakesAyahs(List<int> ayahsNumbers);

  /// Fetches the complete list of [SurahModel] from the local database.
  ///
  /// Throws a [CacheException] if there is an error accessing the database.
  Future<List<SurahModel>> getSurahsList();
}
