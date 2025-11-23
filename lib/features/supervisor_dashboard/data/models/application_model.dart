// application_model.dart
import 'package:equatable/equatable.dart';
import 'package:tajalwaqaracademy/core/models/active_status.dart';
import 'package:tajalwaqaracademy/core/models/gender.dart';
import 'package:tajalwaqaracademy/core/models/user_role.dart';
import '../../../../core/entities/list_item_entity.dart';
import '../../../../core/models/pagination_info_model.dart';
import '../../domain/entities/application_entity.dart';

class ApplicationModel extends Equatable {
  final UserRole applicationType;
  final String submittedAt;
  final UserModel user;

  const ApplicationModel({
    required this.applicationType,
    required this.submittedAt,
    required this.user,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      applicationType: UserRole.fromLabel(json['application_type'] as String),

      submittedAt: json['submitted_at'] as String? ?? "${DateTime.now()}",
      user: UserModel.fromJson(
        json['user'] as Map<String, dynamic>,
        json['status'] as String,
        json['id'] as int,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'application_type': applicationType,
      'submitted_at': submittedAt,
      'user': user.toJson(),
    };
  }

  ApplicationEntity toEntity() {
    return ApplicationEntity(
      id: user.id,
      applicationType: applicationType,
      status: user.status,
      submittedAt: submittedAt,
      user: user.toEntity(),
    );
  }

  @override
  List<Object?> get props => [applicationType, submittedAt, user];
}

class UserModel extends Equatable {
  final int id;
  final String name;
  final Gender gender;
  final String residence;
  final String city;
  final String country;
  final String email;
  final String avatar;
  final String status;
  const UserModel({
    required this.id,
    required this.name,
    required this.gender,
    required this.residence,
    required this.city,
    required this.country,
    required this.email,
    required this.avatar,
    required this.status,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String status, int id) {
    return UserModel(
      id: id,
      name: json['name'] as String,
      gender: Gender.fromLabel(json['gender'] as String),
      residence: json['residence'] as String? ?? "",
      city: json['city'] as String,
      country: json['country'] as String,
      email: json['email'] as String,
      avatar: json['avatar'] as String,
      status: status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'residence': residence,
      'gender': gender.label,
      'city': city,
      'country': country,
      'email': email,
      'avatar': avatar,
      'status': status,
    };
  }

  ListItemEntity toEntity() {
    return ListItemEntity(
      id: id.toString(),
      name: name,
      gender: gender,
      avatar: avatar,
      country: country,
      city: city,
      status: ActiveStatus.fromLabel(status),
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    gender,
    status,
    residence,
    city,
    country,
    email,
    avatar,
  ];
}

class PaginatedApplicationsResponse {
  final bool success;
  final List<ApplicationModel> data;
  final PaginationInfo pagination;

  PaginatedApplicationsResponse({
    required this.success,
    required this.data,
    required this.pagination,
  });

  factory PaginatedApplicationsResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedApplicationsResponse(
      success: json['success'] as bool,
      data: (json['data'] as List)
          .map(
            (item) => ApplicationModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      pagination: PaginationInfo.fromJson(
        json['pagination'] as Map<String, dynamic>,
      ),
    );
  }
}
