// lib/features/quran_reader/domain/usecases/get_page_data.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import 'package:tajalwaqaracademy/features/daily_tracking/domain/repositories/quran_repository.dart';
import 'package:injectable/injectable.dart';

import '../entities/ayah.dart';

/// A use case for fetching all the ayahs for a specific page of the Quran.
///
/// This class encapsulates the business logic for this specific action.
/// It depends on the [QuranRepository] contract to get the data, decoupling
/// the use case from the data layer's implementation.
@lazySingleton
class GetMistakesAyahs implements UseCase<List<Ayah>, GetMistakesAyahsParams> {
  final QuranRepository repository;

  /// Constructs a [GetMistakesAyahs] use case.
  ///
  /// Requires a [QuranRepository] instance, which will be injected by
  /// a dependency injection container.
  GetMistakesAyahs({required this.repository});

  /// Executes the use case.
  ///
  /// This method is callable like a function (e.g., `getMistakesAyahs(params)`).
  /// It delegates the call to the repository's `getMistakesAyahs` method and
  /// returns its result, which is an `Either` type containing either a
  /// `Failure` or a list of `Ayah` entities.
  @override
  Future<Either<Failure, List<Ayah>>> call(GetMistakesAyahsParams params) async {
    return await repository.getMistakesAyahsList(params.ayahsNumbers);
  }
}

/// A parameter object for the [GetMistakesAyahs] use case.
///
/// Using a dedicated parameter class instead of primitive types in the `call`
/// method signature makes the use case more readable, maintainable, and
/// -extensible. If more parameters are needed in the future, only this class
/// -needs to be updated.
class GetMistakesAyahsParams extends Equatable {
  final List<int> ayahsNumbers;

  const GetMistakesAyahsParams({required this.ayahsNumbers});

  @override
  List<Object?> get props => [ayahsNumbers];
}
