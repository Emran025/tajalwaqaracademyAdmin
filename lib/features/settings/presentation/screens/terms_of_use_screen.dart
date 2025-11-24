import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tajalwaqaracademy/features/settings/presentation/bloc/settings_bloc.dart';

import '../../domain/entities/terms_of_use_entity.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('شروط الاستخدام'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        bottom: PreferredSize(preferredSize: Size.zero, child: Container()),
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        buildWhen: (previous, current) {
          if (previous is SettingsLoadSuccess && current is SettingsLoadSuccess) {
            return previous.termsOfUseStatus != current.termsOfUseStatus ||
                previous.termsOfUse != current.termsOfUse;
          }
          return true;
        },
        builder: (context, state) {
          if (state is SettingsLoadSuccess) {
            switch (state.termsOfUseStatus) {
              case SectionStatus.initial:
              case SectionStatus.loading:
                return const Center(child: CircularProgressIndicator());
              case SectionStatus.failure:
                return Center(
                  child: Text(
                    'حدث خطأ أثناء تحميل الشروط:\n${state.error?.message}',
                    textAlign: TextAlign.center,
                  ),
                );
              case SectionStatus.success:
                if (state.termsOfUse != null) {
                  return _buildTermsContent(context, state.termsOfUse!);
                }
                return const Center(child: Text('لم يتم العثور على شروط الاستخدام.'));
            }
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildTermsContent(BuildContext context, TermsOfUseEntity terms) {
    return CustomScrollView(
      slivers: [
        _buildSummaryCard(context, terms),
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
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return _buildSectionItem(context, terms.sections[index]);
            },
            childCount: terms.sections.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context, TermsOfUseEntity terms) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final formattedDate =
        "${terms.lastUpdated.year}-${terms.lastUpdated.month.toString().padLeft(2, '0')}-${terms.lastUpdated.day.toString().padLeft(2, '0')}";

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
                'شروط الاستخدام',
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'آخر تحديث: $formattedDate  |  الإصدار: ${terms.version}',
                style: textTheme.bodySmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const Divider(height: 24),
              ...terms.summary.map((point) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.check_circle_outline,
                        color: Colors.teal),
                    title: Text(point, style: textTheme.bodyMedium),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionItem(
      BuildContext context, SectionEntity section) {
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
              height: 1.5,
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
