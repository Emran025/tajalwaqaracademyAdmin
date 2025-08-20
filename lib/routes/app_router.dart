import 'package:go_router/go_router.dart';
import 'package:tajalwaqaracademy/features/auth/presentation/ui/screens/logIn_screen.dart';
import 'package:tajalwaqaracademy/features/app/pages/splash_screen.dart';
import 'package:tajalwaqaracademy/features/app/pages/welcome_screen.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/presentation/ui/screens/home_screen.dart';
import 'package:tajalwaqaracademy/features/teacher_dashboard/presentation/ui/screens/home_screen.dart';

/// The main router configuration for the application.
///
/// This GoRouter instance handles all navigation logic, including authentication-based
/// redirects and the definition of all available routes.

// We need to listen to both streams now!
final appRouter = GoRouter(
  initialLocation: '/splash',

  routes: [
    /// Defines the route for the splash screen, shown on app startup.
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (_, __) => const SplashScreen(),
    ),

    /// Defines the route for the welcome screen, the first screen for unauthenticated users.
    GoRoute(
      path: '/welcome',
      name: 'welcome',
      builder: (_, __) => const WelcomeScreen(),
    ),

    /// Defines the route for the login screen.
    GoRoute(
      path: '/login', // Using snake_case for consistency
      name: 'login',
      builder: (_, __) => const LogInScreen(),
    ),

    /// Defines the route for the main dashboard for supervisor users.
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (_, __) => const TecherDashboard(),
      // builder: (_, __) => const SupervisorDashboard(),
    ),

    /// Defines the route for the main dashboard for teacher users.
    GoRoute(
      path: '/teacher_home',
      name: 'teacher_home',
      // Note: Ensure the class name 'TecherDashboard' is correct.
      // It might be a typo for 'TeacherDashboard'.
      builder: (_, __) => const SupervisorDashboard(),
      // builder: (_, __) => const TecherDashboard(),
    ),
  ],
);
