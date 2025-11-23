import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tajalwaqaracademy/core/models/user_role.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/presentation/ui/widgets/student_count_chart.dart';
import 'package:tajalwaqaracademy/shared/themes/app_theme.dart';

import '../../../../../core/models/cheet_tile.dart';
import '../../../../../shared/widgets/draggable_scrollable_sheet.dart';
import '../../../domain/entities/chart_filter_entity.dart';
import '../../bloc/supervisor_bloc.dart';

/// Main dashboard screen displaying statistics and analytics
/// Uses BLoC pattern for state management and follows OOP principles
class ModernDashboardScreen extends StatefulWidget {
  final UserRole role;
  const ModernDashboardScreen({super.key, required this.role});

  @override
  State<ModernDashboardScreen> createState() => _ModernDashboardScreenState();
}

class _ModernDashboardScreenState extends State<ModernDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final _DashboardStateBuilder _stateBuilder;

  @override
  void initState() {
    _stateBuilder = _DashboardStateBuilder(role: widget.role);
    super.initState();
    _initializeAnimation();
    _loadInitialData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: _buildFloatingActionButton(),
      body: SafeArea(child: _buildMainContent()),
    );
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  void _loadInitialData() {
    final bloc = context.read<SupervisorBloc>();
    bloc.add(LoadCountsDeltaEntity());
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _handleQuickAction,
      label: Text(
        "إجراء سريع",
        style: GoogleFonts.cairo(color: AppColors.lightCream),
      ),
      icon: Icon(Icons.flash_on, color: AppColors.lightCream),
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.only(left: 14, right: 14, top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          Expanded(child: _stateBuilder.buildDashboardContent(context)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      "الإحصائيات العامة",
      style: Theme.of(context).textTheme.titleLarge,
    );
  }

  void _handleQuickAction() {
    // Implement quick actions here
  }
}

/// Manages dashboard data and configurations
class DashboardDataManager {
  static const List<List<double>> _trendsData = [
    [300, 320, 310, 330, 340, 345, 342],
    [21, 22, 23, 23, 23, 23, 23],
    [50, 52, 54, 55, 56, 57, 57],
    [250, 260, 270, 280, 285, 290, 294],
  ];

  static const List<List<Color>> _colorGradients = [
    [Color(0xFFA69F91), Color(0xFF3C3D37)],
    [AppColors.accent, AppColors.mediumDark],
    [Color(0xFFB4B6A5), Color(0xFF5C6D55)],
    [Color(0xFFFFA17F), Color(0xFF00223E)],
  ];

  List<_DashboardStat> getInitialStats(UserRole role) {
    return [
      _DashboardStat(
        'الطلاب',
        '342',
        Icons.group,
        _colorGradients[1],
        _trendsData[1],
      ),
      if (role == UserRole.supervisor)
        _DashboardStat(
          'المعلمين',
          '23',
          Icons.school,
          _colorGradients[3],
          _trendsData[3],
        ),
      _DashboardStat(
        'الحلقات',
        '57',
        Icons.book,
        _colorGradients[0],
        _trendsData[0],
      ),
    ];
  }

  ChartFilterEntity getInitialFilter() {
    return ChartFilterEntity(
      entityType: UserRole.student,
      timePeriod: 'year',
      startDate: DateTime.now().subtract(const Duration(days: 30)),
      endDate: DateTime.now(),
    );
  }
}

/// Handles building different dashboard states and components
class _DashboardStateBuilder {
  final UserRole role;
  const _DashboardStateBuilder({required this.role});

  Widget buildDashboardContent(BuildContext context) {
    return Column(
      children: [
        _buildStatisticsGrid(context),
        const SizedBox(height: 16),
        _buildNotificationsSection(context),
      ],
    );
  }

  Widget _buildStatisticsGrid(BuildContext context) {
    return Expanded(
      flex: 2,
      child: BlocBuilder<SupervisorBloc, SupervisorState>(
        builder: (context, state) {
          final DashboardDataManager dataManager = DashboardDataManager();
          final stats = dataManager.getInitialStats(role);

          if (state is SupervisorLoaded && state.countsDeltaEntity !=null) {
            return 
            
             _buildLoadedStatisticsGrid(stats, state);
          } else {
            return _buildDefaultStatisticsGrid(stats);
          }
        },
      ),
    );
  }

  Widget _buildLoadedStatisticsGrid(
    List<_DashboardStat> stats,
    SupervisorLoaded state,
  ) {
    final updatedStats = [
      stats[0].copyWith(
        suTitle: "${state.countsDeltaEntity!.studentCount.count}",
      ),
      stats[1].copyWith(
        suTitle: "${state.countsDeltaEntity!.teacherCount.count}",
      ),
      stats[2].copyWith(
        suTitle: "${state.countsDeltaEntity!.halaqaCount.count}",
      ),
    ];

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: updatedStats.length,
      itemBuilder: (context, index) =>
          _buildStatCard(context, updatedStats[index]),
    );
  }

  Widget _buildDefaultStatisticsGrid(List<_DashboardStat> stats) {
    return GridView.builder(
      itemCount: stats.length,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) => _buildStatCard(context, stats[index]),
    );
  }

  Widget _buildStatCard(BuildContext context, _DashboardStat stat) {
    return BlocConsumer<SupervisorBloc, SupervisorState>(
      listener: _handleStatCardStateChange,
      builder: (context, state) {
        return _StatCardWidget(
          stat: stat,
          state: state,
          onTap: () => _handleStatCardTap(context, stat),
        );
      },
    );
  }

  void _handleStatCardStateChange(BuildContext context, SupervisorState state) {
    // Handle specific state changes like errors
  }

  void _handleStatCardTap(BuildContext context, _DashboardStat stat) {
    final selectedEntityType = UserRole.fromLabel(stat.title);
    context.read<SupervisorBloc>().add(
      LoadTimeline(
        filter: ChartFilterEntity(
          entityType: selectedEntityType,
          timePeriod: 'year',
          startDate: DateTime.now().subtract(const Duration(days: 30)),
          endDate: DateTime.now(),
        ),
      ),
    );
  }

  Widget _buildNotificationsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("📢 آخر التنبيهات", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        const _NotificationCard(
          title: "تمت إضافة حلقة جديدة بإشراف الشيخ خالد",
          timeAgo: "منذ 3 دقائق",
        ),
      ],
    );
  }
}

/// Individual statistic card widget
class _StatCardWidget extends StatelessWidget {
  final _DashboardStat stat;
  final SupervisorState state;
  final VoidCallback onTap;

  const _StatCardWidget({
    required this.stat,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DraggaBottomSheetBUtton(
      onTap: onTap,
      children: _buildDetailContent(context),
      child: Container(
        decoration: _buildCardDecoration(),
        padding: const EdgeInsets.all(16),
        child: _buildCardContent(),
      ),
    );
  }

  List<Widget> _buildDetailContent(BuildContext context) {
    if (state is SupervisorLoading) {
      return [_buildLoadingState()];
    } else if (state is SupervisorError) {
      return [_buildErrorState((state as SupervisorError).message)];
    } else if (_hasValidData(state)) {
      return _buildDetailedCharts(context, state as SupervisorLoaded);
    } else {
      return [_buildInitialState()];
    }
  }

  bool _hasValidData(SupervisorState state) {
    return state is SupervisorLoaded &&
        state.timelineData != null &&
        state.availableDateRange != null &&
        state.filter != null &&
        state.chartData != null;
  }

  List<Widget> _buildDetailedCharts(
    BuildContext context,
    SupervisorLoaded state,
  ) {
    return [
      Text(
        "📊 مخططات الطلاب التفصيلية",
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(color: AppColors.lightCream),
      ),
      const SizedBox(height: 16),
      SizedBox(
        height: 550,
        child: StudentCountChart(
          qualityData: state.chartData ?? [],
          filter: state.filter!,
          tile: ChartTile(
            title: 'تقييم جودة الإتقان',
            subTitle: "حسب الفترة",
            icon: Icons.assessment,
          ),
          onFilterChanged: (filter) {
            context.read<SupervisorBloc>().add(
              UpdateChartFilter(filter: filter),
            );
          },
        ),
      ),
    ];
  }

  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
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
    );
  }

  Widget _buildCardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(stat.icon, size: 36, color: AppColors.lightCream),
        const SizedBox(height: 8),
        Text(
          stat.suTitle,
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
        Expanded(child: _buildTrendChart()),
      ],
    );
  }

  Widget _buildTrendChart() {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: stat.trend
                .asMap()
                .entries
                .map((e) => FlSpot(e.key.toDouble(), e.value))
                .toList(),
            isStrokeCapRound: true,
            isCurved: true,
            color: AppColors.lightCream.withOpacity(0.8),
            dotData: const FlDotData(show: false),
            barWidth: 2,
          ),
        ],
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(show: false),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.lightCream),
          SizedBox(height: 16),
          Text("جاري تحميل البيانات..."),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text("حدث خطأ: $message", textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Retry logic
            },
            child: const Text("إعادة المحاولة"),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return const Center(child: Text("اضغط لتحميل البيانات"));
  }
}

/// Data model for dashboard statistics
class _DashboardStat {
  final String title;
  final String suTitle;
  final IconData icon;
  final List<Color> color;
  final List<double> trend;

  const _DashboardStat(
    this.title,
    this.suTitle,
    this.icon,
    this.color,
    this.trend,
  );

  _DashboardStat copyWith({
    String? title,
    String? suTitle,
    IconData? icon,
    List<Color>? color,
    List<double>? trend,
  }) {
    return _DashboardStat(
      title ?? this.title,
      suTitle ?? this.suTitle,
      icon ?? this.icon,
      color ?? this.color,
      trend ?? this.trend,
    );
  }
}

/// Notification card component
class _NotificationCard extends StatelessWidget {
  final String title;
  final String timeAgo;

  const _NotificationCard({required this.title, required this.timeAgo});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: _buildNotificationDecoration(context),
      child: ListTile(
        leading: const Icon(
          Icons.notifications_active,
          color: AppColors.lightCream,
        ),
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

  BoxDecoration _buildNotificationDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.accent70, width: 0.5),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
      ],
    );
  }
}

/// Chart data model (kept for compatibility)
class SalesDataPair {
  final DateTime date;
  final double amount;

  SalesDataPair(this.date, this.amount);
}

// Example data (kept for compatibility)
final List<SalesDataPair> sales = [
  SalesDataPair(DateTime(2017, 9, 20), 25),
  SalesDataPair(DateTime(2017, 9, 24), 50),
  SalesDataPair(DateTime(2017, 10, 3), 100),
  SalesDataPair(DateTime(2017, 10, 11), 75),
];
