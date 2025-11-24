import 'package:equatable/equatable.dart';

class SupportTicketEntity extends Equatable {
  final String subject;
  final String body;

  const SupportTicketEntity({
    required this.subject,
    required this.body,
  });

  @override
  List<Object?> get props => [subject, body];
}
