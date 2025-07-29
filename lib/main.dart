import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tajalwaqaracademy/config/localization/l10n_config.dart';
import 'package:tajalwaqaracademy/core/background/background_job_service.dart';
import 'package:tajalwaqaracademy/features/auth/presentation/bloc/auth_bloc.dart';
import 'config/di/injection.dart';
import 'shared/themes/app_theme.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();

  await initializeDateFormatting('ar');
  // Initialize all background services.
  await sl<BackgroundJobService>().initialize();
  runApp(
    BlocProvider.value(value: sl<AuthBloc>(), child: const TajAlWaqarApp()),
  );
}

class TajAlWaqarApp extends StatelessWidget {
  const TajAlWaqarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'أكاديمية تاج الوقار',
      debugShowCheckedModeBanner: false,

      // --- Localization Setup (Cleaned Up) ---
      // Use the centralized configuration from L10nConfig.
      localizationsDelegates: L10nConfig.delegates,
      supportedLocales: L10nConfig.supportedLocales,

      // Set the default locale for the app.
      locale: L10nConfig.defaultLocale,

      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
