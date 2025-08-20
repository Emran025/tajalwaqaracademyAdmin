import '../../domain/entities/paginated_halaqas_result.dart';
import '../models/halaqa_model.dart';
import '../models/halaqa_sync_response_model.dart';

/// Defines the abstract contract for the remote data source of halaqas.
/// This interface specifies the methods for fetching and manipulating halaqa
/// data from the remote API. All methods must return data layer models (e.g.,
/// [HalaqaModel]) and are expected to throw a [ServerException] upon API failure.

/// Defines the abstract contract for the remote data source of halaqas.
///
/// This interface specifies all methods for interacting with the halaqa-related
/// endpoints of the remote API. It is designed to support a robust, two-way
/// synchronization mechanism.
abstract interface class HalaqaRemoteDataSource {
  /// Fetches a paginated list of halaqas from the remote API.
  ///
  /// - [page]: The page number to fetch.
  ///
  /// Returns a [PaginatedHalaqasResult] containing a list of [HalaqaModel]
  /// and pagination information.
  Future<PaginatedHalaqasResult> getHalaqas({required int page});

  /// Fetches a single page of delta updates from the server.
  ///
  /// - [since]: A Unix timestamp (milliseconds) of the last successful sync.
  /// - [page]: The page number to fetch.
  ///
  /// Returns a [HalaqaSyncResponseModel] containing a batch of updated/deleted
  /// records, pagination info, and a new server timestamp.
  Future<HalaqaSyncResponseModel> getUpdatedHalaqas({
    required int since,
    required int page, // <<< الحلقةة الجديدة
  });

  /// Pushes a create or update operation for a single halaqa to the server.
  ///
  /// This is the core method for the "push" stage of synchronization.
  /// - [halaqaData]: A map containing the full data of the halaqa to be created or updated.
  ///
  /// Returns the final, server-confirmed [HalaqaModel].
  Future<HalaqaModel> upsertHalaqa(Map<String, dynamic> halaqaData);

  // You can add other methods like:
  // Future<HalaqaModel> updateHalaqa({required String id, required Map<String, dynamic> halaqaData});
  // Future<void> deleteHalaqa({required String id});
  /// Deletes a halaqa by their ID via the remote API.
  /// - [halaqaId]: The ID of the halaqa to delete.
  /// Returns a [Future] that completes when the deletion is successful.
  Future<void> deleteHalaqa(String halaqaId);
}
