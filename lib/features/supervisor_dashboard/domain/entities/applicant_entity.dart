// applicant_model.dart
import 'package:equatable/equatable.dart';
import 'package:tajalwaqaracademy/core/models/user_role.dart';
import '../../../../core/entities/list_item_entity.dart';

class ApplicantEntity extends Equatable {
  final int id;
  final UserRole applicantType;
  final String status;
  final String submittedAt;
  final ListItemEntity user;

  const ApplicantEntity({
    required this.id,
    required this.applicantType,
    required this.status,
    required this.submittedAt,
    required this.user,
  });

  @override
  List<Object?> get props => [id, applicantType, status, submittedAt, user];
}
