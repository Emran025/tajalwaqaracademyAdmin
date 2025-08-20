// lib/features/quran_reader/domain/usecases/get_page_data.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import 'package:tajalwaqaracademy/features/daily_tracking/domain/entities/ayah.dart';
import 'package:tajalwaqaracademy/features/daily_tracking/domain/repositories/quran_repository.dart';
import 'package:injectable/injectable.dart';

/// A use case for fetching all the ayahs for a specific page of the Quran.
///
/// This class encapsulates the business logic for this specific action.
/// It depends on the [QuranRepository] contract to get the data, decoupling
/// the use case from the data layer's implementation.
@lazySingleton
class GetPageData implements UseCase<List<Ayah>, GetPageDataParams> {
  final QuranRepository repository;

  /// Constructs a [GetPageData] use case.
  ///
  /// Requires a [QuranRepository] instance, which will be injected by
  /// a dependency injection container.
  GetPageData({required this.repository});

  /// Executes the use case.
  ///
  /// This method is callable like a function (e.g., `getPageData(params)`).
  /// It delegates the call to the repository's `getPageData` method and
  /// returns its result, which is an `Either` type containing either a
  /// `Failure` or a list of `Ayah` entities.
  @override
  Future<Either<Failure, List<Ayah>>> call(GetPageDataParams params) async {
    return await repository.getPageData(params.pageNumber);
  }
}

/// A parameter object for the [GetPageData] use case.
///
/// Using a dedicated parameter class instead of primitive types in the `call`
/// method signature makes the use case more readable, maintainable, and
/// -extensible. If more parameters are needed in the future, only this class
/// -needs to be updated.
class GetPageDataParams extends Equatable {
  final int pageNumber;

  const GetPageDataParams({required this.pageNumber});

  @override
  List<Object?> get props => [pageNumber];
}
