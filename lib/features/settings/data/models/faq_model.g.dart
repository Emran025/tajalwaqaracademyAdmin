// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'faq_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FaqModel _$FaqModelFromJson(Map<String, dynamic> json) => FaqModel(
      id: json['id'] as int,
      question: json['question'] as String,
      answer: json['answer'] as String,
      viewCount: json['view_count'] as int,
      isActive: json['is_active'] as int,
      displayOrder: json['display_order'] as int,
    );

Map<String, dynamic> _$FaqModelToJson(FaqModel instance) => <String, dynamic>{
      'id': instance.id,
      'question': instance.question,
      'answer': instance.answer,
      'view_count': instance.viewCount,
      'is_active': instance.isActive,
      'display_order': instance.displayOrder,
    };

FaqResponseModel _$FaqResponseModelFromJson(Map<String, dynamic> json) =>
    FaqResponseModel(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => FaqModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FaqResponseModelToJson(FaqResponseModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };
