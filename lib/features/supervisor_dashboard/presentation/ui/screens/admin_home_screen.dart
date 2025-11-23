import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tajalwaqaracademy/shared/themes/app_theme.dart';
import 'package:tajalwaqaracademy/features/StudentsManagement/presentation/ui/screens/students_management_screen.dart';
import 'package:tajalwaqaracademy/features/TeachersManagement/presentation/ui/screens/teachers_management_screen.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/presentation/ui/screens/modern_dashboard_screen.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/presentation/ui/screens/supervisor_monitoring_screen.dart';
import 'package:tajalwaqaracademy/shared/widgets/avatar.dart';
import 'package:tajalwaqaracademy/shared/widgets/recitation_mode_sidebar.dart';

import '../../../../../core/models/user_role.dart';
import '../../../../HalaqasManagement/presentation/ui/screens/halaqas_management_screen.dart';
import '../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../auth/presentation/ui/widgets/log_out_dialog.dart';
import '../../../../settings/presentation/screens/settings_screen.dart';

// import '../../../../../core/constants/app_colors.dart';

class SupervisorDashboard extends StatefulWidget {
  const SupervisorDashboard({super.key});

  @override
  State<SupervisorDashboard> createState() => _SupervisorDashboardState();
}

class _SupervisorDashboardState extends State<SupervisorDashboard> {
  int _currentIndex = 0;
  final List<Widget> _tabs = [
    ModernDashboardScreen(role: UserRole.supervisor),
    
    TeachersManagementScreen(),
    StudentsManagementScreen(),
    HalaqaManagementScreen(),
    MonitoringScreen(),
  ];
  final List<String> headers = [
    "الرئيسية",
    "إدارة المعلمين",
    "إدارة الطلاب",
    "إدارة الحلقات",
    "المتابعة الشاملة",
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            headers[_currentIndex],
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
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
              icon: Icons.person,
              label: "ملفي الشخصي",
              isSelected: false,
              onTap: () {},
            ),
            CustomModeIconButton(
              icon: Icons.settings,
              label: "الإعدادات",
              isSelected: false,
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
              icon: Icons.security,
              label: " إدارة الصلاحيات",
              isSelected: false,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            CustomModeIconButton(
              icon: Icons.logout,
              label: "تسجيل الخروج",
              isSelected: false,
              onTap: () {
                Navigator.pop(context);
                // _showLoginDialog();
                _showLogoutDialog();
              },
            ),
          ],
        ),

        body: Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(child: _tabs[_currentIndex]),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.only(bottom: 5, top: 5),
          decoration: BoxDecoration(
            color: AppColors.mediumDark,
            // borderRadius: BorderRadius.circular(24),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: AppColors.lightCream,
            unselectedItemColor: AppColors.lightCream54,
            showUnselectedLabels: true,
            onTap: (index) => setState(() => _currentIndex = index),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                label: 'الرئيسية',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.school_outlined),
                label: 'المعلمين',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.group_outlined),
                label: 'الطلاب',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.book_outlined),
                label: 'الحلقات',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.analytics_outlined),
                label: 'المتابعة',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => BlocProvider.value(
        value: context.read<AuthBloc>(),
        child: const LogoutConfirmationDialog(),
      ),
    );
  }
}
