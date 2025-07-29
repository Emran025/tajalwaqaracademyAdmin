import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tajalwaqaracademy/core/constants/app_colors.dart';

class ModernDashboardScreen extends StatefulWidget {
  const ModernDashboardScreen({super.key});

  @override
  State<ModernDashboardScreen> createState() => _ModernDashboardScreenState();
}

class _ModernDashboardScreenState extends State<ModernDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  final List<_DashboardStat> stats = [
    _DashboardStat(
      'الحضور',
      '294',
      Icons.check_circle,
      gradients[0],
      trends[0],
    ),
    _DashboardStat('الطلاب', '342', Icons.group, gradients[1], trends[1]),
    _DashboardStat('المعلمين', '23', Icons.school, gradients[2], trends[2]),
    _DashboardStat('الحلقات', '57', Icons.book, gradients[3], trends[3]),
  ];

  static const List<List<double>> trends = [
    [300, 320, 310, 330, 340, 345, 342],
    [21, 22, 23, 23, 23, 23, 23],
    [50, 52, 54, 55, 56, 57, 57],
    [250, 260, 270, 280, 285, 290, 294],
  ];

  static const List<List<Color>> gradients = [
    [Color(0xFFA69F91), Color(0xFF3C3D37)],
    [AppColors.accent, AppColors.mediumDark],
    [Color(0xFFB4B6A5), Color(0xFF5C6D55)],
    [Color(0xFFFFA17F), Color(0xFF00223E)],
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildStatCard(_DashboardStat stat, int index) {
    return GestureDetector(
      onTap: () => _openWeeklyDetail(stat),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return FadeTransition(opacity: _controller, child: child);
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: stat.color,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: AppColors.lightCream26),

            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: stat.color.first.withOpacity(0.35),
                offset: const Offset(0, 6),
                blurRadius: 6,
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(stat.icon, size: 36, color: AppColors.lightCream),
              const SizedBox(height: 8),
              Text(
                stat.value,
                style: GoogleFonts.cairo(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightCream,
                ),
              ),
              Text(
                stat.title,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: AppColors.lightCream.withOpacity(0.85),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: LineChart(
                  LineChartData(
                    lineBarsData: [
                      LineChartBarData(
                        spots: stat.trend
                            .asMap()
                            .entries
                            .map((e) => FlSpot(e.key.toDouble(), e.value))
                            .toList(),
                        isCurved: true,
                        color: AppColors.lightCream.withOpacity(0.8),
                        dotData: FlDotData(show: false),
                        barWidth: 2,
                      ),
                    ],
                    gridData: FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(show: false),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openWeeklyDetail(_DashboardStat stat) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.6,
            maxChildSize: 0.85,
            builder: (context, scrollController) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.lightCream26),
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.mediumDark70,
                      AppColors.darkBackground70,
                    ],
                  ),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Drag handle
                      Container(
                        width: 75,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.lightCream70,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                      // Header with icon
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.lightCream12,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              stat.icon,
                              size: 32,
                              color: AppColors.lightCream,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "إحصائية أسبوعية",
                                style: GoogleFonts.cairo(
                                  color: AppColors.lightCream,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                stat.title,
                                style: GoogleFonts.cairo(
                                  color: AppColors.lightCream,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      AspectRatio(
                        aspectRatio: 3 / 2,
                        child: Stack(
                          children: [
                            /// خلفية الأعمدة
                            BarChart(
                              BarChartData(
                                barGroups: stat.trend
                                    .asMap()
                                    .entries
                                    .map(
                                      (e) => BarChartGroupData(
                                        x: e.key,
                                        barRods: [
                                          BarChartRodData(
                                            toY: e.value,
                                            width: 14,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.white.withOpacity(0.8),
                                                Colors.white.withOpacity(0.4),
                                              ],
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                    .toList(),
                                titlesData: FlTitlesData(show: false),
                                borderData: FlBorderData(show: false),
                                gridData: FlGridData(show: false),
                              ),
                            ),

                            /// خط بياني أعلى الأعمدة
                            LineChart(
                              LineChartData(
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: stat.trend
                                        .asMap()
                                        .entries
                                        .map(
                                          (e) =>
                                              FlSpot(e.key.toDouble(), e.value),
                                        )
                                        .toList(),
                                    isCurved: true,
                                    barWidth: 3,
                                    color: AppColors.accent,
                                    belowBarData: BarAreaData(
                                      show: true,
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.accent,
                                          Colors.transparent,
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                    dotData: FlDotData(
                                      show: true,
                                      getDotPainter:
                                          (spot, percent, barData, index) =>
                                              FlDotCirclePainter(
                                                radius: 4,
                                                color: AppColors.accent,
                                                strokeWidth: 1,
                                                strokeColor:
                                                    AppColors.lightCream,
                                              ),
                                    ),
                                  ),
                                ],
                                titlesData: FlTitlesData(show: false),
                                borderData: FlBorderData(show: false),
                                gridData: FlGridData(show: false),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Stats summary
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildMiniStat(
                            "المعدل",
                            "${stat.trend.reduce((a, b) => a + b) ~/ stat.trend.length}",
                          ),
                          _buildMiniStat(
                            "أعلى قيمة",
                            "${stat.trend.reduce((a, b) => a > b ? a : b)}",
                          ),
                          _buildMiniStat(
                            "أقل قيمة",
                            "${stat.trend.reduce((a, b) => a < b ? a : b)}",
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppColors.accent70),
                              ),
                              child: Text(
                                "اغلاق",
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  color: AppColors.lightCream,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // Mini stat widget
  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.cairo(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // تنفيذ إجراءات سريعة هنا
        },
        label: Text(
          "إجراء سريع",
          style: GoogleFonts.cairo(color: AppColors.lightCream),
        ),
        icon: Icon(Icons.flash_on, color: AppColors.lightCream),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 14, right: 14, top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "الإحصائيات العامة",
                style: GoogleFonts.cairo(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightCream,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  itemCount: stats.length,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (_, i) => _buildStatCard(stats[i], i),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "📢 آخر التنبيهات",
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightCream,
                ),
              ),
              const SizedBox(height: 12),
              const _NotificationCard(
                title: "تمت إضافة حلقة جديدة بإشراف الشيخ خالد",
                timeAgo: "منذ ٣ دقائق",
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardStat {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> color;
  final List<double> trend;

  const _DashboardStat(
    this.title,
    this.value,
    this.icon,
    this.color,
    this.trend,
  );
}

class _NotificationCard extends StatelessWidget {
  final String title;
  final String timeAgo;

  const _NotificationCard({required this.title, required this.timeAgo});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accent12,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent70, width: 0.5),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: ListTile(
        leading: Icon(Icons.notifications_active, color: AppColors.lightCream),
        title: Text(
          title,
          style: GoogleFonts.cairo(color: AppColors.lightCream),
        ),
        subtitle: Text(
          timeAgo,
          style: GoogleFonts.cairo(fontSize: 12, color: AppColors.accent70),
        ),
        onTap: () {},
      ),
    );
  }
}
