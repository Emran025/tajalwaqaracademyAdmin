// lib/features/quran_reader/data/repositories/quran_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import 'package:tajalwaqaracademy/features/daily_tracking/data/datasources/quran_local_data_source.dart';
import 'package:tajalwaqaracademy/features/daily_tracking/domain/entities/ayah.dart';
import 'package:tajalwaqaracademy/features/daily_tracking/domain/entities/surah.dart';
import 'package:tajalwaqaracademy/features/daily_tracking/domain/repositories/quran_repository.dart';

import '../../../../core/error/exceptions.dart';

/// The implementation of the [QuranRepository] contract.
///
/// This class acts as a bridge between the data layer (data sources) and the
/// domain layer (use cases). It orchestrates data fetching from the local
/// data source and handles the conversion from data models to domain entities.
/// It also translates data-layer exceptions into domain-layer failures.
@LazySingleton(as: QuranRepository)
class QuranRepositoryImpl implements QuranRepository {
  final QuranLocalDataSource localDataSource;
  // In a more complex app, you might also have a remoteDataSource here.
  // final QuranRemoteDataSource remoteDataSource;

  QuranRepositoryImpl({
    required this.localDataSource,
    // required this.remoteDataSource,
  });

  /// Retrieves the list of ayahs for a specific page.
  ///
  /// It calls the [localDataSource] to get the data. If the call is successful,
  /// it maps the list of `AyahModel` to a list of `Ayah` entities.
  /// If a [CacheException] occurs, it catches it and returns a [CacheFailure].
  @override
  Future<Either<Failure, List<Ayah>>> getPageData(int pageNumber) async {
    try {
      // 1. Fetch data models from the data source.
      final ayahModels = await localDataSource.getPageAyahs(pageNumber);

      // 2. Convert data models to domain entities.

      final ayahs = ayahModels.map((model) => model.toEntity()).toList();

      // 3. Return the result wrapped in a 'Right' for success.
      return Right(ayahs);
    } on CacheException catch (e) {
      // 4. Catch specific exceptions and return them as domain 'Failures'.
      return Left(CacheFailure(message: e.message));
    } on Exception catch (e) {
      // 5. Catch any other unexpected exceptions.
      return Left(
        UnknownFailure(
          message: 'An unexpected error occurred: ${e.toString()}',
        ),
      );
    }
  }

  /// Retrieves the complete list of all surahs.
  ///
  /// It follows the same pattern as [getPageData]: fetch models, convert to entities,
  /// and handle potential exceptions by returning a [Failure].
  @override
  Future<Either<Failure, List<Surah>>> getSurahsList() async {
    try {
      final surahModels = await localDataSource.getSurahsList();
      final surahs = surahModels.map((model) => model.toEntity()).toList();
      return Right(surahs);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on Exception catch (e) {
      return Left(
        UnknownFailure(
          message: 'An unexpected error occurred: ${e.toString()}',
        ),
      );
    }
  }

  /// Retrieves the complete list of all surahs.
  ///
  /// It follows the same pattern as [getMistakesAyahs]: fetch models, convert to entities,
  /// and handle potential exceptions by returning a [Failure].
  @override
  Future<Either<Failure, List<Ayah>>> getMistakesAyahsList(
    List<int> ayahsNumbers,
  ) async {
    try {
      // 1. Fetch data models from the data source.
      final ayahModels = await localDataSource.getMistakesAyahs(ayahsNumbers);

      // 2. Convert data models to domain entities.

      final ayahs = ayahModels.map((model) => model.toEntity()).toList();

      // 3. Return the result wrapped in a 'Right' for success.
      return Right(ayahs);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on Exception catch (e) {
      return Left(
        UnknownFailure(
          message: 'An unexpected error occurred: ${e.toString()}',
        ),
      );
    }
  }
}
