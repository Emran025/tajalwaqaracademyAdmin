import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tajalwaqaracademy/shared/themes/app_theme.dart';
import 'package:tajalwaqaracademy/core/constants/data.dart';
import 'package:tajalwaqaracademy/core/models/report_frequency.dart';
import 'package:tajalwaqaracademy/features/StudentsManagement/domain/entities/student_entity.dart';
import 'package:tajalwaqaracademy/shared/func/date_format.dart';

import 'package:tajalwaqaracademy/shared/widgets/avatar.dart';
import 'package:tajalwaqaracademy/shared/widgets/frequency_selector.dart';
import 'package:tajalwaqaracademy/shared/widgets/horizontal_calendar_date_picker.dart';

import '../../../../../config/di/injection.dart';
import '../../../../../core/models/active_status.dart';
import '../../../../../shared/widgets/caerd_tile.dart';
import '../../bloc/student_bloc.dart';
import '../../view_models/follow_up_report_bundle_entity.dart';
import '../../view_models/factories/follow_up_report_factory.dart';
import 'follow_up_report_dialog.dart';
import 'student_profile_screen.dart';

class StudentsContinuousMonitoring extends StatefulWidget {
  const StudentsContinuousMonitoring({super.key});

  @override
  State<StudentsContinuousMonitoring> createState() =>
      _StudentsContinuousMonitoringState();
}

class _StudentsContinuousMonitoringState
    extends State<StudentsContinuousMonitoring>
    with TickerProviderStateMixin {
  late List<StudentDetailEntity> students;

  DateTime selectedDate = DateTime.now();
  String reportType = 'يومي'; // أو 'أسبوعي', 'شهري'

  Frequency _freq = Frequency.daily; // التردد الافتراضي

  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    students = [
      ...fakeStudents1,
      ...fakeStudents1,
      ...fakeStudents1,
      ...fakeStudents1,
    ];
    super.initState();
    // Add a listener to the scroll controller to detect when the user reaches the end.
  }

  // This is the correct place to trigger the initial data fetch.
  // We do it in the BlocProvider's create method.

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Column(
      children: [
        SizedBox(height: 8),
        FrequencySelector(
          selected: _freq,
          onChanged: (newFreq) {
            setState(() {
              _freq = newFreq;
              reportType = _freq.labelAr;
            });
          },
        ),

        HorizontalCalendarDatePicker(
          startDate: DateTime.now().subtract(const Duration(days: 60)),
          endDate: DateTime.now().add(const Duration(days: 60)),
          initialDate: DateTime.now(),
          onDateSelected: (date) {
            setState(() {
              selectedDate = date;
            });
          },
        ),

        Expanded(
          child: CustomScrollView(
            physics: NeverScrollableScrollPhysics(),
            slivers: [
              // 1) القسم العلوي: هيدر التقرير
              SliverToBoxAdapter(
                child: _buildSectionHeader(
                  'تقرير $reportType المفترض رفعه يوم  ${formatDate(selectedDate)}',
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: accent,
                    dividerColor: Colors.black12,
                    unselectedLabelColor: AppColors.lightCream54,
                    padding: const EdgeInsets.only(top: 16.0),
                    tabs: [
                      Tab(
                        icon: Icon(Icons.warning, color: AppColors.accent),
                        child: Row(
                          children: [
                            Text(
                              "المتوقع",
                              style: Theme.of(context).textTheme.bodyLarge!,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "(31)",
                              style: Theme.of(context).textTheme.bodyLarge!,
                            ),
                          ],
                        ),
                      ),
                      Tab(
                        icon: Icon(Icons.upload, color: AppColors.accent),
                        child: Row(
                          children: [
                            Text(
                              "المرسل",
                              style: Theme.of(context).textTheme.bodyLarge!,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "(27)",
                              style: Theme.of(context).textTheme.bodyLarge!,
                            ),
                          ],
                        ),
                      ),
                      Tab(
                        icon: Icon(Icons.person_off, color: AppColors.accent),
                        child: Row(
                          children: [
                            Text(
                              "المتبقي",
                              style: Theme.of(context).textTheme.bodyLarge!,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "(5)",
                              style: Theme.of(context).textTheme.bodyLarge!,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 4) الـTabBarView ياخذ بقية المساحة
              SliverFillRemaining(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 5,
                  ),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildStudentsList(),
                      _buildStudentsList(),
                      _buildStudentsList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStudentsList({
    ActiveStatus? status ,
    int? halaqaId,
    DateTime? trackDate,
    Frequency? frequencyCode,
  }) {
    return BlocProvider(
      create: (context) => sl<StudentBloc>()
        ..add(
          FilteredStudents(
            status: status,
            halaqaId: halaqaId,
            trackDate: trackDate,
            frequencyCode: frequencyCode,
          ),
        ),

      child: BlocBuilder<StudentBloc, StudentState>(
        builder: (context, state) {
          if (state.status == StudentStatus.loading && state.students.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == StudentStatus.failure && state.students.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: state.failure?.message'),
                  ElevatedButton(
                    onPressed: () => context.read<StudentBloc>().add(
                      const StudentsRefreshed(),
                    ),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }
          if (state.status == StudentStatus.success && state.students.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                if (state.status == StudentStatus.success &&
                    state.hasMorePages &&
                    !state.isLoadingMore) {
                  context.read<StudentBloc>().add(const StudentsRefreshed());
                }
              },
              child: const Center(child: Text('No students found.')),
            );
          }
          final filteredStudents = state.students;
          // .where(
          //   (t) => (status == ActiveStatus.unknown
          //       ? t.status == t.status
          //       : t.status == status),
          // )
          // .toList();
          return RefreshIndicator(
            onRefresh: () async {
              context.read<StudentBloc>().add(const StudentsRefreshed());
              // The refresh completes when the BLoC emits a new state.
            },
            child: ListView.separated(
              separatorBuilder: (_, __) => const SizedBox(height: 5),
              controller: _scrollController, // Controller for "load more"
              itemCount:
                  filteredStudents.length + (state.isLoadingMore ? 1 : 0),
              itemBuilder: (ctx, i) {
                if (i >= filteredStudents.length) {
                  // "Load More" indicator
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return CustomListListTile(
                  title: filteredStudents[i].name,
                  moreIcon: Icons.more_vert,
                  leading: Avatar(),
                  subtitle: filteredStudents[i].status.labelAr,
                  backgroundColor: AppColors.accent12,
                  border: Border.all(color: AppColors.accent70, width: 0.5),
                  onMoreTab: () => {},
                  onListTilePressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => StudentProfileScreen(
                          studentID: filteredStudents[i].id,
                        ),
                      ),
                    );
                  },
                  onTajPressed: () {
                    _showStudentReports(filteredStudents[i].name);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, left: 8, right: 8),
      child: Text(text, style: Theme.of(context).textTheme.bodyLarge!),
    );
  }

  void _showStudentReports(String studentName) {
    final planEntity = studentPlan.toEntity();
    final trackingEntities = studentTrackings
        .map((model) => model.toEntity())
        .toList();
    final factory = FollowUpReportFactory();
    final FollowUpReportBundleEntity reportBundle = factory.create(
      plan: planEntity,
      trackings: trackingEntities,
      totalPendingReports: 2,
    );

    showDialog(
      context: context,
      builder: (_) =>
          FollowUpReportDialog(studentName: studentName, bundle: reportBundle),
      //  StudentReports(name: student.name, report: logs),
    );
  }
}
