import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tajalwaqaracademy/config/di/injection.dart';
import 'package:tajalwaqaracademy/core/constants/app_colors.dart';
import 'package:tajalwaqaracademy/features/TeachersManagement/presentation/bloc/teacher_bloc.dart';
import 'package:tajalwaqaracademy/features/TeachersManagement/presentation/ui/screens/teacher_management_screen.dart';
import 'package:tajalwaqaracademy/features/TeachersManagement/presentation/ui/screens/teacher_requests_screen.dart';

class TeachersManagementScreen extends StatefulWidget {
  const TeachersManagementScreen({super.key});

  @override
  State<TeachersManagementScreen> createState() =>
      _TeachersManagementScreenState();
}

class _TeachersManagementScreenState extends State<TeachersManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<TeacherBloc>(),
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        appBar: AppBar(
          toolbarHeight: 0,
          // title: const Text("إدارة المعلمين"),
          bottom: TabBar(
            labelStyle: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.lightCream54,
            ),
            unselectedLabelStyle: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.lightCream,
            ),

            dividerColor: Colors.black12,
            indicatorColor: AppColors.accent,
            controller: _tabController,
            tabs: const [
              Tab(text: "المعلمون الحاليون"),
              Tab(text: "طلبات التقديم"),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [TeacherManagementScreen(), TeacherRequestsScreen()],
        ),
      ),
    );
  }
}
