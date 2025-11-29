import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tajalwaqaracademy/features/app/pages/app_navigation_manager.dart';
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
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AppNavigationManager _appNavigationManager = AppNavigationManager();
  @override
  void initState() {
    super.initState();
    context.read<AppSetupCubit>().initialize();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkAuthStatus();
      }
    });
  }

  void _checkAuthStatus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        //context.read<AuthBloc>().add(LogOutRequested(message: "good bye"));
        context.read<AuthBloc>().add(AppStarted());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          (previous.authStatus != current.authStatus ||
          current.authStatus == AuthStatus.authenticated),
      listener: (context, authState) async {
        if (authState.authStatus == AuthStatus.authenticated) {
          print("المستخدم مسجل الدخول - التوجيه إلى الصفحة الرئيسية");
          final userRole = authState.user?.role;

          if (userRole == UserRole.teacher) {
            context.go('/teacher_home');
          } else {
            context.go('/home');
          }
        } else if (authState.authStatus == AuthStatus.unauthenticated) {
           final hasSeenWelcome =
              await _appNavigationManager.hasSeenWelcomeScreen();
          if (hasSeenWelcome) {
            context.go('/login');
          } else {
            print("المستخدم غير مسجل الدخول - التوجيه إلى صفحة الترحيب");
            context.go('/welcome');
          }
        }
      },
      child: Scaffold(
        body: Container(
          width: size.width,
          height: size.height,
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Hero(
                tag: 'logo',
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.accent70,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: size.width * 0.70,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'أكاديمية تاج الوقار',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightCream,
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
