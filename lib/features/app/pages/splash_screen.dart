import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tajalwaqaracademy/shared/themes/app_theme.dart';

import '../../../core/models/user_role.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../cubit/app_setup_cubit.dart';

/// A stateless widget that displays the application's splash screen.
///
/// This screen is typically the first thing a user sees and is responsible for
/// showing branding while the application initializes in the background.
///
/// It is a [StatelessWidget] because its appearance does not change over time.
/// All navigation logic is handled externally by the `GoRouter`'s redirect system,
/// making this widget purely presentational.
class SplashScreen extends StatefulWidget {
  /// Creates a [SplashScreen].
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    context.read<AppSetupCubit>().initialize();
    super.initState();
    // Start the app initialization process.
  }

  @override
  Widget build(BuildContext context) {
    // This MultiBlocListener now lives within a context that is a descendant of GoRouter.
    // Get the device's screen size for responsive UI adjustments.
    final size = MediaQuery.of(context).size;
    return MultiBlocListener(
      listeners: [
        BlocListener<AppSetupCubit, AppStatus>(
          listener: (context, appStatus) {
            if (appStatus == AppStatus.ready) {
              print("object : 999999999999999999999999999999999");
              context.read<AuthBloc>().add(AppStarted());
            }
          },
        ),
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (previous, current) =>
              previous.authStatus != current.authStatus,
          listener: (context, authState) {
            print("object : 000000000000000000000000000");
            // This context.go() is guaranteed to work.
            if (authState.authStatus == AuthStatus.authenticated) {
              print("object : 11111111111111111111111111111111");
              final userRole = authState.user?.role;
              if (userRole == UserRole.teacher) {
                context.go('/teacher_home');
              } else {
                context.go('/home');
              }
            } else if (authState.authStatus == AuthStatus.unauthenticated) {
              context.go('/welcome');
            }
          },
        ),
      ],
      // While the listeners are working in the background, we show the actual splash screen UI.
      child: Scaffold(
        body: Container(
          // Ensure the container fills the entire screen.
          width: size.width,
          height: size.height,
          // Apply a decorative gradient background.
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.accent,
                AppColors.mediumDark,
                AppColors.darkBackground,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          // Center the content vertically and horizontally.
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // The Hero widget enables a "hero" animation (a shared element transition).
              // This is often used to animate an element from one screen to another,
              // for example, animating the logo from the splash screen to the login screen.
              Hero(
                tag: 'logo', // A unique tag to identify the hero element.
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.accent70,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width:
                        size.width *
                        0.70, // Logo width is 70% of the screen width.
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // The application's name.
              const Text(
                'أكاديمية تاج الوقار',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightCream,
                  // Add a subtle drop shadow for better text readability.
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
