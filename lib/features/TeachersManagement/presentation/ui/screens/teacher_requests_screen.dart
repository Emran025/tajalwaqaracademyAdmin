import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tajalwaqaracademy/core/constants/app_colors.dart';
import 'package:tajalwaqaracademy/core/constants/data.dart';
import 'package:tajalwaqaracademy/features/TeachersManagement/presentation/ui/screens/teacher_profile_screen.dart';
import 'package:tajalwaqaracademy/shared/widgets/avatar.dart';
import 'package:tajalwaqaracademy/shared/widgets/taj.dart';

import '../../../domain/entities/teacher_entity.dart';

class TeacherRequestsScreen extends StatelessWidget {
  const TeacherRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: fakeTeachers2.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 5),
                  itemBuilder: (ctx, i) {
                    return _buildTeacherCard(fakeTeachers2[i], ctx);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeacherCard(TeacherDetailEntity teacher, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.accent12,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent70, width: 0.5),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: ListTile(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TeacherProfileScreen(
                teacherId: teacher.id,
                // nameArabic: state.signInModel.nameArabic,
              ),
            ),
          );
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 15),
        shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        leading: Avatar(gender: teacher.gender), //, pic: teacher.pic),
        title: Text(
          teacher.name,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: AppColors.lightCream,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: Text(
            "${teacher.country} - ${teacher.city}",
            style: GoogleFonts.cairo(fontSize: 12, color: AppColors.lightCream),
          ),
        ),
        trailing: StatusTag(status: teacher.status),
      ),
    );
  }
}
