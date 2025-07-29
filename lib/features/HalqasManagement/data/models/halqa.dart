import 'package:flutter/material.dart';
import 'package:tajalwaqaracademy/core/models/active_status.dart';
import 'package:tajalwaqaracademy/core/models/gender.dart';


class Halqa {
  String halqaID;
  String halqaName;
  final String country;
  final TimeOfDay availableTime;
  final Gender gender;
  final ActiveStatus status;
  String teacher;
  Halqa(
    this.halqaID,
    this.halqaName,
    this.country,
    this.availableTime,
    this.teacher, {
    this.status = ActiveStatus.active,
    this.gender = Gender.male,
  });
}
