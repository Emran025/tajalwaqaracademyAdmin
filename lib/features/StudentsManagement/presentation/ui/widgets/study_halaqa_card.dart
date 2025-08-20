import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tajalwaqaracademy/shared/func/date_format.dart';

import 'package:tajalwaqaracademy/shared/themes/app_theme.dart';
import '../../../../../shared/widgets/avatar.dart';
import '../../../../../shared/widgets/taj.dart';
import '../../../domain/entities/halqa_entity.dart';

class StudyHalaqaCard extends StatefulWidget {
  final AssignedHalaqasEntity assignedHalaqasEntity;
  final VoidCallback? onPress;
  const StudyHalaqaCard({
    super.key,
    required this.assignedHalaqasEntity,
    required this.onPress,
  });

  @override
  State<StudyHalaqaCard> createState() => _StudyHalaqaCardState();
}

class _StudyHalaqaCardState extends State<StudyHalaqaCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.accent12,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accent70, width: 0.7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "📝 حلقة الطالب",
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(222, 233, 229, 229),
                ),
              ),
              GestureDetector(
                onTap: () => widget.onPress!(),
                child: Icon(Icons.edit, color: AppColors.accent70),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.accent12,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.accent70, width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 18),
              shape: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),

              title: Text(
                widget.assignedHalaqasEntity.name,
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightCream,
                ),
              ),
              leading: Avatar(size: Size(45, 45)),

              subtitle: Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  " الإنظمام : ${formatDate(DateTime.parse(widget.assignedHalaqasEntity.enrolledAt))}",
                  style: GoogleFonts.cairo(
                    fontSize: 10,
                    color: AppColors.lightCream,
                  ),
                ),
              ),
              onTap: () => {},
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () {
                      // onPressed!();
                    },
                    child: StatusTag(lable: "تقرير"),
                  ),
                  IconButton(
                    icon: Icon(Icons.more_vert, color: AppColors.lightCream),
                    onPressed: () => {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
