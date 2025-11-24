import 'package:tajalwaqaracademy/features/supervisor_dashboard/domain/entities/applicant_profile_entity.dart';

class ApplicantProfileModel extends ApplicantProfileEntity {
  const ApplicantProfileModel({
    required super.id,
    required super.userId,
    required super.schoolId,
    required super.applicationType,
    required super.status,
    required super.bio,
    required super.qualifications,
    required super.intentStatement,
    required super.rejectionReason,
    required super.submittedAt,
    required super.createdAt,
    required super.updatedAt,
    required super.user,
  });

  factory ApplicantProfileModel.fromJson(Map<String, dynamic> json) {
    return ApplicantProfileModel(
      id: json['id'],
      userId: json['user_id'],
      schoolId: json['school_id'],
      applicationType: json['application_type'],
      status: json['status'],
      bio: json['bio'],
      qualifications: json['qualifications'],
      intentStatement: json['intent_statement'],
      rejectionReason: json['rejection_reason'],
      submittedAt: json['submitted_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      user: UserModel.fromJson(json['user']),
    );
  }
}

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.emailVerifiedAt,
    required super.avatar,
    required super.phone,
    required super.phoneZone,
    required super.whatsapp,
    required super.whatsappZone,
    required super.gender,
    required super.birthDate,
    required super.country,
    required super.city,
    required super.residence,
    required super.status,
    required super.schoolId,
    required super.createdAt,
    required super.updatedAt,
    required super.deletedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      emailVerifiedAt: json['email_verified_at'],
      avatar: json['avatar'],
      phone: json['phone'],
      phoneZone: json['phone_zone'],
      whatsapp: json['whatsapp'],
      whatsappZone: json['whatsapp_zone'],
      gender: json['gender'],
      birthDate: json['birth_date'],
      country: json['country'],
      city: json['city'],
      residence: json['residence'],
      status: json['status'],
      schoolId: json['school_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      deletedAt: json['deleted_at'],
    );
  }
}
