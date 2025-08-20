import 'package:flutter/material.dart';
import 'package:tajalwaqaracademy/shared/themes/app_theme.dart';
import 'package:tajalwaqaracademy/core/constants/data.dart';
import '../../../../../shared/widgets/caerd_tile.dart';
import '../../../domain/entities/student_list_item_entity.dart';
import '../../../presentation/ui/screens/student_profile_screen.dart';
import 'package:tajalwaqaracademy/shared/widgets/avatar.dart';

class StudentRequestsScreen extends StatefulWidget {
  const StudentRequestsScreen({super.key});

  @override
  State<StudentRequestsScreen> createState() => _StudentRequestsScreenState();
}

class _StudentRequestsScreenState extends State<StudentRequestsScreen> {
  late List<StudentListItemEntity> requests;

  @override
  void initState() {
    requests = fakeStudents;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: requests.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 5),
                  itemBuilder: (ctx, i) {
                    return _buildStudentCard(requests[i]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- UNIFIED Student Card Widget ---
  // We only need one card widget that works with the StudentDetailEntity from our domain.

  Widget _buildStudentCard(StudentListItemEntity student) {
    return CustomListListTile(
      title: student.name,
      moreIcon: Icons.more_vert,
      leading: Avatar(gender: student.gender, pic: student.avatar),
      subtitle: "${student.country} - ${student.city}",
      backgroundColor: AppColors.accent12,
      hasMoreIcon: false,
      tajLable: student.status.labelAr,
      border: Border.all(color: AppColors.accent70, width: 0.5),
      onMoreTab: () => {},
      onListTilePressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => StudentProfileScreen(studentID: student.id),
          ),
        );
      },
      onTajPressed: () {},
    );
  }
}
