import 'package:injectable/injectable.dart';
import 'package:tajalwaqaracademy/features/TeachersManagement/data/services/teacher_sync_service.dart';
import 'package:workmanager/workmanager.dart';
import 'package:tajalwaqaracademy/config/di/injection.dart'; // To get the sl instance
import 'background_job_service.dart';

// The unique name for our periodic sync task.
const _periodicSyncTask = "com.tajalwaqaracademy.sync.teachers";

/// A top-level function that acts as the entry point for WorkManager.
/// This function runs in a separate isolate.

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await configureDependencies();

        try {
 
    

    // We fetch the SyncService from the container and execute the sync.
    // In a larger app, you could use `task` name to decide which service to run.
    // Use the task name to decide which sync service to run.
    switch (task) {
      case _periodicSyncTask: // com.tajalwaqaracademy.sync.teachers
        await sl<TeacherSyncService>().performSync();
        break;
      // case _studentSyncTask:
      //   await sl<StudentSyncService>().performSync();
      //   break;
      
    }return true;
        } catch (e) {
      print('Background sync failed from callbackDispatcher: $e');
      return false; // Indicate failure
    }
    
  });
}

@LazySingleton(as: BackgroundJobService)
final class WorkmanagerJobServiceImpl implements BackgroundJobService {

  @override
  Future<void> initialize() async {
    // Initialize the WorkManager plugin with our callback dispatcher.
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false, // Set to true for detailed logs during development
    );

    // Register a periodic task for background synchronization.
    await Workmanager().registerPeriodicTask(
      _periodicSyncTask,
      _periodicSyncTask, // Task name
      frequency: const Duration(hours: 12), // Run roughly twice a day
      initialDelay: const Duration(minutes: 15), // Wait 15 mins after first launch
      constraints: Constraints(
        networkType: NetworkType.connected, // Only run when connected to a network
        requiresCharging: false,
      ),
      // If a task with the same name exists, it will be replaced.
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
    print('[WorkManager] Periodic sync task registered.');
  }
}