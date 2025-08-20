import 'package:flutter/material.dart';
import 'package:tajalwaqaracademy/shared/themes/app_theme.dart';
import 'package:tajalwaqaracademy/features/StudentsManagement/presentation/ui/screens/students_continuous_monitoring.dart';

import '../../../../HalaqasManagement/presentation/ui/screens/halqas_continuous_monitoring.dart';

class SupervisorMonitoringScreen extends StatefulWidget {
  const SupervisorMonitoringScreen({super.key});

  @override
  State<SupervisorMonitoringScreen> createState() =>
      _SupervisorMonitoringScreenState();
}

class _SupervisorMonitoringScreenState extends State<SupervisorMonitoringScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          bottom: TabBar(
            // labelStyle: GoogleFonts.cairo(
            //   fontSize: 14,
            //   fontWeight: FontWeight.bold,
            //   color: AppColors.lightCream54,
            // ),
            // unselectedLabelStyle: GoogleFonts.cairo(
            //   fontSize: 12,
            //   fontWeight: FontWeight.bold,
            //   color: AppColors.lightCream,
            // ),
            indicatorColor: AppColors.accent,
            controller: _tabController,
            dividerColor: Colors.black12,

            tabs: [
              Tab(text: "الحلقات"),
              Tab(text: "الطلاب"),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            HalaqasContinuousMonitoring(),
            StudentsContinuousMonitoring(),
          ],
        ),
      ),
    );
  }
}
