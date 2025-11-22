// path: lib/features/settings/presentation/widgets/settings_group_widget.dart
import 'package:flutter/material.dart';

class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 20, top: 24, bottom: 8),
          child: Text(title.toUpperCase(), style: theme.textTheme.titleLarge),
        ),
        Card(
          elevation: 0,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: theme.colorScheme.onSurface.withOpacity(0.12),
              width: 1,
            ),
          ),

          clipBehavior: Clip.antiAlias,
          color: theme.brightness == Brightness.dark
              ? theme.colorScheme.surface
              : Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 4),
            shrinkWrap: true,
            itemCount: children.length,
            itemBuilder: (context, index) => children[index],
            separatorBuilder: (context, index) => Divider(
              height: 1,
              thickness: 1,
              indent: 56,
              color: theme.dividerColor.withOpacity(0.05),
            ),
          ),
        ),
      ],
    );
  }
}
