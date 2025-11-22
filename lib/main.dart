import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'config/localization/l10n_config.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'config/di/injection.dart';
import 'features/app/cubit/app_setup_cubit.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'shared/themes/app_theme.dart';
import 'routes/app_router.dart';
import 'package:flutter/services.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  // Initialize date formatting for Arabic locale.
  // This is necessary for proper date formatting in the app.
  await initializeDateFormatting('ar');
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<AppSetupCubit>()),
        // Provides the SettingsBloc globally, making it accessible application-wide.
        BlocProvider<SettingsBloc>(
          create: (context) => sl<SettingsBloc>(),
          // Immediately dispatch the event to load initial settings on app start.
        ),
        // Provides the AuthBloc globally. Using .value is not necessary here;
        // creating it is standard practice unless the instance must be preserved
        // across widget trees, which is not the case at the root.
        BlocProvider<AuthBloc>(create: (context) => sl<AuthBloc>()),
      ],
      child: const TajAlWaqarApp(),
    ),
  );
}

class TajAlWaqarApp extends StatelessWidget {
  const TajAlWaqarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        AppThemeType themeType = AppThemeType.light;
        if (state is SettingsLoadSuccess) {
          themeType = state.settings.themeType;
        }
        final themeData = AppThemes.getTheme(themeType);
        return MaterialApp.router(
          scrollBehavior: ScrollBehavior(),
          title: 'أكاديمية تاج الوقار',
          debugShowCheckedModeBanner: false,
          // --- Localization Setup (Cleaned Up) ---
          // Use the centralized configuration from L10nConfig.
          localizationsDelegates: L10nConfig.delegates,
          supportedLocales: L10nConfig.supportedLocales,
          // Set the default locale for the app.
          locale: L10nConfig.defaultLocale,
          theme: themeData,
          // darkTheme: AppThemes.getTheme(AppThemeType.dark),
          // themeMode: ThemeMode.system,
          routerConfig: appRouter,
        );
      },
    );
  }
}

//  {login: amran@naser.com, password: amran$$$025, device_info: {device_id: AE3A.240806.043, model: sdk_gphone64_x86_64, manufacturer: Google, os_version: Android 15 (SDK 35), app_version: 1.0.0+1, timezone: Asia/Riyadh, locale: en_US, fcm_token: dummy_push_token_for_development_env}}
