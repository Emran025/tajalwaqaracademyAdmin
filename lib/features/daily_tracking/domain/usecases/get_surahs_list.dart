// lib/features/quran_reader/domain/usecases/get_surahs_list.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import 'package:tajalwaqaracademy/features/daily_tracking/domain/entities/surah.dart';
import 'package:tajalwaqaracademy/features/daily_tracking/domain/repositories/quran_repository.dart';
import 'package:injectable/injectable.dart';

/// A use case for fetching the complete list of all Surahs in the Quran.
/// This class encapsulates the business logic for retrieving the surah index.
/// It relies on the [QuranRepository] to abstract away the data fetching details.
@lazySingleton
class GetSurahsList implements UseCase<List<Surah>, NoParams> {
  final QuranRepository repository;

  /// Constructs a [GetSurahsList] use case.
  ///
  /// Requires a [QuranRepository] instance, which is typically provided
  /// through dependency injection.
  GetSurahsList({required this.repository});

  /// Executes the use case to get the list of surahs.
  ///
  /// Since this operation doesn't require any specific input parameters,
  /// it uses the [NoParams] class to signify this.
  /// The call is forwarded to the repository's `getSurahsList` method.
  @override
  Future<Either<Failure, List<Surah>>> call(NoParams params) async {
    return await repository.getSurahsList();
  }
}
