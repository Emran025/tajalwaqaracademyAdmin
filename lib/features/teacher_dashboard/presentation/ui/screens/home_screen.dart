import 'package:flutter/material.dart';
import 'package:tajalwaqaracademy/shared/themes/app_theme.dart';
// import 'package:tajalwaqaracademy/features/HalqasManagement/presentation/ui/screens/halqas_management_screen.dart';
// import 'package:tajalwaqaracademy/features/StudentsManagement/presentation/ui/screens/students_management_screen.dart';
import 'package:tajalwaqaracademy/shared/widgets/avatar.dart';

import '../../../../../shared/widgets/recitation_mode_sidebar.dart';
import '../../../../settings/presentation/screens/settings_screen.dart';
import 'modern_dashboard_screen.dart';
import 'supervisor_monitoring_screen.dart';

// import '../../../../../core/constants/app_colors.dart';

class TecherDashboard extends StatefulWidget {
  const TecherDashboard({super.key});

  @override
  State<TecherDashboard> createState() => _TecherDashboardState();
}

class _TecherDashboardState extends State<TecherDashboard> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    ModernDashboardScreen(),
    // HalqasManagementScreen(),
    // StudentsManagementScreen(),
    SupervisorMonitoringScreen(),
  ];
  final List<String> headers = ["الرئيسية", "المتابعة الشاملة"];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: AppColors.darkBackground,
        appBar: AppBar(
          title: Text(headers[_currentIndex]),
          actions: [
            IconButton(
              icon: Icon(Icons.notifications_active_outlined, size: 30),
              onPressed: () {},
            ),
          ],
        ),

        drawer: RecitationModeSideBar(
          title: "مرحباً، عمران",
          avatar: Avatar(size: Size(100, 100)),
          items: [
            CustomModeIconButton(
              icon: Icons.dashboard_outlined,
              label: headers[0],
              isSelected: _currentIndex == 0,
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 0;
                });
              },
            ),
            CustomModeIconButton(
              icon: Icons.analytics_outlined,
              label: headers[1],
              isSelected: _currentIndex == 1,
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 1;
                });
              },
            ),
            CustomModeIconButton(
              isSelected: false,
              label: "الإعدادات",
              icon: Icons.settings,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const SettingsScreen();
                    },
                  ),
                );
              },
            ),
            CustomModeIconButton(
              icon: Icons.logout,
              label: "تسجيل الخروج",
              isSelected: false,
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),

        body: Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(child: _tabs[_currentIndex]),
        ),
      ),
    );
  }
}
