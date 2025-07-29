import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/error_model.dart';
import '../entities/teacher_list_item_entity.dart';
import '../repositories/teacher_repository.dart';
import 'usecase.dart';

/// A use case that provides a real-time stream of the teacher list.
///
/// This use case subscribes to the [TeacherRepository] to get a stream of
/// teachers. It follows the "Stale-While-Revalidate" pattern implicitly, as the
/// repository handles the background synchronization.
@lazySingleton
class WatchTeachersUseCase
    extends StreamUseCase<List<TeacherListItemEntity>, WatchTeachersParams> {
  final TeacherRepository _repository;

  WatchTeachersUseCase({required TeacherRepository repository})
    : _repository = repository;

  /// Calls the repository to get a stream of teachers.
  ///
  /// The stream will immediately emit the cached data and then emit new data
  /// whenever the local database is updated by the background sync process.
  @override
  Stream<Either<Failure, List<TeacherListItemEntity>>> call(
    WatchTeachersParams params,
  ) {
    // The use case acts as a clean proxy to the repository method.
    return _repository.getTeachers(forceRefresh: params.forceRefresh);
  }
}

/// Parameters for the [WatchTeachersUseCase].
class WatchTeachersParams extends Equatable {
  /// When `true`, it signals to the repository to force a background sync.
  /// This is useful for user-initiated "pull-to-refresh" actions.
  final bool forceRefresh;

  const WatchTeachersParams({this.forceRefresh = true});

  @override
  List<Object?> get props => [forceRefresh];
}
