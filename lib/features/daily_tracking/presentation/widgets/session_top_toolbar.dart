// lib/features/daily_tracking/presentation/widgets/session_bottom_toolbar.dart

import 'package:flutter/material.dart';

/// A specialized bottom toolbar for the recitation session screen.
///
/// This toolbar provides actions relevant to the current tracking task,
/// such as saving progress, viewing the task report, and other session-related tools.

/// A specialized bottom toolbar for the recitation session screen.
///
/// This toolbar provides actions relevant to the current tracking task,
/// such as saving progress, viewing the task report, and other session-related tools.
class SessionTopToolbar extends StatelessWidget {
  final VoidCallback onTap;
  const SessionTopToolbar({super.key, required this.onTap});

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
              print('bar_chart Options Tapped');
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
