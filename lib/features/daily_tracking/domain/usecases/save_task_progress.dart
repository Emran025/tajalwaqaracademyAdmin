import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:tajalwaqaracademy/features/StudentsManagement/domain/entities/tracking_detail_entity.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/tracking_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class SaveTaskProgress extends UseCase<void, SaveTaskProgressParams> {
  final TrackingRepository repository;
  SaveTaskProgress(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveTaskProgressParams params) async {
    return await repository.saveDraftTaskProgress(params.detail);
  }
}

class SaveTaskProgressParams extends Equatable {
  final TrackingDetailEntity detail;
  const SaveTaskProgressParams({required this.detail});
  @override
  List<Object> get props => [detail];
}
