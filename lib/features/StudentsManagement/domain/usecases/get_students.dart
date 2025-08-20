import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/student_list_item_entity.dart';
import '../repositories/student_repository.dart';
import 'usecase.dart';

/// A use case that provides a real-time stream of the student list.
///
/// This use case subscribes to the [StudentRepository] to get a stream of
/// students. It follows the "Stale-While-Revalidate" pattern implicitly, as the
/// repository handles the background synchronization.
@lazySingleton
class WatchStudentsUseCase
    extends StreamUseCase<List<StudentListItemEntity>, WatchStudentsParams> {
  final StudentRepository _repository;

  WatchStudentsUseCase({required StudentRepository repository})
    : _repository = repository;

  /// Calls the repository to get a stream of students.
  ///
  /// The stream will immediately emit the cached data and then emit new data
  /// whenever the local database is updated by the background sync process.
  @override
  Stream<Either<Failure, List<StudentListItemEntity>>> call(
    WatchStudentsParams params,
  ) {
    // The use case acts as a clean proxy to the repository method.
    return _repository.getStudents(forceRefresh: params.forceRefresh);
  }
}

/// Parameters for the [WatchStudentsUseCase].
class WatchStudentsParams extends Equatable {
  /// When `true`, it signals to the repository to force a background sync.
  /// This is useful for user-initiated "pull-to-refresh" actions.
  final bool forceRefresh;

  const WatchStudentsParams({this.forceRefresh = true});

  @override
  List<Object?> get props => [forceRefresh];
}
