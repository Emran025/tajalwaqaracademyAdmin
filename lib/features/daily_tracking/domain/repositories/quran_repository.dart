// lib/features/quran_reader/domain/repositories/quran_repository.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import 'package:tajalwaqaracademy/features/daily_tracking/domain/entities/ayah.dart';
import 'package:tajalwaqaracademy/features/daily_tracking/domain/entities/surah.dart';

/// An abstract contract for the Quran repository.
///
/// This interface resides in the domain layer and defines the methods that
/// use cases can call to interact with Quran data, without knowing the
/// implementation details of the data source.
///
/// The implementation of this contract (`QuranRepositoryImpl`) is in the data layer.
abstract class QuranRepository {
  /// Fetches the list of [Ayah] entities for a given page number.
  ///
  /// The method returns an `Either` type, which encapsulates either a [Failure]
  /// on the left side in case of an error, or a list of [Ayah] entities on the
  /// right side upon success.
  ///
  /// - [pageNumber]: The number of the page to fetch (e.g., 1 to 604).
  Future<Either<Failure, List<Ayah>>> getPageData(int pageNumber);

  /// Fetches the complete list of all [Surah] entities in the Quran.
  ///
  /// Similar to [getPageData], it returns an `Either` type, providing
  /// a [Failure] on error or the complete list of [Surah] entities on success.
  Future<Either<Failure, List<Surah>>> getSurahsList();
  /// Fetches the complete list of all [Surah] entities in the Quran.
  ///
  /// Similar to [getMistakesAyahs], it returns an `Either` type, providing
  /// a [Failure] on error or the complete list of [MistakesAyahs] entities on success.
  Future<Either<Failure, List<Ayah>>> getMistakesAyahsList(List <int> ayahsNumbers);
}
