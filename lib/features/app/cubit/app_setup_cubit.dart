// lib/app/cubit/app_setup_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/di/injection.dart';
import '../../../core/background/background_job_service.dart';
import '../../../core/database/app_database.dart';

enum AppStatus { initializing, ready, error }

class AppSetupCubit extends Cubit<AppStatus> {
  AppSetupCubit() : super(AppStatus.initializing);

  Future<void> initialize() async {
    try {
      // 1. We no longer need allReady(), as we are controlling the sequence.
      // await sl.allReady(); // <-- REMOVE THIS LINE
      
      // 2. Explicitly initialize the database.
      // This call will force the singleton to be created and the DB to be opened.
      await sl<AppDatabase>().database;
      print("Database Initialized Successfully");

      // 3. Initialize other services.
      await sl<BackgroundJobService>().initialize();
      print("Background Service Initialized Successfully");

      emit(AppStatus.ready);
      print("AppStatus emitted: ready");

    } catch (e) {
      print("Initialization Error: $e");
      emit(AppStatus.error);
    }
  }
}

