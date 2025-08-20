import 'package:injectable/injectable.dart';
import 'package:tajalwaqaracademy/core/api/api_consumer.dart';
import 'package:tajalwaqaracademy/core/api/end_ponits.dart';
import 'package:tajalwaqaracademy/core/error/exceptions.dart';
import 'package:tajalwaqaracademy/features/daily_tracking/data/datasources/tracking_remote_data_source.dart';
import 'package:tajalwaqaracademy/features/daily_tracking/data/models/tracking_sync_payload_model.dart';
import 'package:tajalwaqaracademy/features/daily_tracking/data/models/tracking_sync_response_model.dart';

@LazySingleton(as: TrackingRemoteDataSource)
final class TrackingRemoteDataSourceImpl implements TrackingRemoteDataSource {
  final ApiConsumer _apiConsumer;

  TrackingRemoteDataSourceImpl({required ApiConsumer apiConsumer}) : _apiConsumer = apiConsumer;

  @override
  Future<TrackingSyncResponseModel> pushTrackingUpdates(TrackingSyncPayloadModel payload) async {
    try {
      // 1. Perform the API call with the serialized payload.
      final responseJson = await _apiConsumer.post(
        EndPoint.trackingsSync, // Example: '/trackings/sync'
        data: payload.toJson(),
      );

      // 2. Validate the response structure. The server should always return a map.
      if (responseJson is! Map<String, dynamic>) {
        throw const ServerException(
          message: 'Invalid response format from tracking sync endpoint: Expected a map.',
        );
      }

      // 3. Parse the JSON response into a strongly-typed model and return it.
      // The response model can confirm which UUIDs were successfully processed.
      return TrackingSyncResponseModel.fromJson(responseJson);

    } on ServerException {
      // Re-throw server exceptions to be handled by the repository layer.
      rethrow;
    } catch (e) {
      // Wrap any other unexpected errors in a ServerException.
      throw ServerException(message: 'An unexpected error occurred during tracking push: ${e.toString()}');
    }
  }
}