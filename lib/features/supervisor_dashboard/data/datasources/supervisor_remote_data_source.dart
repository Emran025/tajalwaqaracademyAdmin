
import '../../../../core/models/user_role.dart';
import '../models/application_model.dart';

/// Defines the abstract contract for the remote data source of students.
///
/// This interface specifies the methods for fetching and manipulating student
/// data from the remote API. All methods must return data layer models (e.g.,
/// [StudentModel]) and are expected to throw a [ServerException] upon API failure.

/// Defines the abstract contract for the remote data source of students.
///
/// This interface specifies all methods for interacting with the student-related
/// endpoints of the remote API. It is designed to support a robust, two-way
/// synchronization mechanism.

abstract interface class SupervisorRemoteDataSource {

  /// Fetches a single page of delta updates from the server.
  ///
  /// - [since]: A Unix timestamp (milliseconds) of the last successful sync.
  /// - [page]: The page number to fetch.
  ///
  /// Returns a [StudentSyncResponseModel] containing a batch of updated/deleted
  /// records, pagination info, and a new server timestamp.
  Future<PaginatedApplicationsResponse> getApplications({
    int page = 1,
    int? since,
     required UserRole entityType ,
  });
}
