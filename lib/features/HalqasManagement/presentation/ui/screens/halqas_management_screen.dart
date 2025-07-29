import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tajalwaqaracademy/core/constants/app_colors.dart';
import 'package:tajalwaqaracademy/features/HalqasManagement/presentation/ui/screens/halqa_management_screen.dart';
import 'package:tajalwaqaracademy/features/HalqasManagement/presentation/ui/screens/halqa_requests_screen.dart';

class HalqasManagementScreen extends StatefulWidget {
  const HalqasManagementScreen({super.key});

  @override
  State<HalqasManagementScreen> createState() => _HalqasManagementScreenState();
}

class _HalqasManagementScreenState extends State<HalqasManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        toolbarHeight: 0,
        bottom: TabBar(
          labelStyle: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.accent,
          ),
          unselectedLabelStyle: GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.lightCream,
          ),
          dividerColor: AppColors.mediumDark,
          indicatorColor: AppColors.accent,
          controller: _tabController,
          tabs: const [
            Tab(text: "حلقات مكتملة"),
            Tab(text: "حلقات قيد الإنشاء"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [HalqaManagementScreen(), HalqaRequestsScreen()],
      ),
    );
  }
}
