import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'faq_model.g.dart';

@JsonSerializable()
class FaqModel extends Equatable {
  final int id;
  final String question;
  final String answer;
  @JsonKey(name: 'view_count')
  final int viewCount;
  @JsonKey(name: 'is_active')
  final int isActive;
  @JsonKey(name: 'display_order')
  final int displayOrder;

  const FaqModel({
    required this.id,
    required this.question,
    required this.answer,
    required this.viewCount,
    required this.isActive,
    required this.displayOrder,
  });

  factory FaqModel.fromJson(Map<String, dynamic> json) =>
      _$FaqModelFromJson(json);

  Map<String, dynamic> toJson() => _$FaqModelToJson(this);

  @override
  List<Object?> get props => [
        id,
        question,
        answer,
        viewCount,
        isActive,
        displayOrder,
      ];
}

@JsonSerializable()
class FaqResponseModel extends Equatable {
  final bool success;
  final String message;
  final List<FaqModel> data;

  const FaqResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory FaqResponseModel.fromJson(Map<String, dynamic> json) =>
      _$FaqResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$FaqResponseModelToJson(this);

  @override
  List<Object?> get props => [success, message, data];
}
