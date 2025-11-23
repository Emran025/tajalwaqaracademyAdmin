import 'package:flutter/material.dart';

TimeOfDay stringToTimeOfDay(String time) {
  final parts = time.split(':');
  if (parts.length != 2) {
    return const TimeOfDay(hour: 0, minute: 0);
  }
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) {
    return const TimeOfDay(hour: 0, minute: 0);
  }
  return TimeOfDay(hour: hour, minute: minute);
}

String timeOfDayToString(TimeOfDay time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
