// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_ticket_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupportTicketModel _$SupportTicketModelFromJson(Map<String, dynamic> json) =>
    SupportTicketModel(
      subject: json['subject'] as String,
      body: json['body'] as String,
    );

Map<String, dynamic> _$SupportTicketModelToJson(SupportTicketModel instance) =>
    <String, dynamic>{
      'subject': instance.subject,
      'body': instance.body,
    };
