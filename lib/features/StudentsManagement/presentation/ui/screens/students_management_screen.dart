import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/di/injection.dart';
import '../../bloc/student_bloc.dart';
import 'student_management_screen.dart';
import 'student_requests_screen.dart';

class StudentsManagementScreen extends StatefulWidget {
  const StudentsManagementScreen({super.key});

  @override
  State<StudentsManagementScreen> createState() =>
      _StudentsManagementScreenState();
}

class _StudentsManagementScreenState extends State<StudentsManagementScreen>
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
      create: (context) => sl<StudentBloc>(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          toolbarHeight: 0,
          // title: const Text("إدارة الطالبين"),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: "الطلاب الحاليون"),
              Tab(text: "طلبات التقديم"),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [StudentManagementScreen(), StudentRequestsScreen()],
        ),
      ),
    );
  }
}
