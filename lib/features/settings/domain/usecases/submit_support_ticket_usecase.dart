import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/support_ticket_entity.dart';
import '../repositories/settings_repository.dart';

@lazySingleton
class SubmitSupportTicketUseCase
    implements UseCase<void, SubmitSupportTicketParams> {
  final SettingsRepository repository;

  SubmitSupportTicketUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(
      SubmitSupportTicketParams params) async {
    return await repository.submitSupportTicket(params.ticket);
  }
}

class SubmitSupportTicketParams extends Equatable {
  final SupportTicketEntity ticket;

  const SubmitSupportTicketParams({required this.ticket});

  @override
  List<Object?> get props => [ticket];
}
