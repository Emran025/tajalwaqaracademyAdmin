import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/faq_entity.dart';
import '../repositories/settings_repository.dart';

@lazySingleton
class GetFaqsUseCase implements UseCase<List<FaqEntity>, GetFaqsParams> {
  final SettingsRepository repository;

  GetFaqsUseCase(this.repository);

  @override
  Future<Either<Failure, List<FaqEntity>>> call(GetFaqsParams params) async {
    return await repository.getFaqs(params.page);
  }
}

class GetFaqsParams extends Equatable {
  final int page;

  const GetFaqsParams({required this.page});

  @override
  List<Object?> get props => [page];
}
