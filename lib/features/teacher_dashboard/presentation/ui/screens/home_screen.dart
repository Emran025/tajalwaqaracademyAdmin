import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tajalwaqaracademy/shared/themes/app_theme.dart';
// import 'package:tajalwaqaracademy/features/HalqasManagement/presentation/ui/screens/halqas_management_screen.dart';
// import 'package:tajalwaqaracademy/features/StudentsManagement/presentation/ui/screens/students_management_screen.dart';
import 'package:tajalwaqaracademy/shared/widgets/avatar.dart';

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
                      _buildDrawerItem(
                        Icons.dashboard_outlined,
                        headers[0],
                        () {
                          Navigator.pop(context);
                          setState(() {
                            _currentIndex = 0;
                          });
                        },
                      ),
                      _buildDrawerItem(
                        Icons.analytics_outlined,
                        headers[1],
                        () {
                          Navigator.pop(context);
                          setState(() {
                            _currentIndex = 1;
                          });
                        },
                      ),
                      _buildDrawerItem(Icons.settings, "الإعدادات", () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return const SettingsScreen();
                            },
                          ),
                        );
                      }),
                      _buildDrawerItem(Icons.logout, "تسجيل الخروج", () {
                        Navigator.pop(context);
                      }),
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
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback? onTap) {
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
        onTap!();
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
