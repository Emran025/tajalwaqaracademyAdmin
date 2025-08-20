import 'package:flutter/material.dart';
import 'package:tajalwaqaracademy/shared/themes/app_theme.dart';
import 'package:tajalwaqaracademy/core/constants/data.dart';
import 'package:tajalwaqaracademy/features/TeachersManagement/presentation/ui/screens/teacher_profile_screen.dart';
import 'package:tajalwaqaracademy/shared/widgets/avatar.dart';

import '../../../../../shared/widgets/caerd_tile.dart';
import '../../../domain/entities/teacher_list_item_entity.dart';

class TeacherRequestsScreen extends StatelessWidget {
  const TeacherRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: fakeTeachers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 5),
                  itemBuilder: (ctx, i) {
                    return _buildTeacherCard(fakeTeachers[i], ctx);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- UNIFIED Teacher Card Widget ---
  // We only need one card widget that works with the TeacherDetailEntity from our domain.
  Widget _buildTeacherCard(
    TeacherListItemEntity teacher,
    BuildContext context,
  ) {
    return CustomListListTile(
      title: teacher.name,
      moreIcon: Icons.more_vert,
      leading: Avatar(gender: teacher.gender, pic: teacher.avatar),
      subtitle: "${teacher.country} - ${teacher.city}",
      backgroundColor: AppColors.accent12,
      hasMoreIcon: false,
      tajLable: teacher.status.labelAr,
      border: Border.all(color: AppColors.accent70, width: 0.5),
      onMoreTab: () => {},
      onListTilePressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TeacherProfileScreen(teacherId: teacher.id),
          ),
        );
      },
      onTajPressed: () {},
    );
  }
}
