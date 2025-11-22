import 'package:flutter/material.dart';
import 'package:tajalwaqaracademy/shared/widgets/taj.dart';

import '../themes/app_theme.dart';

class CustomListTile extends StatelessWidget {
  final String? tajLable;
  final String title;
  final String subtitle;
  final Color? moreColor;
  final Widget? leading;
  final Color backgroundColor;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final IconData? moreIcon;
  final bool hasMoreIcon;
  final VoidCallback? onTajPressed;
  final VoidCallback? onListTilePressed;
  final VoidCallback? onMoreTab;
  const CustomListTile({
    super.key,
    this.tajLable = "تقرير",
    this.subtitle = "",
    required this.title,
    required this.moreIcon,
    this.moreColor = AppColors.lightCream,
    required this.leading,
    required this.backgroundColor,
    required this.border,
    this.boxShadow = const [
      BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
    ],
    this.onMoreTab,
    this.hasMoreIcon = true,
    this.onListTilePressed,
    this.onTajPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        // color: Theme.of(context).colorScheme.primaryContainer,
        // borderRadius: BorderRadius.circular(24),
        borderRadius: BorderRadius.circular(12),
        border:
            border ??
            Border.all(
              color: theme.brightness != Brightness.dark
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
      child: ListTile(
        onTap: () => onListTilePressed!(),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () => onTajPressed!(),
              child: StatusTag(lable: tajLable),
            ),
            if (hasMoreIcon)
              IconButton(
                icon: Icon(moreIcon ?? Icons.more_vert, color: moreColor),
                onPressed: () => onMoreTab!(),
              ),
          ],
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18),
        shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        leading: leading,
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.brightness != Brightness.dark
                ? theme.colorScheme.surface
                : AppColors.lightCream,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: theme.brightness != Brightness.dark
                  ? theme.colorScheme.surface
                  : AppColors.lightCream,
            ),
          ),
        ),
      ),
    );
  }
}
