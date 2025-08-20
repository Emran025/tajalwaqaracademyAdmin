import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
// ... imports
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/tracking_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class FinalizeSession extends UseCase<void, FinalizeSessionParams> {
  final TrackingRepository repository;
  FinalizeSession(this.repository);

  @override
  Future<Either<Failure, void>> call(FinalizeSessionParams params) async {
    return await repository.finalizeSession(
      trackingId: params.trackingId,
      finalNotes: params.finalNotes,
      behaviorScore: params.behaviorScore,
    );
  }
}

class FinalizeSessionParams extends Equatable {
  final int trackingId;
  final String finalNotes;
  final int behaviorScore;
  const FinalizeSessionParams({required this.trackingId, required this.finalNotes, required this.behaviorScore});
  @override
  List<Object> get props => [trackingId, finalNotes, behaviorScore];
}