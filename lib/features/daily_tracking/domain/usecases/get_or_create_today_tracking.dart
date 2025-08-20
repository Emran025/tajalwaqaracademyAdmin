import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/models/tracking_type.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../StudentsManagement/domain/entities/tracking_detail_entity.dart';
import '../repositories/tracking_repository.dart';
import 'package:injectable/injectable.dart';

// Renamed for clarity to match what it returns.
@lazySingleton
class GetOrCreateTodayTrackingDetails
    extends
        UseCase<
          Map<TrackingType, TrackingDetailEntity>,
          GetOrCreateTodayTrackingDetailsParams
        > {
  final TrackingRepository repository;

  GetOrCreateTodayTrackingDetails(this.repository);

  @override
  Future<Either<Failure, Map<TrackingType, TrackingDetailEntity>>> call(
    GetOrCreateTodayTrackingDetailsParams params,
  ) async {
    return await repository.getOrCreateTodayDraftTrackingDetails(
      enrollmentId: params.enrollmentId,
    );
  }
}

class GetOrCreateTodayTrackingDetailsParams extends Equatable {
  final String enrollmentId;

  const GetOrCreateTodayTrackingDetailsParams({required this.enrollmentId});

  @override
  List<Object> get props => [enrollmentId];
}
