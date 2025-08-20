import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/models/active_status.dart';
import '../../../../core/models/report_frequency.dart';
import '../entities/halaqa_entity.dart';
import '../entities/halaqa_list_item_entity.dart';

/// Defines the abstract contract for the halaqa data repository.
///
/// This interface is the single gateway for the domain layer to interact with
/// all halaqa-related data, abstracting away the complexities of data sources,
/// caching, and synchronization.
abstract interface class HalaqaRepository {
  /// Returns a stream of the halaqa list, suitable for a reactive UI.
  ///
  /// This method implements a "Stale-While-Revalidate" pattern. It immediately
  /// returns a stream of the locally cached data and simultaneously triggers a
  /// background sync to fetch the latest data from the remote server.
  ///
  /// Any updates from the sync will be automatically pushed to the local database,
  /// which in turn will cause this stream to emit a new, updated list.
  ///
  /// - [forceRefresh]: When true, it forces a background sync even if one was
  ///   recently completed. Useful for "pull-to-refresh" actions.
  ///
  /// Returns a [Stream] that emits `Either<Failure, List<HalaqaListItemEntity>>`.
  Stream<Either<Failure, List<HalaqaListItemEntity>>> getHalaqas({
    bool forceRefresh = true,
  });

  /// Fetches the next page of halaqas from the remote API to append to the local cache.
  ///
  /// This is used for "load more" or infinite scrolling functionality. The UI will
  /// update automatically via the stream returned by `getHalaqas`.
  ///
  /// - [page]: The next page number to fetch.
  Future<Either<Failure, Unit>> fetchMoreHalaqas({required int page});

  /// Returns [Either<Failure, HalaqaDetailEntity>]:
  /// - Right(HalaqaDetailEntity) on success.
  /// - Left(Failure) if the halaqa is not found or another error occurs.
  Future<Either<Failure, HalaqaDetailEntity>> getHalaqaById(String halaqaId);

  /// Creates a new halaqa or updates an existing one.
  ///
  /// Returns [Either<Failure, HalaqaDetailEntity>]:
  /// - Right(HalaqaDetailEntity) on success, returning the created/updated halaqa.
  /// - Left(Failure) on error.
  Future<Either<Failure, HalaqaDetailEntity>> upsertHalaqa(
    HalaqaDetailEntity halaqa,
  );

  /// Deletes a halaqa by their ID.
  ///
  /// Returns [Either<Failure, Unit>]:
  /// - Right(unit) on successful deletion. `unit` is a void-like type from dartz.
  /// - Left(Failure) on error.
  Future<Either<Failure, Unit>> deleteHalaqa(String halaqaId);

  /// Returns [Right(unit)] on success, or a [Left(Failure)] on error.
  Future<Either<Failure, Unit>> setHalaqaStatus({
    required String halaqaId,
    required ActiveStatus newStatus,
  });

  Future<Either<Failure, List<HalaqaListItemEntity>>>
  getHalaqasByStudentCriteria({
    ActiveStatus? studentStatus,
    DateTime? trackDate,
    Frequency? frequencyCode,
  });
}
