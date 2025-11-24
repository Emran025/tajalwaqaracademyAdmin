import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'support_ticket_model.g.dart';

@JsonSerializable()
class SupportTicketModel extends Equatable {
  final String subject;
  final String body;

  const SupportTicketModel({
    required this.subject,
    required this.body,
  });

  factory SupportTicketModel.fromJson(Map<String, dynamic> json) =>
      _$SupportTicketModelFromJson(json);

  Map<String, dynamic> toJson() => _$SupportTicketModelToJson(this);

  @override
  List<Object?> get props => [subject, body];
}
