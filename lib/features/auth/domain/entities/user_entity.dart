// domain/entities/user_entity.dart

import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final int id;
  final int roleId;
  final String status;
  final String name;
  final String gender;
  final String? birthDate;
  final String email;
  final String? avatar;
  final String? phoneZone;
  final String phone;
  final String? whatsappZone;
  final String? whatsapp;
  final String? qualification;
  final int? experienceYears;
  final String? country;
  final String? residence;
  final String? city;
  final String? availableTime;
  final String? stopReasons;
  final String? memorizationLevel;

  const UserEntity({
    required this.id,
    required this.roleId,
    required this.status,
    required this.name,
    required this.gender,
    this.birthDate,
    required this.email,
    this.avatar,
    this.phoneZone,
    required this.phone,
    this.whatsappZone,
    this.whatsapp,
    this.qualification,
    this.experienceYears,
    this.country,
    this.residence,
    this.city,
    this.availableTime,
    this.stopReasons,
    this.memorizationLevel,
  });

  @override
  List<Object?> get props => [id, email, name, roleId];
}
