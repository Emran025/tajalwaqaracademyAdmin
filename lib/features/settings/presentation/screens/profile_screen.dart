// path: lib/features/settings/presentation/screens/profile_screen.dart (New File)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/ui/widgets/change_password_dialog.dart';
import '../../domain/entities/user_session_entity.dart';
import '../bloc/settings_bloc.dart';
import '../widgets/modern_setting_tile.dart';
import '../widgets/settings_group_widget.dart';

/// The main screen for displaying and managing the user's profile.
///
/// This screen is responsible for:
/// - Displaying user information (avatar, name, email).
/// - Providing entry points for editing the profile and changing the password.
/// - Listing all active user sessions with contextual actions.
/// It reacts to the [SettingsState] to show loading, error, and success states
/// for the user profile data.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          // The parent must be in a loaded state to reach here.
          if (state is! SettingsLoadSuccess) {
            // This case should ideally not be hit if navigation is handled correctly,
            // but serves as a robust fallback.
            return const Center(child: CircularProgressIndicator());
          }
          return _buildProfileContent(context, state);
        },
      ),
    );
  }

  /// Builds the main content area of the profile screen.
  Widget _buildProfileContent(BuildContext context, SettingsLoadSuccess state) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: const Text('الملف الشخصي'),
          // Makes the AppBar float and snap back into view, a modern UX pattern.
          floating: true,
          pinned: true,
          snap: true,
          elevation: 0,
          backgroundColor: Theme.of(
            context,
          ).scaffoldBackgroundColor.withAlpha(200),
        ),

        // --- Profile Header Section ---
        // Display the header if the profile data is successfully loaded.
        if (state.profileStatus == SectionStatus.success &&
            state.userProfile != null)
          SliverToBoxAdapter(
            child: _ProfileHeader(user: state.userProfile!.user),
          ),

        // --- Loading/Error State for Profile Section ---
        // Show a loading indicator while the profile is being fetched.
        if (state.profileStatus == SectionStatus.loading)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          ),

        // Show an error message if the profile fetch fails.
        if (state.profileStatus == SectionStatus.failure)
          SliverFillRemaining(
            child: Center(
              child: Text('فشل تحميل الملف الشخصي: ${state.error?.message}'),
            ),
          ),

        // --- Actions and Sessions (only shown after profile loads successfully) ---
        if (state.profileStatus == SectionStatus.success &&
            state.userProfile != null) ...[
          // --- Account Actions Group ---
          SliverToBoxAdapter(
            child: SettingsGroup(
              title: 'إدارة الحساب',
              children: [
                ModernSettingTile(
                  icon: Icons.edit_outlined,
                  iconBackgroundColor: Colors.blueAccent,
                  title: 'تعديل معلومات التواصل',
                  onTap: () {
                    /* TODO: Navigate to Edit Profile Form */
                  },
                ),
                ModernSettingTile(
                  icon: Icons.lock_outline,
                  iconBackgroundColor: Colors.deepPurpleAccent,
                  title: 'تغيير كلمة المرور',
                  onTap: () {
                    /* TODO: Navigate to Change Password Screen */
                    _showLogoutDialog();
                  },
                ),
              ],
            ),
          ),

          // --- Active Sessions Group ---
          SliverToBoxAdapter(
            child: SettingsGroup(
              title: 'الجلسات النشطة',
              children: state.userProfile!.activeSessions.isNotEmpty
                  ? state.userProfile!.activeSessions
                        .map((session) => _SessionCard(session: session))
                        .toList()
                  : [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: Text('لا توجد جلسات أخرى نشطة.')),
                      ),
                    ],
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => BlocProvider.value(
        value: context.read<AuthBloc>(),
        child: const ChangePasswordDialog(),
      ),
    );
  }
}

/// A private widget to display the main profile header.
class _ProfileHeader extends StatelessWidget {
  final UserEntity user;
  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            backgroundImage:
                user.avatar != null && !user.avatar!.contains('example')
                ? NetworkImage(user.avatar!)
                : null,
            child: user.avatar == null || user.avatar!.contains('example')
                ? Icon(Icons.person, size: 60, color: Colors.amber)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            user.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

/// A private widget to display a single active session.
class _SessionCard extends StatelessWidget {
  final UserSessionEntity session;
  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCurrent = session.isCurrentDevice;

    // Determine the icon based on device type (a simple example).
    IconData deviceIcon = Icons.devices_other;
    if (session.deviceInfo.deviceModel.toLowerCase().contains('iphone') ||
        session.deviceInfo.deviceModel.toLowerCase().contains('pixel') ||
        session.deviceInfo.deviceModel.toLowerCase().contains('galaxy')) {
      deviceIcon = Icons.phone_android;
    } else if (session.deviceInfo.osVersion.toLowerCase().contains('web')) {
      deviceIcon = Icons.web;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: isCurrent
          ? theme.colorScheme.primary.withOpacity(0.05)
          : Colors.transparent,
      child: Row(
        children: [
          Icon(deviceIcon, color: theme.colorScheme.primary, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${session.deviceInfo.manufacturer} ${session.deviceInfo.deviceModel}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  // Example: "Last active: Aug 10, 2025"
                  'آخر نشاط: ${MaterialLocalizations.of(context).formatMediumDate(session.lastAccessedAt)}',
                  style: theme.textTheme.bodySmall,
                ),
                if (isCurrent)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      '• هذا الجهاز',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (!isCurrent)
            TextButton(
              onPressed: () {
                // TODO: Dispatch a "RemoveSession" event to the BLoC
                // context.read<SettingsBloc>().add(RemoveSession(session.id));
              },
              child: const Text('تسجيل الخروج'),
            ),
        ],
      ),
    );
  }
}
