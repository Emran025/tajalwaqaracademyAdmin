// path: lib/features/settings/presentation/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tajalwaqaracademy/features/settings/presentation/screens/profile_screen.dart';

import 'data_management_screen.dart';
import '../bloc/settings_bloc.dart';
import '../widgets/modern_setting_tile.dart';
import '../widgets/settings_group_widget.dart';
import '../widgets/theme_switcher_widget.dart';
import 'privacy_policy_screen.dart';

/// The main UI screen for the application settings feature.
///
/// This widget is a "dumb" component, meaning it contains no business logic.
/// Its sole responsibility is to render the UI based on the current [SettingsState]
/// and to dispatch [SettingsEvent]s to the [SettingsBloc] in response to
/// user interactions.
class SettingsScreen extends StatefulWidget {
  /// Creates a const instance of the settings screen.
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    // Retrieve theme data once for reuse, improving readability.
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        // The user-facing title remains in its original language.
        title: const Text('الإعدادات'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        // Using a zero-height bottom to ensure a clean look with CustomScrollView
        bottom: PreferredSize(preferredSize: Size.zero, child: Container()),
      ),
      // BlocBuilder is the core of the reactive UI. It listens to state changes
      // from the SettingsBloc and rebuilds the widget tree accordingly.
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          // State 1: A catastrophic failure occurred while loading initial data.
          // Display a full-screen error message.
          if (state is SettingsLoadFailure) {
            return Center(
              child: Text('خطأ في تحميل الإعدادات: ${state.failure.message}'),
            );
          }

          // State 2: Data is loading (either initial or subsequent).
          // Display a central loading indicator. This covers `SettingsInitial`.
          if (state is! SettingsLoadSuccess) {
            return const Center(child: CircularProgressIndicator());
          }

          // State 3: Data has been successfully loaded.
          // Render the main content of the settings screen.
          return _buildSettingsContent(context, state, colorScheme);
        },
      ),
    );
  }

  /// Builds the main scrollable content of the settings screen.
  ///
  /// This private helper method is extracted for clarity and separation of concerns.
  /// It takes the successfully loaded state and constructs the UI accordingly.
  Widget _buildSettingsContent(
    BuildContext context,
    SettingsLoadSuccess state,
    ColorScheme colorScheme,
  ) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SettingsGroup(
            title: 'المظهر',
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ThemeSwitcherWidget(
                  // Data binding: The widget's value is driven by the BLoC state.
                  currentTheme: state.settings.themeType,
                  // Event dispatching: User interactions trigger events to the BLoC.
                  onThemeSelected: (newTheme) {
                    setState(() {
                      context.read<SettingsBloc>().add(ThemeChanged(newTheme));
                    });
                  },
                ),
              ),
            ],
          ),
        ),

        // --- Account Group ---
        SliverToBoxAdapter(
          child: SettingsGroup(
            title: 'الحساب',
            children: [
              ModernSettingTile(
                icon: Icons.person_outline,
                iconBackgroundColor: Colors.blue,
                title: 'الملف الشخصي',
                subtitle: 'عرض الملف الشخصي وجلسات التسجيل، تعديل وكلمة المرور',
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  context.read<SettingsBloc>().add(LoadUserProfile());
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
              ),
            ],
          ),
        ),

        // --- Preferences Group ---
        SliverToBoxAdapter(
          child: SettingsGroup(
            title: 'الإشعارات والتنبيهات',
            children: [
              ModernSettingTile(
                icon: Icons.notifications_outlined,
                iconBackgroundColor: Colors.orange,
                title: 'تفعيل الإشعارات',
                subtitle: 'استقبال تنبيهات الدروس والتحديثات',
                trailing: Switch(
                  value: state.settings.notificationsEnabled,
                  onChanged: (value) {
                    context.read<SettingsBloc>().add(
                      NotificationsPreferenceChanged(value),
                    );
                  },
                  activeColor: colorScheme.primary,
                ),
                // UX Improvement: The entire row is tappable to toggle the switch.
                onTap: () {
                  final currentValue = state.settings.notificationsEnabled;
                  context.read<SettingsBloc>().add(
                    NotificationsPreferenceChanged(!currentValue),
                  );
                },
              ),
            ],
          ),
        ),

        SliverToBoxAdapter(
          child: SettingsGroup(
            title: "مركز البيانات",
            children: [
              ModernSettingTile(
                icon: Icons.storage_outlined,
                iconBackgroundColor: Colors.indigo,
                title: 'إدارة البيانات',
                subtitle: 'استيراد وتصدير بيانات التطبيق',
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: BlocProvider.of<SettingsBloc>(context),
                        child: const DataManagementScreen(),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: SettingsGroup(
            title: 'الدعم والخصوصية',
            children: [
              ModernSettingTile(
                icon: Icons.analytics_outlined,
                iconBackgroundColor: Colors.purple,
                title: 'تحليل البيانات',
                subtitle: 'المساهمة في تحسين التطبيق',
                trailing: Switch(
                  value: state.settings.analyticsEnabled,
                  onChanged: (value) {
                    context.read<SettingsBloc>().add(
                      AnalyticsPreferenceChanged(value),
                    );
                  },
                  activeColor: colorScheme.primary,
                ),
                onTap: () {
                  final currentValue = state.settings.analyticsEnabled;
                  context.read<SettingsBloc>().add(
                    AnalyticsPreferenceChanged(!currentValue),
                  );
                },
              ),
              ModernSettingTile(
                icon: Icons.description_outlined,
                iconBackgroundColor: Colors.grey,
                title: 'شروط الاستخدام',
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: Implement navigation to Terms of Use Screen
                },
              ),
              ModernSettingTile(
                icon: Icons.privacy_tip_outlined,
                iconBackgroundColor: Colors.indigoAccent,
                title: 'سياسة الخصوصية',
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // --- START OF UPDATED CODE ---

                  // 1. Dispatch the event to tell the BLoC to start fetching the data.
                  context.read<SettingsBloc>().add(LoadPrivacyPolicy());

                  // 2. Immediately navigate to the policy screen.
                  //    The screen itself will handle showing the loading indicator.
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        // Provide the existing BLoC instance to the new screen
                        // so it can listen to the state changes we just triggered.
                        value: BlocProvider.of<SettingsBloc>(context),
                        child: const PrivacyPolicyScreen(),
                      ),
                    ),
                  );
                  // --- END OF UPDATED CODE ---
                },
              ),
              ModernSettingTile(
                icon: Icons.help_outline,
                iconBackgroundColor: Colors.green,
                title: 'المساعدة والدعم',
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: Implement navigation to Help & Support Screen
                },
              ),
            ],
          ),
        ),
        // Provides bottom padding for better visual spacing when scrolled to the end.
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}
