import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tajalwaqaracademy/core/utils/go_router_refresh_stream.dart';
import 'package:tajalwaqaracademy/features/auth/presentation/ui/screens/splash_screen.dart';
import 'package:tajalwaqaracademy/features/auth/presentation/ui/screens/welcome_screen.dart';

import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/ui/screens/login_screen.dart';

import '../config/di/injection.dart';
import '../features/supervisor_dashboard/presentation/ui/screens/home_screen.dart'; // تأكد أنه مفعل

import '../features/auth/presentation/bloc/auth_state.dart';

/// نستلّم الـ AuthBloc من GetIt
final _authBloc = sl<AuthBloc>();

final appRouter = GoRouter(
  initialLocation: '/',
  // يعيد فحص redirect كلما تغيّرت حالة الـ BLoC
  refreshListenable: GoRouterRefreshStream(_authBloc.stream),

  redirect: (BuildContext ctx, GoRouterState state) {
    final loggedIn =
        _authBloc.state is AuthSuccess ||
        _authBloc.state is SignUpSuccess ||
        _authBloc.state is LoginSuccess;
    final onAuthPages = state.uri.path == '/' || state.uri.path == '/login';

    if (!loggedIn && !onAuthPages) {
      print('غير مسجل، إعادة التوجيه إلى شاشة الترحيب');
      print(_authBloc.state);
      print(state.uri.path);
      // غير مسجل → شاشة الترحيب
      return '/';
    }
    if (loggedIn && onAuthPages) {
      print('مسجل، إعادة التوجيه إلى الصفحة الرئيسية');
      print(_authBloc.state);
      print(state.uri.path);
      // مسجل ويريد الوصول لـ welcome/login → home
      return '/Splash';
    }
    print(_authBloc.state);
    print(state.uri.path);
    return null; // متابعة التنقل الطبيعي
  },

  routes: [
    GoRoute(
      path: '/',
      name: 'welcome',
      builder: (_, __) => const SupervisorDashboard(),
    ),
    GoRoute(
      path: '/Splash',
      name: 'Splash',
      builder: (_, __) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (_, __) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      // builder: (_, __) => const SplashScreen(),
      builder: (_, __) => const SupervisorDashboard(),
    ),
    // GoRoute(
    //   path: '/supervisor_dashboard',
    //   name: 'supervisor_dashboard',
    //   builder: (_, __) => const Placeholder(),
    // ),
  ],
);
