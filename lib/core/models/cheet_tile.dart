import 'package:flutter/material.dart';

class ChartTile {
  final String title;
  final String subTitle;
  final IconData icon;
  final List<Color> color;

  const ChartTile({
    required this.title,
    required this.subTitle,
    required this.icon,
    this.color = Colors.accents,
  });
}
