// path: lib/features/settings/presentation/widgets/theme_switcher_widget.dart
import 'package:flutter/material.dart';
// تأكد من استيراد ملف الثيمات الذي يحتوي على AppThemeType

import '../../../../shared/themes/app_theme.dart';

/// ودجت متخصص لعرض خيارات الثيم والتبديل بينها.
/// مصمم ليكون قطعة واجهة مستقلة تتلقى الحالة وترسل الأحداث.
class ThemeSwitcherWidget extends StatelessWidget {
  /// الثيم المحدد حاليًا، والذي سيتم استلامه من الـ BLoC State.
  final AppThemeType currentTheme;

  /// دالة Callback يتم استدعاؤها عند اختيار المستخدم لثيم جديد.
  /// تقوم بإرسال القيمة الجديدة (AppThemeType) إلى الـ BLoC.
  final ValueChanged<AppThemeType> onThemeSelected;

  const ThemeSwitcherWidget({
    super.key,
    required this.currentTheme,
    required this.onThemeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // استخدام SegmentedButton من Material 3 لتجربة مستخدم عصرية.
    return SegmentedButton<AppThemeType>(
      // 1. تحديد الخيار الفعّال حاليًا.
      // يجب أن يكون من نوع Set، لذلك نضع القيمة الحالية داخل {}.
      selected: {currentTheme},

      // 2. معالجة التغيير عند اختيار المستخدم.
      onSelectionChanged: (newSelection) {
        // `newSelection` هي Set، وبما أننا في وضع الاختيار الأحادي،
        // فإنها ستحتوي دائمًا على عنصر واحد فقط.
        // نستدعي الـ callback بالقيمة الجديدة.
        onThemeSelected(newSelection.first);
      },

      // 3. تصميم الودجت ليتناسب مع هوية التطبيق.
      style: SegmentedButton.styleFrom(
        // لون الخلفية العام للودجت
        backgroundColor: theme.colorScheme.surface.withOpacity(0.5),
        // لون الأيقونة والنص للعناصر غير المحددة
        foregroundColor: theme.colorScheme.onSurface.withOpacity(0.7),
        // لون الأيقونة والنص للعنصر المحدد (الفعّال)
        selectedForegroundColor: theme.colorScheme.onPrimary,
        // لون خلفية العنصر المحدد (الفعّال)
        selectedBackgroundColor: theme.colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),

      // 4. تعريف الخيارات (Segments) التي ستظهر للمستخدم.
      // استخدام `const` هنا يحسن الأداء.
      segments: const [
        ButtonSegment<AppThemeType>(
          value: AppThemeType.light,
          label: Text('فاتح'),
          icon: Icon(Icons.wb_sunny_outlined),
        ),
        ButtonSegment<AppThemeType>(
          value: AppThemeType.dark,
          label: Text('داكن'),
          icon: Icon(Icons.nightlight_round_outlined),
        ),
        ButtonSegment<AppThemeType>(
          value: AppThemeType.reading,
          label: Text('قراءة'),
          icon: Icon(
            Icons.chrome_reader_mode_outlined,
          ), // أيقونة أنسب لوضع القراءة
        ),
      ],
    );
  }
}
