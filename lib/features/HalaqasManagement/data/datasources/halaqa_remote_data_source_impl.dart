import 'package:injectable/injectable.dart';
import 'package:tajalwaqaracademy/core/api/api_consumer.dart';
import 'package:tajalwaqaracademy/core/api/end_ponits.dart';
import '../../domain/entities/paginated_halaqas_result.dart';
import '../models/halaqa_model.dart';
import '../models/halaqa_sync_response_model.dart';
import 'halaqa_remote_data_source.dart';

/// The concrete implementation of [HalaqaRemoteDataSource].
///
/// This class communicates with the remote API using the provided [ApiConsumer].
/// Its primary responsibilities are to format request data, call the appropriate
/// API endpoints, and parse the raw JSON responses into strongly-typed data models.
/// It relies on the [ApiConsumer] to handle underlying network errors and exceptions.

/// to perform all halaqa-related data operations, including the complex
/// two-way synchronization logic.
@LazySingleton(as: HalaqaRemoteDataSource)
final class HalaqaRemoteDataSourceImpl implements HalaqaRemoteDataSource {
  final ApiConsumer _apiConsumer;

  HalaqaRemoteDataSourceImpl({required ApiConsumer apiConsumer})
    : _apiConsumer = apiConsumer;
  @override
  Future<PaginatedHalaqasResult> getHalaqas({required int page}) async {
    // Make the API call using the injected ApiConsumer.
    // The ApiConsumer is responsible for handling network exceptions.
    final responseJson = await _apiConsumer.get(
      EndPoint.halaqas, // Example: '/halaqas'
      queryParameters: {'page': page},
    );

    // The response structure from a paginated endpoint often looks like:
    // {
    //   "data": [...],
    //   "meta": { "last_page": 20 }
    // }
    // We need to parse this structure robustly.

    // Ensure the response is a map, otherwise it's an invalid format.
    if (responseJson is! Map<String, dynamic>) {
      throw const FormatException('Invalid response format: Expected a map.');
    }

    // Safely extract the list of halaqa data.
    final List<dynamic> halaqasListJson =
        responseJson['data'] as List<dynamic>? ?? [];

    // Parse each item in the list into a HalaqaModel.
    final List<HalaqaModel> halaqas = halaqasListJson
        .map(
          (halaqaJson) =>
              HalaqaModel.fromJson(halaqaJson as Map<String, dynamic>),
        )
        .toList();

    // Safely extract pagination metadata.
    final int currentPage =
        responseJson['meta']?['current_page'] as int? ?? page;
    final int lastPage =
        responseJson['meta']?['last_page'] as int? ?? currentPage;

    // Construct and return the final paginated result.
    return PaginatedHalaqasResult(
      halaqas: halaqas,
      hasMorePages: currentPage < lastPage,
    );
  }

  @override
  Future<HalaqaSyncResponseModel> getUpdatedHalaqas({
    required int since,
    required int page,
  }) async {
    // The `since` timestamp is sent as a query parameter to the sync endpoint.
    // The server is expected to return only the records that have changed since then.
    final responseJson = await _apiConsumer.get(
      EndPoint.halaqasSync, // Example: '/halaqas/sync'
      queryParameters: {
        'updatedSince': since,
        'page': page,
      }, // Assuming page 1 for simplicity
    );

    // The response is expected to be a map containing 'updated' and 'deleted' lists.
    if (responseJson is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid sync response format: Expected a root map.',
      );
    }

    // Delegate parsing to the dedicated response model.
    return HalaqaSyncResponseModel.fromJson(responseJson);
  }

  @override
  Future<HalaqaModel> upsertHalaqa(Map<String, dynamic> halaqaData) async {
    // The API should handle both create (if no ID) and update (if ID exists)
    // with a single endpoint for simplicity.
    final responseJson = await _apiConsumer.post(
      EndPoint.halaqasUpsert, // Example: '/halaqas/upsert'
      data: halaqaData,
    );

    if (responseJson is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid upsert response format: Expected a halaqa object map.',
      );
    }

    // The server returns the final state of the object, which we parse and return.
    return HalaqaModel.fromJson(responseJson);
  }

  @override
  Future<void> deleteHalaqa(String halaqaId) async {
    // A DELETE request is sent to a URL that includes the halaqa's ID.
    await _apiConsumer.delete(
      '${EndPoint.halaqas}/$halaqaId', // Example: DELETE /halaqas/some-uuid
    );
    // On a successful 2xx response, we expect no content, so the method returns void.
  }
}
