// application_model.dart
import 'package:equatable/equatable.dart';
import 'package:tajalwaqaracademy/core/models/user_role.dart';
import '../../../../core/entities/list_item_entity.dart';


class ApplicationEntity extends Equatable {
  final int id;
  final UserRole applicationType;
  final String status;
  final String submittedAt;
  final ListItemEntity user;

  const ApplicationEntity({
    required this.id,
    required this.applicationType,
    required this.status,
    required this.submittedAt,
    required this.user,
  });

  @override
  List<Object?> get props => [id, applicationType, status, submittedAt, user];
}
