import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tajalwaqaracademy/core/constants/app_colors.dart';
import 'package:tajalwaqaracademy/features/HalqasManagement/presentation/ui/screens/halqas_management_screen.dart';
import 'package:tajalwaqaracademy/features/StudentsManagement/presentation/ui/screens/students_management_screen.dart';
import 'package:tajalwaqaracademy/features/TeachersManagement/presentation/ui/screens/teachers_management_screen.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/presentation/ui/screens/modern_dashboard_screen.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/presentation/ui/screens/supervisor_monitoring_screen.dart';
import 'package:tajalwaqaracademy/shared/widgets/avatar.dart';

// import '../../../../../core/constants/app_colors.dart';

class SupervisorDashboard extends StatefulWidget {
  const SupervisorDashboard({super.key});

  @override
  State<SupervisorDashboard> createState() => _SupervisorDashboardState();
}

class _SupervisorDashboardState extends State<SupervisorDashboard> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    ModernDashboardScreen(),
    TeachersManagementScreen(),
    StudentsManagementScreen(),
    HalqasManagementScreen(),
    // Center(child: Text("الحلقات")),
    SupervisorMonitoringScreen(),
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
        backgroundColor: AppColors.darkBackground,
        appBar: AppBar(
          title: Text(
            headers[_currentIndex],
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              color: AppColors.lightCream,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.notifications_active_outlined, size: 30),
              onPressed: () {},
            ),
          ],
        ),

        drawer: Drawer(
          backgroundColor: AppColors.accent,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.accent, AppColors.darkBackground],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),

            child: Column(
              children: [
                ClipPath(
                  clipper: _HeaderClipper(),
                  child: Container(
                    color: AppColors.mediumDark,
                    width: double.infinity,
                    height: 200,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Avatar(size: Size(100, 100)),
                        SizedBox(width: 12),
                        Text(
                          "مرحباً، عمران",
                          style: GoogleFonts.cairo(
                            color: AppColors.lightCream,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _buildDrawerItem(Icons.person, "ملفي الشخصي"),
                      _buildDrawerItem(Icons.settings, "إدارة الإعدادات"),
                      _buildDrawerItem(Icons.security, " إدارة الصلاحيات"),
                      _buildDrawerItem(Icons.logout, "تسجيل الخروج"),
                    ],
                  ),
                ),
              ],
            ),
          ),
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

  Widget _buildDrawerItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: GoogleFonts.cairo(
          fontWeight: FontWeight.bold,
          color: AppColors.lightCream70,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        print("الانتقال إلى $title");
      },
    );
  }
}

// Clipper مخصص
class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final p = Path();
    p.lineTo(0, size.height - 40);
    p.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 40,
    );
    p.lineTo(size.width, 0);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> old) => false;
}
