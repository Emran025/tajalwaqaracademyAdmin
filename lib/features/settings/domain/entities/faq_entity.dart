import 'package:equatable/equatable.dart';

class FaqEntity extends Equatable {
  final int id;
  final String question;
  final String answer;
  final int viewCount;

  const FaqEntity({
    required this.id,
    required this.question,
    required this.answer,
    required this.viewCount,
  });

  @override
  List<Object?> get props => [id, question, answer, viewCount];
}
