// lib/features/settings/presentation/screens/privacy_policy_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tajalwaqaracademy/features/settings/presentation/bloc/settings_bloc.dart';

import '../../domain/entities/privacy_policy_entity.dart';

/// A screen dedicated to displaying the Privacy Policy.
///
/// This widget is a "dumb" component, driven entirely by the [SettingsBloc] state.
/// It listens for changes and rebuilds its UI to reflect the current data
/// loading status (loading, success, or failure). This separation of concerns
/// keeps the UI layer clean and focused on rendering.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('سياسة الخصوصية'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        // Using a zero-height bottom to ensure a clean look with CustomScrollView
        bottom: PreferredSize(preferredSize: Size.zero, child: Container()),
      ),
      // BlocBuilder rebuilds the UI in response to state changes from the SettingsBloc.
      // We specifically build when the `policyStatus` or `privacyPolicy` might change.
      body: BlocBuilder<SettingsBloc, SettingsState>(
        buildWhen: (previous, current) {
          // Optimization: only rebuild if the relevant parts of the state have changed.
          if (previous is SettingsLoadSuccess &&
              current is SettingsLoadSuccess) {
            return previous.policyStatus != current.policyStatus ||
                previous.privacyPolicy != current.privacyPolicy;
          }
          return true;
        },
        builder: (context, state) {
          // The state must be `SettingsLoadSuccess` to contain policy info.
          if (state is SettingsLoadSuccess) {
            switch (state.policyStatus) {
              case SectionStatus.initial:
              case SectionStatus.loading:
                // Display a loading indicator while the policy is being fetched.
                return const Center(child: CircularProgressIndicator());
              case SectionStatus.failure:
                // Display a user-friendly error message if the fetch fails.
                return Center(
                  child: Text(
                    'حدث خطأ أثناء تحميل السياسة:\n${state.error?.message}',
                    textAlign: TextAlign.center,
                  ),
                );
              case SectionStatus.success:
                // On success, check if the policy data is actually available.
                if (state.privacyPolicy != null) {
                  return _buildPolicyContent(context, state.privacyPolicy!);
                }
                // Handle the edge case where status is success but data is null.
                return const Center(
                  child: Text('لم يتم العثور على سياسة الخصوصية.'),
                );
            }
          }
          // Fallback for any other state (e.g., global failure), though unlikely to be hit
          // if navigated from a successful SettingsScreen.
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  /// Builds the main scrollable content area for the privacy policy.
  ///
  /// This helper function creates a visually appealing and organized layout
  /// for the policy document using a `CustomScrollView`.
  Widget _buildPolicyContent(BuildContext context, PrivacyPolicyEntity policy) {
    return CustomScrollView(
      slivers: [
        // A prominent summary card at the top.
        _buildSummaryCard(context, policy),

        // A header for the detailed sections.
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Text(
              'التفاصيل الكاملة',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),

        // An efficient, lazy-loaded list of expandable policy sections.
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            return _buildSectionItem(context, policy.sections[index]);
          }, childCount: policy.sections.length),
        ),

        // Provides bottom padding for better visual spacing.
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  /// Builds the summary card displayed at the top of the screen.
  Widget _buildSummaryCard(BuildContext context, PrivacyPolicyEntity policy) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    // Simple date formatting
    final formattedDate =
        "${policy.lastUpdated.year}-${policy.lastUpdated.month.toString().padLeft(2, '0')}-${policy.lastUpdated.day.toString().padLeft(2, '0')}";

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'سياسة الخصوصية',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'آخر تحديث: $formattedDate  |  الإصدار: ${policy.version}',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const Divider(height: 24),
              // Dynamically create a list of summary points.
              ...policy.summary.map(
                (point) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.teal,
                  ),
                  title: Text(
                    point,
                    style: textTheme.bodyMedium!.copyWith(
                      color: Colors.white60,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a single, expandable list item for a policy section.
  ///
  /// Using [ExpansionTile] provides an excellent user experience by keeping the
  /// UI clean and allowing users to focus on one section at a time.
  Widget _buildSectionItem(BuildContext context, SectionEntity section) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ExpansionTile(
        title: Text(section.title, style: theme.textTheme.titleMedium),
        childrenPadding: const EdgeInsets.all(16.0),
        children: [
          Text(
            section.content,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5, // Improved line spacing for readability
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
