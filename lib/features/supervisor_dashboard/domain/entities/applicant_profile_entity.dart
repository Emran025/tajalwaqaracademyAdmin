import 'package:equatable/equatable.dart';

class ApplicantProfileEntity extends Equatable {
  final int id;
  final int userId;
  final int schoolId;
  final String applicationType;
  final String status;
  final String? bio;
  final String? qualifications;
  final String? intentStatement;
  final String? rejectionReason;
  final String? submittedAt;
  final String createdAt;
  final String updatedAt;
  final UserEntity user;

  const ApplicantProfileEntity({
    required this.id,
    required this.userId,
    required this.schoolId,
    required this.applicationType,
    required this.status,
    this.bio,
    this.qualifications,
    this.intentStatement,
    this.rejectionReason,
    this.submittedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        schoolId,
        applicationType,
        status,
        bio,
        qualifications,
        intentStatement,
        rejectionReason,
        submittedAt,
        createdAt,
        updatedAt,
        user,
      ];
}

class UserEntity extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? emailVerifiedAt;
  final String avatar;
  final String phone;
  final String phoneZone;
  final String? whatsapp;
  final String whatsappZone;
  final String gender;
  final String birthDate;
  final String country;
  final String city;
  final String? residence;
  final String status;
  final int schoolId;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    required this.avatar,
    required this.phone,
    required this.phoneZone,
    this.whatsapp,
    required this.whatsappZone,
    required this.gender,
    required this.birthDate,
    required this.country,
    required this.city,
    this.residence,
    required this.status,
    required this.schoolId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        emailVerifiedAt,
        avatar,
        phone,
        phoneZone,
        whatsapp,
        whatsappZone,
        gender,
        birthDate,
        country,
        city,
        residence,
        status,
        schoolId,
        createdAt,
        updatedAt,
        deletedAt,
      ];
}
