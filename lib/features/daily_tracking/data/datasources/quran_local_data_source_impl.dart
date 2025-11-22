// lib/features/quran_reader/data/datasources/quran_local_data_source.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:tajalwaqaracademy/features/daily_tracking/data/datasources/quran_local_data_source.dart';
import 'package:tajalwaqaracademy/features/daily_tracking/data/models/ayah_model.dart';
import 'package:tajalwaqaracademy/features/daily_tracking/data/models/surah_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/error/exceptions.dart';

/// The implementation of [QuranLocalDataSource] that uses SQLite.
///
/// This class is responsible for the one-time setup of the Quran database
/// by copying it from the assets and then querying it for data.
@LazySingleton(as: QuranLocalDataSource)
class QuranLocalDataSourceImpl implements QuranLocalDataSource {
  static const String _dbName = 'QuranV3.sqlite';
  Database? _database;
  Completer<Database>? _dbCompleter;

  /// Lazily initializes and returns the database instance, preventing race conditions.
  Future<Database> get database async {
    if (_dbCompleter != null) {
      return _dbCompleter!.future;
    }
    if (_database != null) {
      return _database!;
    }

    _dbCompleter = Completer<Database>();
    try {
      final db = await _initDatabase();
      _database = db;
      _dbCompleter!.complete(db);
    } catch (e) {
      _dbCompleter!.completeError(e);
    }
    return _dbCompleter!.future;
  }

  /// Initializes the database. If it doesn't exist, it's copied from assets.
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    final exists = await databaseExists(path);

    if (!exists) {
      print("First run: Copying Quran database from assets...");
      try {
        await Directory(dirname(path)).create(recursive: true);
        final assetPath = join('assets/', _dbName);
        final ByteData data = await rootBundle.load(assetPath);
        final List<int> bytes = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );
        await File(path).writeAsBytes(bytes, flush: true);
        print("Database copied successfully.");
      } catch (e) {
        throw CacheException(
          message:
              'FATAL: Error copying database from assets. Ensure "assets/$_dbName" exists and is in pubspec.yaml. Error: ${e.toString()}',
        );
      }
    } else {
      print("Opening existing Quran database.");
    }
    return await openDatabase(path, readOnly: true);
  }

  // gat ayahsModels by ayahs Numbers List
  /// Retrieves Quranic verses (ayahs) based on the provided list of verse IDs.
  ///
  /// This method fetches ayahs from the local database corresponding to the given
  /// list of IDs. Unlike a standard database query with IN clause that returns
  /// distinct results, this method preserves the original order and duplicates
  /// present in the input list, making it suitable for scenarios where verse
  /// repetition and sequence matter (e.g., mistake tracking in memorization).
  ///
  /// The implementation follows an optimized approach:
  /// 1. Fetches unique verses from the database in a single query
  /// 2. Creates an in-memory lookup map for efficient access
  /// 3. Reconstructs the result list maintaining original order and duplicates
  ///
  /// @param ayahsNumbers List of verse IDs to retrieve (may contain duplicates)
  /// @return Future<List<AyahModel>> List of ayah models in the same order and
  ///         frequency as the input IDs
  /// @throws CacheException If database operation fails or data retrieval error occurs
  @override
  Future<List<AyahModel>> getMistakesAyahs(List<int> ayahsNumbers) async {
    try {
      // Early return for empty input to optimize performance
      if (ayahsNumbers.isEmpty) {
        return [];
      }

      final db = await database;

      // Extract unique IDs to optimize database query performance
      final uniqueIds = ayahsNumbers.toSet().toList();

      // Execute single database query to fetch all required verses
      final List<Map<String, dynamic>> maps = await db.query(
        'Quran',
        where: 'ID IN (${List.filled(uniqueIds.length, '?').join(',')})',
        whereArgs: uniqueIds,
      );

      // Handle case where no verses are found for the given IDs
      if (maps.isEmpty) {
        return [];
      }

      // Create lookup map for O(1) access to verses by ID
      final ayahMap = <int, AyahModel>{};
      for (final map in maps) {
        final ayah = AyahModel.fromMap(map);
        ayahMap[ayah.number] = ayah;
      }

      // Reconstruct result list preserving original order and duplicates
      return ayahsNumbers
          .map((id) => ayahMap[id])
          .where((ayah) => ayah != null)
          .cast<AyahModel>()
          .toList();
    } catch (e) {
      throw CacheException(
        message: 'Failed to load ayahs for IDs $ayahsNumbers: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<AyahModel>> getPageAyahs(int pageNumber) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'Quran', // Correct table name
        where: 'PageNum = ?', // Correct column name
        whereArgs: [pageNumber],
        orderBy: 'AyaNum ASC', // Correct column name for ordering within page
      );

      if (maps.isNotEmpty) {
        return maps.map((map) => AyahModel.fromMap(map)).toList();
      } else {
        // It is valid for a page to be empty (e.g., decorative pages)
        return [];
      }
    } catch (e) {
      throw CacheException(
        message: 'Failed to load ayahs for page $pageNumber: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<SurahModel>> getSurahsList() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'Sora', // Correct table name
        orderBy: 'Id ASC', // Correct column name for ordering surahs
      );

      if (maps.isNotEmpty) {
        return maps.map((map) => SurahModel.fromMap(map)).toList();
      } else {
        throw const CacheException(
          message: 'Surah list is empty or table "Sora" not found.',
        );
      }
    } catch (e) {
      throw CacheException(
        message: 'Failed to load surahs list: ${e.toString()}',
      );
    }
  }
}
