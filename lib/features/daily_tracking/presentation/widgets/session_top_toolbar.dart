// lib/features/daily_tracking/presentation/widgets/session_bottom_toolbar.dart

import 'dart:ui';

import 'package:flutter/material.dart';

/// A specialized bottom toolbar for the recitation session screen.
///
/// This toolbar provides actions relevant to the current tracking task,
/// such as saving progress, viewing the task report, and other session-related tools.

import 'package:tajalwaqaracademy/core/models/cheet_tile.dart';
import 'package:tajalwaqaracademy/features/daily_tracking/presentation/pages/student_error_analysis_chart.dart';

/// A specialized bottom toolbar for the recitation session screen.
///
/// This toolbar provides actions relevant to the current tracking task,
/// such as saving progress, viewing the task report, and other session-related tools.
class SessionTopToolbar extends StatelessWidget {
  final VoidCallback onTap;
  final String enrollmentId;
  const SessionTopToolbar({
    super.key,
    required this.onTap,
    required this.enrollmentId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.only(
        bottom: 16.0,
        top: 8.0,
        left: 8.0,
        right: 8.0,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              onTap();
              print('More Options Tapped');
            },
            icon: Icon(
              Icons.menu,
              size: 26,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                useRootNavigator: true,
                builder: (context) => BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: DraggableScrollableSheet(
                    expand: false,
                    initialChildSize: 0.75,
                    maxChildSize: 0.75,
                    builder: (context, scrollController) {
                      return StudentErrorAnalysisChart(
                        enrollmentId: enrollmentId,
                        tile: const ChartTile(
                          title: 'تحليل أداء الطالب',
                          subTitle: 'عرض إحصائيات الأخطاء',
                          icon: Icons.bar_chart,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
            icon: Icon(
              Icons.bar_chart,
              // Icons.show_chart
              // Icons.multiline_chart
              // Icons.pie_chart
              // Icons.insights
              // Icons.analytics
              // Icons.timeline
              // Icons.query_stats
              size: 26,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
