import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tajalwaqaracademy/features/StudentsManagement/presentation/ui/widgets/student_list_card_with_options.dart';
import 'package:tajalwaqaracademy/shared/themes/app_theme.dart';
import 'package:tajalwaqaracademy/core/constants/data.dart';
import '../../../../../config/di/injection.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../shared/widgets/frequency_selector.dart';
import '../../../../StudentsManagement/domain/entities/student_entity.dart';
import '../../bloc/halaqa_bloc.dart';
import 'halaqa_edit_screen.dart';

class HalaqaProfileScreen extends StatefulWidget {
  final String halaqaId;
  const HalaqaProfileScreen({super.key, required this.halaqaId});
  @override
  State<HalaqaProfileScreen> createState() => _HalaqaProfileScreenState();
}

class _HalaqaProfileScreenState extends State<HalaqaProfileScreen>
    with TickerProviderStateMixin {
  DateTime selectedDate = DateTime.now();

  List<String> pastTeachers = ["أ. محمد", "أ. علي", "أ. يوسف"];
  List<String> graduates = ["حسن", "ريان", "وفاء"];

  List<String> selectorItems = [
    "الطلاب",
    "الحفاظ",
    "الأداء",
    "الملاحظات",
    "التوجيه",
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

  late List<StudentDetailEntity> prevStudents;

  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: selectorItems.length, vsync: this);
    _tabController.addListener(() => setState(() {}));
    prevStudents = fakeStudents1;
    super.initState();
  }

  // Dialog list
  void _showListDialog(String title, List<String> items, String message) {
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.black45,
              insetPadding: EdgeInsets.all(10),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: EdgeInsets.all(10),
                  constraints: BoxConstraints(maxHeight: 450),
                  decoration: BoxDecoration(
                    color: AppColors.accent12,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.accent70, width: 0.7),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Text(
                          title,
                          style: GoogleFonts.cairo(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.lightCream,
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      Expanded(
                        child: items.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 24,
                                  ),
                                  child: Text(
                                    message,
                                    style: GoogleFonts.cairo(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              )
                            : Scrollbar(
                                thumbVisibility: true,
                                child: ListView.separated(
                                  // padding: EdgeInsets.symmetric(
                                  //   vertical: 5,
                                  // ),
                                  itemCount: items.length,
                                  separatorBuilder: (_, __) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    child: Divider(
                                      height: 1,
                                      color: AppColors.mediumDark87,
                                    ),
                                  ),
                                  itemBuilder: (_, i) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        items[i],
                                        style: GoogleFonts.cairo(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.lightCream,
                                        ),
                                      ),
                                      leading: Icon(
                                        Icons.check_circle_outline,
                                        color: AppColors.accent,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                      SizedBox(height: 12),
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
                                  color: AppColors.lightCream,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _openWeeklyDetail(_DashboardStat stat) {
    return Container(
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lightCream26),
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.mediumDark70, AppColors.darkBackground70],
        ),
      ),
      child: SingleChildScrollView(
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
                  child: Icon(stat.icon, size: 32, color: AppColors.lightCream),
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
                                  borderRadius: BorderRadius.circular(6),
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
                              .map((e) => FlSpot(e.key.toDouble(), e.value))
                              .toList(),
                          isCurved: true,
                          barWidth: 3,
                          color: AppColors.accent,
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [AppColors.accent, Colors.transparent],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) =>
                                FlDotCirclePainter(
                                  radius: 4,
                                  color: AppColors.accent,
                                  strokeWidth: 1,
                                  strokeColor: AppColors.lightCream,
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

            // const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Column(
      children: [
        SingleChildScrollView(
          child: Selector(
            items: selectorItems,
            selected: selectorItems[_tabController.index],
            onChanged: (value) {
              setState(() {
                _tabController.animateTo(value - 1);
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Divider(height: 2),
        ),
        Expanded(
          child: Center(
            child: TabBarView(
              controller: _tabController,
              children: [
                StudentListCardWithOptions(),
                Center(),
                _openWeeklyDetail(
                  _DashboardStat(
                    'الحضور',
                    '294',
                    Icons.check_circle,
                    gradients[0],
                    trends[0],
                  ),
                ),
                Center(),
                Center(),
              ],
            ),
          ),
        ),
      ],
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        // color: Theme.of(context).colorScheme.primaryContainer,
        // borderRadius: BorderRadius.circular(24),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness != Brightness.dark
              ? AppColors.accent70
              : Theme.of(context).colorScheme.onSurface,
          width: 0.5,
        ),
        gradient: LinearGradient(
          colors: [AppColors.mediumDark70, AppColors.mediumDark],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      // decoration: BoxDecoration(
      //   color: Theme.of(context).colorScheme.onSurface.withOpacity(0.20),
      //   borderRadius: BorderRadius.circular(20),
      //   border: Border.all(color: AppColors.mediumDark38),

      //   //   elevation: 6,
      //   // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      // ),
      // color: Theme.of(context).colorScheme.surface.withOpacity(0.85),
      child: BlocProvider.value(
        value: sl<HalaqaBloc>()..add(HalaqaDetailsFetched(widget.halaqaId)),
        child: BlocConsumer<HalaqaBloc, HalaqaState>(
          listener: (context, state) {
            // if (state.detailsStatus == HalaqaDetailsStatus.success) {
            //   // On success, close the dialog
            //   Navigator.of(context).pop();
            //   ScaffoldMessenger.of(context).showSnackBar(
            //     const SnackBar(
            //       content: Text('Halaqa saved successfully!'),
            //       backgroundColor: Colors.green,
            //     ),
            //   );
            // } else
            if (state.detailsStatus == HalaqaDetailsStatus.failure) {
              // On failure, show an error message

              // Now we can be more specific about the error.
              final failure = state.failure;
              String message;
              IconData icon;

              if (failure is NetworkFailure) {
                message = 'No Internet Connection. Please check your network.';
                icon = Icons.wifi_off;
              } else if (failure is CacheFailure) {
                message = 'Error reading from local data. Please try again.';
                icon = Icons.storage_rounded;
              } else {
                message = 'An unexpected error occurred.';
                icon = Icons.error_outline;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  backgroundColor: AppColors.accent,
                                ),
                                onPressed: () {
                                  // setState(() {
                                  //   residence.text = tempSelected;
                                  // });
                                  // Navigator.pop(context);
                                },
                                child: Text(
                                  "حاول مجددًا",
                                  style: GoogleFonts.cairo(
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
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            if ((state.detailsStatus == HalaqaDetailsStatus.success) &&
                (state.selectedHalaqa != null)) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.accent,
                          child: Icon(
                            Icons.group,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    state.selectedHalaqa!.name,
                                    style: GoogleFonts.cairo(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.lightCream,
                                    ),
                                  ),
                                  Text(
                                    state.selectedHalaqa!.country,
                                    style: GoogleFonts.cairo(
                                      fontSize: 14,
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                " •  ${state.selectedHalaqa!.teacherId}",
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  color: Colors.grey.shade300,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStat(
                          "الحفاظ",
                          pastTeachers.length.toString(),
                          Icons.school,
                        ),

                        _buildStat("التقييم", "4", Icons.star),
                        _buildStat("الطلاب", "20", Icons.people),
                      ],
                    ),
                  ],
                ),
              );
            } else {
              return Center();
            }
          },
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return GestureDetector(
      onTap: () {
        _showListDialog(label, pastTeachers, "لا يوجد $label");
      },
      child: Column(
        children: [
          Icon(icon, color: Colors.grey.shade300),
          SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.lightCream,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ملف الحلقة")),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => HalaqaEditScreen()),
        ),

        // highlightElevation: 40,
        extendedPadding: const EdgeInsets.all(12.0),
        label: SizedBox(
          height: 60,
          width: 60,
          child: Icon(Icons.edit, color: AppColors.lightCream, size: 20),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                // Header glass card
                _buildHeader(context),
                SizedBox(height: 8),
                Expanded(child: _buildTabs()),
              ],
            ),
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
