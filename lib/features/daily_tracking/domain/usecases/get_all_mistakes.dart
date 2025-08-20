import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/models/tracking_type.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/mistake.dart';
import '../repositories/tracking_repository.dart';

/// A use case for fetching a historical list of all mistakes for a student,
/// with optional filtering by tracking type and page range.
import 'package:injectable/injectable.dart';

@lazySingleton
/// A use case for fetching a historical list of all mistakes for a student,
/// with optional filtering by tracking type and page range.
class GetAllMistakes extends UseCase<List<Mistake>, GetAllMistakesParams> {
  final TrackingRepository repository;
  GetAllMistakes(this.repository);

  @override
  Future<Either<Failure, List<Mistake>>> call(GetAllMistakesParams params) async {
    return await repository.getAllMistakes(
      enrollmentId: params.enrollmentId,
      type: params.type, // Can be null
      fromPage: params.fromPage,
      toPage: params.toPage,
    );
  }
}

class GetAllMistakesParams extends Equatable {
  final String enrollmentId;
  final TrackingType? type; // <-- NOW OPTIONAL

  final int? fromPage;
  final int? toPage;

  const GetAllMistakesParams({
    required this.enrollmentId,
    this.type, // <-- NOW OPTIONAL
    this.fromPage,
    this.toPage,
  });

  @override
  List<Object?> get props => [enrollmentId, type, fromPage, toPage];
}