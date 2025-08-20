
import 'package:tajalwaqaracademy/core/error/exceptions.dart'; // To throw ServerException
import 'package:tajalwaqaracademy/features/daily_tracking/data/models/tracking_sync_response_model.dart';

// Import the relevant models
import '../models/tracking_sync_payload_model.dart';

/// Abstract contract for remote data operations related to student tracking.
abstract class TrackingRemoteDataSource {
  /// Pushes a batch of local tracking changes (updates) to the server.
  ///
  /// On success, it returns a [TrackingSyncResponseModel] which may contain
  /// acknowledgements or updated data from the server.
  /// Throws a [ServerException] on API errors.
  Future<TrackingSyncResponseModel> pushTrackingUpdates(TrackingSyncPayloadModel payload);
}



